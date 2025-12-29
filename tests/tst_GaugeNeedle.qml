import QtQuick
import QtTest
import DevDash.Gauges.Primitives 1.0

/**
 * @brief Unit tests for needle primitive components
 *
 * Tests the atomic needle parts: NeedleFrontBody, NeedleRearBody,
 * NeedleHeadTip, NeedleTailTip
 */
TestCase {
    id: testCase
    name: "NeedlePrimitiveTests"
    when: windowShown

    width: 400
    height: 400

    // Test front body (main needle portion)
    NeedleFrontBody {
        id: frontBody
        x: 200
        y: 200
        length: 100
        pivotWidth: 8
        tipWidth: 2
        shape: "tapered"
        color: "#ff6600"
    }

    // Test rear body (counterweight portion)
    NeedleRearBody {
        id: rearBody
        x: 200
        y: 200
        visible: false
        length: 30
        pivotWidth: 8
        tipWidth: 4
        shape: "tapered"
        color: "#333333"
    }

    // Test head tip
    NeedleHeadTip {
        id: headTip
        x: 200
        y: 100
        visible: false
        shape: "pointed"
        baseWidth: 2
        length: 10
        color: "#ff6600"
    }

    function test_frontBody_defaultProperties() {
        compare(frontBody.length, 100, "Default length")
        compare(frontBody.pivotWidth, 8, "Pivot width")
        compare(frontBody.tipWidth, 2, "Tip width")
        compare(frontBody.shape, "tapered", "Shape")
    }

    function test_frontBody_shapes() {
        frontBody.shape = "tapered"
        compare(frontBody.shape, "tapered", "Tapered shape")

        frontBody.shape = "straight"
        compare(frontBody.shape, "straight", "Straight shape")

        // Reset
        frontBody.shape = "tapered"
    }

    function test_frontBody_color() {
        frontBody.color = "#00ff00"
        compare(frontBody.color.toString(), "#00ff00", "Color change")

        // Reset
        frontBody.color = "#ff6600"
    }

    function test_rearBody_properties() {
        compare(rearBody.length, 30, "Rear length")
        compare(rearBody.pivotWidth, 8, "Pivot width")
        compare(rearBody.tipWidth, 4, "Tip width")
    }

    function test_headTip_shapes() {
        headTip.shape = "pointed"
        compare(headTip.shape, "pointed", "Pointed shape")

        headTip.shape = "arrow"
        compare(headTip.shape, "arrow", "Arrow shape")

        headTip.shape = "rounded"
        compare(headTip.shape, "rounded", "Rounded shape")

        headTip.shape = "flat"
        compare(headTip.shape, "flat", "Flat shape")

        headTip.shape = "diamond"
        compare(headTip.shape, "diamond", "Diamond shape")

        // Reset
        headTip.shape = "pointed"
    }

    function test_headTip_dimensions() {
        headTip.baseWidth = 4
        headTip.length = 15
        compare(headTip.baseWidth, 4, "Base width")
        compare(headTip.length, 15, "Length")

        // Reset
        headTip.baseWidth = 2
        headTip.length = 10
    }
}
