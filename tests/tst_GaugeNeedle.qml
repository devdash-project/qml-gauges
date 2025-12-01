import QtQuick
import QtTest
import DevDash.Gauges

/**
 * @brief Unit tests for gauge needle primitives
 */
TestCase {
    id: testCase
    name: "GaugeNeedleTests"
    when: windowShown

    width: 400
    height: 400

    // Test tapered needle
    GaugeNeedleTapered {
        id: taperedNeedle
        anchors.centerIn: parent
        angle: 0
        length: 100
        needleWidth: 8
        tipWidth: 2
        color: "#ff6600"
    }

    // Test classic needle
    GaugeNeedleClassic {
        id: classicNeedle
        anchors.centerIn: parent
        visible: false
        angle: 0
        length: 100
        needleWidth: 4
        color: "#ffffff"
    }

    function test_taperedNeedle_defaultProperties() {
        compare(taperedNeedle.angle, 0, "Default angle")
        compare(taperedNeedle.length, 100, "Default length")
        compare(taperedNeedle.needleWidth, 8, "Needle width")
        compare(taperedNeedle.tipWidth, 2, "Tip width (tapered)")
    }

    function test_taperedNeedle_angleRotation() {
        taperedNeedle.angle = 45
        compare(taperedNeedle.angle, 45, "Angle set to 45")

        taperedNeedle.angle = -90
        compare(taperedNeedle.angle, -90, "Negative angle")

        taperedNeedle.angle = 360
        compare(taperedNeedle.angle, 360, "Full rotation")
    }

    function test_taperedNeedle_animation() {
        taperedNeedle.animated = true
        compare(taperedNeedle.animated, true, "Animation enabled")

        taperedNeedle.spring = 5.0
        compare(taperedNeedle.spring, 5.0, "Spring stiffness")

        taperedNeedle.damping = 0.5
        compare(taperedNeedle.damping, 0.5, "Damping factor")
    }

    function test_classicNeedle_properties() {
        compare(classicNeedle.needleWidth, 4, "Classic needle width")
        compare(classicNeedle.counterweightRadius, 0, "No counterweight by default")

        classicNeedle.counterweightRadius = 10
        compare(classicNeedle.counterweightRadius, 10, "Counterweight set")
    }

    function test_needleColor() {
        taperedNeedle.color = "#00ff00"
        compare(taperedNeedle.color.toString(), "#00ff00", "Color change")
    }

    function test_needleBorder() {
        taperedNeedle.borderWidth = 2
        taperedNeedle.borderColor = "#000000"
        compare(taperedNeedle.borderWidth, 2, "Border width")
        compare(taperedNeedle.borderColor.toString(), "#000000", "Border color")
    }
}
