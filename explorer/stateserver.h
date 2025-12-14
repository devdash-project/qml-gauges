#ifndef STATESERVER_H
#define STATESERVER_H

#include <QObject>
#include <QWebSocketServer>
#include <QWebSocket>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QVariantMap>
#include <QSet>

/**
 * @brief WebSocket server for exposing explorer state to external tools (MCP).
 *
 * Enables programmatic interaction with the component explorer:
 * - Navigate to component pages
 * - Get/set property values
 * - List available properties
 * - Subscribe to state changes
 *
 * Protocol (JSON over WebSocket):
 *
 * Requests:
 *   {"action": "navigate", "page": "GaugeTick"}
 *   {"action": "getState"}
 *   {"action": "getProperty", "name": "tickShape"}
 *   {"action": "setProperty", "name": "tickShape", "value": "triangle"}
 *   {"action": "listProperties"}
 *
 * Responses:
 *   {"success": true, "data": {...}}
 *   {"success": false, "error": "..."}
 *
 * Notifications (broadcast to all clients):
 *   {"event": "pageChanged", "page": "GaugeTick", "title": "GaugeTick"}
 *   {"event": "propertyChanged", "name": "tickShape", "value": "triangle"}
 */
class StateServer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentPage READ currentPage WRITE setCurrentPage NOTIFY currentPageChanged)
    Q_PROPERTY(QString currentPageTitle READ currentPageTitle WRITE setCurrentPageTitle NOTIFY currentPageTitleChanged)
    Q_PROPERTY(QVariantMap properties READ properties WRITE setProperties NOTIFY propertiesChanged)
    Q_PROPERTY(QVariantList propertyMetadata READ propertyMetadata WRITE setPropertyMetadata NOTIFY propertyMetadataChanged)
    Q_PROPERTY(int port READ port CONSTANT)
    Q_PROPERTY(bool listening READ isListening NOTIFY listeningChanged)

public:
    explicit StateServer(QObject *parent = nullptr);
    ~StateServer() override;

    // Property accessors
    QString currentPage() const { return m_currentPage; }
    void setCurrentPage(const QString &page);

    QString currentPageTitle() const { return m_currentPageTitle; }
    void setCurrentPageTitle(const QString &title);

    QVariantMap properties() const { return m_properties; }
    void setProperties(const QVariantMap &props);

    QVariantList propertyMetadata() const { return m_propertyMetadata; }
    void setPropertyMetadata(const QVariantList &metadata);

    int port() const { return m_port; }
    bool isListening() const { return m_server && m_server->isListening(); }

    // QML-callable methods
    Q_INVOKABLE bool start(int port = 9876);
    Q_INVOKABLE void stop();
    Q_INVOKABLE void updateProperty(const QString &name, const QVariant &value);

signals:
    void currentPageChanged(const QString &page);
    void currentPageTitleChanged(const QString &title);
    void propertiesChanged();
    void propertyMetadataChanged();
    void listeningChanged();

    // Signals for QML to respond to external commands
    void navigateRequested(const QString &page);
    void setPropertyRequested(const QString &name, const QVariant &value);

private slots:
    void onNewConnection();
    void onTextMessage(const QString &message);
    void onClientDisconnected();

private:
    void broadcast(const QJsonObject &message);
    void sendResponse(QWebSocket *client, const QJsonObject &response);
    QJsonObject handleRequest(const QJsonObject &request);

    QWebSocketServer *m_server = nullptr;
    QSet<QWebSocket*> m_clients;

    QString m_currentPage;
    QString m_currentPageTitle;
    QVariantMap m_properties;
    QVariantList m_propertyMetadata;
    int m_port = 9876;
};

#endif // STATESERVER_H
