import QtQuick
import QtTest
import DevDash.Gauges

/**
 * @brief Integration tests for RadialGauge template
 */
TestCase {
    id: testCase
    name: "RadialGaugeTests"
    when: windowShown

    width: 500
    height: 500

    RadialGauge {
        id: gauge
        anchors.centerIn: parent
        width: 400
        height: 400

        value: 50
        minValue: 0
        maxValue: 100
        label: "TEST"
        unit: "units"
    }

    function test_valueRange() {
        compare(gauge.minValue, 0, "Min value")
        compare(gauge.maxValue, 100, "Max value")
        compare(gauge.value, 50, "Initial value")
    }

    function test_valueUpdate() {
        gauge.value = 75
        compare(gauge.value, 75, "Value updated")

        gauge.value = 0
        compare(gauge.value, 0, "Value at minimum")

        gauge.value = 100
        compare(gauge.value, 100, "Value at maximum")
    }

    function test_labels() {
        compare(gauge.label, "TEST", "Gauge label")
        compare(gauge.unit, "units", "Unit label")

        gauge.label = "RPM"
        compare(gauge.label, "RPM", "Label changed")
    }

    function test_thresholds() {
        gauge.warningThreshold = 70
        gauge.redlineStart = 90

        compare(gauge.warningThreshold, 70, "Warning threshold")
        compare(gauge.redlineStart, 90, "Redline start")
    }

    function test_featureToggles() {
        // Test feature visibility toggles
        compare(gauge.showFace, true, "Face visible by default")
        compare(gauge.showNeedle, true, "Needle visible by default")
        compare(gauge.showTicks, true, "Ticks visible by default")
        compare(gauge.showDigitalReadout, false, "Digital readout hidden by default")

        gauge.showDigitalReadout = true
        compare(gauge.showDigitalReadout, true, "Digital readout enabled")

        gauge.showBezel = true
        compare(gauge.showBezel, true, "Bezel enabled")
    }

    function test_tickConfiguration() {
        gauge.majorTickInterval = 20
        gauge.minorTickInterval = 5
        gauge.labelDivisor = 1

        compare(gauge.majorTickInterval, 20, "Major tick interval")
        compare(gauge.minorTickInterval, 5, "Minor tick interval")
        compare(gauge.labelDivisor, 1, "Label divisor")
    }

    function test_angleConfiguration() {
        compare(gauge.startAngle, -225, "Default start angle")
        compare(gauge.sweepAngle, 270, "Default sweep angle")

        gauge.startAngle = -180
        gauge.sweepAngle = 180

        compare(gauge.startAngle, -180, "Custom start angle")
        compare(gauge.sweepAngle, 180, "Custom sweep angle (half circle)")
    }

    function test_needleCustomization() {
        gauge.needleShape = "tapered"
        compare(gauge.needleShape, "tapered", "Tapered needle")

        gauge.needleShape = "straight"
        compare(gauge.needleShape, "straight", "Straight needle")

        gauge.needlePivotWidth = 6
        gauge.needleTipWidth = 1
        compare(gauge.needlePivotWidth, 6, "Needle pivot width")
        compare(gauge.needleTipWidth, 1, "Needle tip width")
    }

    function test_colorScheme() {
        gauge.faceColor = "#1a1a1a"
        gauge.needleColor = "#ff6600"
        gauge.tickColor = "#888888"

        compare(gauge.faceColor.toString(), "#1a1a1a", "Face color")
        compare(gauge.needleColor.toString(), "#ff6600", "Needle color")
        compare(gauge.tickColor.toString(), "#888888", "Tick color")
    }
}
