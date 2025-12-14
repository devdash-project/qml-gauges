#include "stateserver.h"
#include <QDebug>

StateServer::StateServer(QObject *parent)
    : QObject(parent)
{
}

StateServer::~StateServer()
{
    stop();
}

bool StateServer::start(int port)
{
    if (m_server && m_server->isListening()) {
        qWarning() << "StateServer already listening on port" << m_port;
        return true;
    }

    m_port = port;
    m_server = new QWebSocketServer(
        QStringLiteral("QML Gauges State Server"),
        QWebSocketServer::NonSecureMode,
        this
    );

    if (!m_server->listen(QHostAddress::LocalHost, port)) {
        qWarning() << "StateServer failed to listen on port" << port
                   << ":" << m_server->errorString();
        delete m_server;
        m_server = nullptr;
        return false;
    }

    connect(m_server, &QWebSocketServer::newConnection,
            this, &StateServer::onNewConnection);

    qInfo() << "StateServer listening on ws://localhost:" << port;
    emit listeningChanged();
    return true;
}

void StateServer::stop()
{
    if (!m_server) return;

    // Close all client connections
    for (QWebSocket *client : std::as_const(m_clients)) {
        client->close();
    }
    m_clients.clear();

    m_server->close();
    delete m_server;
    m_server = nullptr;

    qInfo() << "StateServer stopped";
    emit listeningChanged();
}

void StateServer::setCurrentPage(const QString &page)
{
    if (m_currentPage == page) return;

    m_currentPage = page;
    emit currentPageChanged(page);

    // Broadcast page change to all clients
    QJsonObject notification;
    notification["event"] = "pageChanged";
    notification["page"] = page;
    notification["title"] = m_currentPageTitle;
    broadcast(notification);
}

void StateServer::setCurrentPageTitle(const QString &title)
{
    if (m_currentPageTitle == title) return;

    m_currentPageTitle = title;
    emit currentPageTitleChanged(title);
}

void StateServer::setProperties(const QVariantMap &props)
{
    m_properties = props;
    emit propertiesChanged();
}

void StateServer::setPropertyMetadata(const QVariantList &metadata)
{
    m_propertyMetadata = metadata;
    emit propertyMetadataChanged();
}

void StateServer::updateProperty(const QString &name, const QVariant &value)
{
    m_properties[name] = value;

    // Broadcast property change to all clients
    QJsonObject notification;
    notification["event"] = "propertyChanged";
    notification["name"] = name;
    notification["value"] = QJsonValue::fromVariant(value);
    broadcast(notification);
}

void StateServer::onNewConnection()
{
    QWebSocket *client = m_server->nextPendingConnection();
    if (!client) return;

    qInfo() << "StateServer: new client connected from"
            << client->peerAddress().toString();

    connect(client, &QWebSocket::textMessageReceived,
            this, &StateServer::onTextMessage);
    connect(client, &QWebSocket::disconnected,
            this, &StateServer::onClientDisconnected);

    m_clients.insert(client);
}

void StateServer::onTextMessage(const QString &message)
{
    QWebSocket *client = qobject_cast<QWebSocket*>(sender());
    if (!client) return;

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(message.toUtf8(), &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        QJsonObject error;
        error["success"] = false;
        error["error"] = QString("JSON parse error: %1").arg(parseError.errorString());
        sendResponse(client, error);
        return;
    }

    if (!doc.isObject()) {
        QJsonObject error;
        error["success"] = false;
        error["error"] = "Request must be a JSON object";
        sendResponse(client, error);
        return;
    }

    QJsonObject response = handleRequest(doc.object());
    sendResponse(client, response);
}

void StateServer::onClientDisconnected()
{
    QWebSocket *client = qobject_cast<QWebSocket*>(sender());
    if (!client) return;

    qInfo() << "StateServer: client disconnected";
    m_clients.remove(client);
    client->deleteLater();
}

QJsonObject StateServer::handleRequest(const QJsonObject &request)
{
    QString action = request["action"].toString();
    QJsonObject response;

    if (action == "getState") {
        // Return full state
        QJsonObject data;
        data["page"] = m_currentPage;
        data["pageTitle"] = m_currentPageTitle;
        data["properties"] = QJsonObject::fromVariantMap(m_properties);
        data["propertyMetadata"] = QJsonArray::fromVariantList(m_propertyMetadata);

        response["success"] = true;
        response["data"] = data;

    } else if (action == "getProperty") {
        QString name = request["name"].toString();
        if (name.isEmpty()) {
            response["success"] = false;
            response["error"] = "Missing 'name' parameter";
        } else if (!m_properties.contains(name)) {
            response["success"] = false;
            response["error"] = QString("Property '%1' not found").arg(name);
        } else {
            QJsonObject data;
            data["name"] = name;
            data["value"] = QJsonValue::fromVariant(m_properties[name]);
            response["success"] = true;
            response["data"] = data;
        }

    } else if (action == "setProperty") {
        QString name = request["name"].toString();
        if (name.isEmpty()) {
            response["success"] = false;
            response["error"] = "Missing 'name' parameter";
        } else if (!request.contains("value")) {
            response["success"] = false;
            response["error"] = "Missing 'value' parameter";
        } else {
            QVariant value = request["value"].toVariant();

            // Emit signal for QML to handle the property change
            emit setPropertyRequested(name, value);

            response["success"] = true;
            QJsonObject data;
            data["name"] = name;
            data["value"] = request["value"];
            response["data"] = data;
        }

    } else if (action == "listProperties") {
        response["success"] = true;
        response["data"] = QJsonArray::fromVariantList(m_propertyMetadata);

    } else if (action == "navigate") {
        QString page = request["page"].toString();
        if (page.isEmpty()) {
            response["success"] = false;
            response["error"] = "Missing 'page' parameter";
        } else {
            // Emit signal for QML to handle navigation
            emit navigateRequested(page);
            response["success"] = true;
            QJsonObject data;
            data["page"] = page;
            response["data"] = data;
        }

    } else if (action == "ping") {
        response["success"] = true;
        QJsonObject data;
        data["pong"] = true;
        data["listening"] = isListening();
        response["data"] = data;

    } else {
        response["success"] = false;
        response["error"] = QString("Unknown action: '%1'").arg(action);
    }

    return response;
}

void StateServer::broadcast(const QJsonObject &message)
{
    QByteArray payload = QJsonDocument(message).toJson(QJsonDocument::Compact);
    for (QWebSocket *client : std::as_const(m_clients)) {
        client->sendTextMessage(QString::fromUtf8(payload));
    }
}

void StateServer::sendResponse(QWebSocket *client, const QJsonObject &response)
{
    QByteArray payload = QJsonDocument(response).toJson(QJsonDocument::Compact);
    client->sendTextMessage(QString::fromUtf8(payload));
}
