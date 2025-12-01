#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QSurfaceFormat>

int main(int argc, char *argv[])
{
    // Enable multisampling antialiasing for smooth Shape edges
    // This must be set before creating the QGuiApplication
    QSurfaceFormat format;
    format.setSamples(1000);  // Testing extreme MSAA
    QSurfaceFormat::setDefaultFormat(format);

    QGuiApplication app(argc, argv);

    // Set application metadata
    app.setOrganizationName("DevDash");
    app.setOrganizationDomain("devdash.io");
    app.setApplicationName("QML Gauges Explorer");
    app.setApplicationVersion("1.0.0");

    // Use Fusion style for better cross-platform appearance
    QQuickStyle::setStyle("Fusion");

    // Create QML engine
    QQmlApplicationEngine engine;

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
