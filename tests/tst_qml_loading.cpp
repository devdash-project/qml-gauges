/**
 * @file tst_qml_loading.cpp
 * @brief Tests that verify QML files load without errors
 *
 * These tests catch QML compilation errors, circular dependencies,
 * and initialization issues that would otherwise only show up at runtime.
 *
 * Complements the Qt Quick Test behavioral tests (tst_*.qml) by validating
 * that all components can be instantiated.
 */

#include <catch2/catch_session.hpp>
#include <catch2/catch_test_macros.hpp>

#include <cstdlib>
#include <iostream>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>

// Custom main to initialize QGuiApplication before Catch2 tests run
int main(int argc, char* argv[]) {
    // Qt requires QGuiApplication for QML/Quick components
    QGuiApplication app(argc, argv);

    // Run Catch2 tests
    return Catch::Session().run(argc, argv);
}

namespace qmlgauges {

// Helper to configure QML engine with import paths
static void setupEngine(QQmlEngine& engine) {
    const char* importPath = std::getenv("QML2_IMPORT_PATH");
    if (importPath) {
        engine.addImportPath(QString::fromUtf8(importPath));
    }
}

// Helper to create and check component
static QObject* createComponent(QQmlEngine& engine, const char* qml, const char* name) {
    QQmlComponent component(&engine);
    component.setData(qml, QUrl());

    if (component.status() == QQmlComponent::Error) {
        std::cerr << name << " errors:" << std::endl;
        for (const auto& error : component.errors()) {
            std::cerr << "  " << error.toString().toStdString() << std::endl;
        }
        return nullptr;
    }

    return component.create();
}

/**
 * @brief Test that DevDash.Gauges module is importable
 */
TEST_CASE("DevDash.Gauges module is importable", "[qml][module]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges
        Item {}
    )", "DevDash.Gauges import");

    REQUIRE(obj != nullptr);
    delete obj;
}

/**
 * @brief Test that DevDash.Gauges.Primitives module is importable
 */
TEST_CASE("DevDash.Gauges.Primitives module is importable", "[qml][module]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Primitives
        Item {}
    )", "DevDash.Gauges.Primitives import");

    REQUIRE(obj != nullptr);
    delete obj;
}

/**
 * @brief Test that DevDash.Gauges.Compounds module is importable
 */
TEST_CASE("DevDash.Gauges.Compounds module is importable", "[qml][module]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Compounds
        Item {}
    )", "DevDash.Gauges.Compounds import");

    REQUIRE(obj != nullptr);
    delete obj;
}

/**
 * @brief Test that GaugeArc primitive loads
 */
TEST_CASE("GaugeArc component loads", "[qml][primitives]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Primitives
        GaugeArc { width: 200; height: 200 }
    )", "GaugeArc");

    REQUIRE(obj != nullptr);
    REQUIRE(obj->property("startAngle").isValid());
    REQUIRE(obj->property("sweepAngle").isValid());
    REQUIRE(obj->property("strokeWidth").isValid());
    delete obj;
}

/**
 * @brief Test that GaugeFace primitive loads
 */
TEST_CASE("GaugeFace component loads", "[qml][primitives]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Primitives
        GaugeFace { width: 200; height: 200 }
    )", "GaugeFace");

    REQUIRE(obj != nullptr);
    REQUIRE(obj->property("color").isValid());
    delete obj;
}

/**
 * @brief Test that NeedleFrontBody primitive loads
 */
TEST_CASE("NeedleFrontBody component loads", "[qml][primitives][needles]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Primitives
        NeedleFrontBody { length: 100; pivotWidth: 10; tipWidth: 4 }
    )", "NeedleFrontBody");

    REQUIRE(obj != nullptr);
    REQUIRE(obj->property("length").isValid());
    REQUIRE(obj->property("pivotWidth").isValid());
    REQUIRE(obj->property("tipWidth").isValid());
    REQUIRE(obj->property("shape").isValid());
    delete obj;
}

/**
 * @brief Test that NeedleHeadTip primitive loads
 */
TEST_CASE("NeedleHeadTip component loads", "[qml][primitives][needles]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Primitives
        NeedleHeadTip { shape: "pointed"; baseWidth: 4 }
    )", "NeedleHeadTip");

    REQUIRE(obj != nullptr);
    REQUIRE(obj->property("shape").isValid());
    REQUIRE(obj->property("baseWidth").isValid());
    delete obj;
}

/**
 * @brief Test that NeedleRearBody primitive loads
 */
TEST_CASE("NeedleRearBody component loads", "[qml][primitives][needles]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Primitives
        NeedleRearBody { length: 25; pivotWidth: 10; tipWidth: 6 }
    )", "NeedleRearBody");

    REQUIRE(obj != nullptr);
    REQUIRE(obj->property("length").isValid());
    REQUIRE(obj->property("pivotWidth").isValid());
    REQUIRE(obj->property("tipWidth").isValid());
    delete obj;
}

/**
 * @brief Test that NeedleTailTip primitive loads
 */
TEST_CASE("NeedleTailTip component loads", "[qml][primitives][needles]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Primitives
        NeedleTailTip { shape: "crescent"; baseWidth: 6 }
    )", "NeedleTailTip");

    REQUIRE(obj != nullptr);
    REQUIRE(obj->property("shape").isValid());
    REQUIRE(obj->property("baseWidth").isValid());
    REQUIRE(obj->property("curveAmount").isValid());
    delete obj;
}

/**
 * @brief Test that GaugeBezel loads
 */
TEST_CASE("GaugeBezel component loads", "[qml][primitives]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Primitives
        GaugeBezel { width: 200; height: 200 }
    )", "GaugeBezel");

    REQUIRE(obj != nullptr);
    REQUIRE(obj->property("outerRadius").isValid());
    REQUIRE(obj->property("innerRadius").isValid());
    REQUIRE(obj->property("style").isValid());
    delete obj;
}

/**
 * @brief Test that GaugeCenterCap loads
 */
TEST_CASE("GaugeCenterCap component loads", "[qml][primitives]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Primitives
        GaugeCenterCap { width: 50; height: 50 }
    )", "GaugeCenterCap");

    REQUIRE(obj != nullptr);
    delete obj;
}

/**
 * @brief Test that GaugeTick loads
 */
TEST_CASE("GaugeTick component loads", "[qml][primitives]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Primitives
        GaugeTick { length: 20 }
    )", "GaugeTick");

    REQUIRE(obj != nullptr);
    REQUIRE(obj->property("length").isValid());
    delete obj;
}

/**
 * @brief Test that GaugeTickLabel loads
 */
TEST_CASE("GaugeTickLabel component loads", "[qml][primitives]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Primitives
        GaugeTickLabel { text: "100" }
    )", "GaugeTickLabel");

    REQUIRE(obj != nullptr);
    REQUIRE(obj->property("text").isValid());
    delete obj;
}

/**
 * @brief Test that GaugeTickRing compound loads
 */
TEST_CASE("GaugeTickRing component loads", "[qml][compounds]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Compounds
        GaugeTickRing { width: 300; height: 300; minValue: 0; maxValue: 100 }
    )", "GaugeTickRing");

    REQUIRE(obj != nullptr);
    REQUIRE(obj->property("minValue").isValid());
    REQUIRE(obj->property("maxValue").isValid());
    delete obj;
}

/**
 * @brief Test that GaugeValueArc compound loads
 */
TEST_CASE("GaugeValueArc component loads", "[qml][compounds]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Compounds
        GaugeValueArc { width: 200; height: 200; value: 50; minValue: 0; maxValue: 100 }
    )", "GaugeValueArc");

    REQUIRE(obj != nullptr);
    REQUIRE(obj->property("value").isValid());
    delete obj;
}

/**
 * @brief Test that GaugeZoneArc compound loads
 */
TEST_CASE("GaugeZoneArc component loads", "[qml][compounds]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Compounds
        GaugeZoneArc { width: 200; height: 200; startValue: 80; endValue: 100; minValue: 0; maxValue: 100 }
    )", "GaugeZoneArc");

    REQUIRE(obj != nullptr);
    delete obj;
}

/**
 * @brief Test that DigitalReadout compound loads
 */
TEST_CASE("DigitalReadout component loads", "[qml][compounds]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Compounds
        DigitalReadout { value: 123.4 }
    )", "DigitalReadout");

    REQUIRE(obj != nullptr);
    REQUIRE(obj->property("value").isValid());
    delete obj;
}

/**
 * @brief Test that RollingDigitReadout compound loads
 */
TEST_CASE("RollingDigitReadout component loads", "[qml][compounds]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Compounds
        RollingDigitReadout { value: 1234 }
    )", "RollingDigitReadout");

    REQUIRE(obj != nullptr);
    REQUIRE(obj->property("value").isValid());
    delete obj;
}

/**
 * @brief Test that GaugeNeedle compound loads
 */
TEST_CASE("GaugeNeedle component loads", "[qml][compounds][needles]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges.Compounds
        GaugeNeedle {
            width: 200; height: 300
            angle: 45
            frontLength: 100
            frontPivotWidth: 10
            frontTipWidth: 4
            headTipShape: "pointed"
            rearRatio: 0.25
            tailTipShape: "crescent"
        }
    )", "GaugeNeedle");

    REQUIRE(obj != nullptr);
    REQUIRE(obj->property("angle").isValid());
    REQUIRE(obj->property("frontLength").isValid());
    REQUIRE(obj->property("frontPivotWidth").isValid());
    REQUIRE(obj->property("headTipShape").isValid());
    REQUIRE(obj->property("rearRatio").isValid());
    REQUIRE(obj->property("tailTipShape").isValid());
    REQUIRE(obj->property("hasShadow").isValid());
    delete obj;
}

/**
 * @brief Test that RadialGauge template loads
 */
TEST_CASE("RadialGauge template loads", "[qml][templates]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges
        RadialGauge {
            width: 400; height: 400
            value: 50; minValue: 0; maxValue: 100
            label: "TEST"; unit: "units"
        }
    )", "RadialGauge");

    REQUIRE(obj != nullptr);
    REQUIRE(obj->property("value").isValid());
    REQUIRE(obj->property("minValue").isValid());
    REQUIRE(obj->property("maxValue").isValid());
    REQUIRE(obj->property("label").isValid());
    REQUIRE(obj->property("showFace").isValid());
    REQUIRE(obj->property("needleShape").isValid());
    REQUIRE(obj->property("needleHeadTipShape").isValid());
    delete obj;
}

/**
 * @brief Test that multiple gauges can be composed
 */
TEST_CASE("Multiple components compose without conflict", "[qml][integration]") {
    QQmlEngine engine;
    setupEngine(engine);

    auto* obj = createComponent(engine, R"(
        import QtQuick
        import DevDash.Gauges
        Item {
            width: 800; height: 400
            RadialGauge { id: g1; x: 0; width: 400; height: 400; value: 25 }
            RadialGauge { id: g2; x: 400; width: 400; height: 400; value: 75 }
        }
    )", "Multiple RadialGauges");

    REQUIRE(obj != nullptr);
    delete obj;
}

} // namespace qmlgauges
