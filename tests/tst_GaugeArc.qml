import QtQuick
import QtTest
import DevDash.Gauges.Primitives 1.0

/**
 * @brief Unit tests for GaugeArc primitive
 */
TestCase {
    id: testCase
    name: "GaugeArcTests"
    when: windowShown

    width: 400
    height: 400

    // Test component
    GaugeArc {
        id: arc
        anchors.fill: parent
        strokeWidth: 20
        strokeColor: "#00aaff"
    }

    function init() {
        // Reset state before each test
        arc.startAngle = -225
        arc.sweepAngle = 270
        arc.strokeWidth = 20
        arc.strokeColor = "#00aaff"
        arc.arcOpacity = 1.0
        arc.animated = false
    }

    function test_configuredProperties() {
        compare(arc.startAngle, -225, "Configured startAngle")
        compare(arc.sweepAngle, 270, "Configured sweepAngle")
        compare(arc.strokeWidth, 20, "Stroke width")
    }

    function test_angleCalculation() {
        // Test that arc respects angle bounds
        arc.startAngle = 0
        arc.sweepAngle = 360
        compare(arc.startAngle, 0, "Start angle updated")
        compare(arc.sweepAngle, 360, "Sweep angle updated")
    }

    function test_colorChange() {
        arc.strokeColor = "#ff0000"
        compare(arc.strokeColor.toString(), "#ff0000", "Color change")
    }

    function test_arcOpacity() {
        arc.arcOpacity = 0.5
        compare(arc.arcOpacity, 0.5, "Arc opacity")
    }

    function test_animated() {
        arc.animated = true
        compare(arc.animated, true, "Animation enabled")
        arc.animated = false
        compare(arc.animated, false, "Animation disabled")
    }
}
