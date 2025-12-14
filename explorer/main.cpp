#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include "stateserver.h"

int main(int argc, char *argv[])
{
    // Qt 6.10+ uses CurveRenderer for Shape antialiasing - no MSAA needed
    QGuiApplication app(argc, argv);

    // Set application metadata
    app.setOrganizationName("DevDash");
    app.setOrganizationDomain("devdash.io");
    app.setApplicationName("QML Gauges Explorer");
    app.setApplicationVersion("1.0.0");

    // Use Fusion style for better cross-platform appearance
    QQuickStyle::setStyle("Fusion");

    // Create and start the WebSocket state server for MCP integration
    StateServer stateServer;
    int statePort = 9876;

    // Allow port override via environment variable
    if (qEnvironmentVariableIsSet("QML_GAUGES_STATE_PORT")) {
        bool ok;
        int envPort = qEnvironmentVariableIntValue("QML_GAUGES_STATE_PORT", &ok);
        if (ok && envPort > 0 && envPort < 65536) {
            statePort = envPort;
        }
    }

    if (!stateServer.start(statePort)) {
        qWarning() << "Failed to start state server - MCP integration disabled";
    }

    // Create QML engine
    QQmlApplicationEngine engine;

    // Expose state server to QML
    engine.rootContext()->setContextProperty("stateServer", &stateServer);

    // Add QML import paths for the gauge library
    engine.addImportPath("qrc:/");
    engine.addImportPath(":/");

    // Add build directory import path for development
    // In production, modules would be installed to system QML path
    engine.addImportPath(QCoreApplication::applicationDirPath() + "/../qml");
    engine.addImportPath(QCoreApplication::applicationDirPath() + "/qml");

    // Load main QML file
    const QUrl url(QStringLiteral("qrc:/Explorer/qml/Main.qml"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl) {
                QCoreApplication::exit(-1);
            }
        },
        Qt::QueuedConnection);

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
