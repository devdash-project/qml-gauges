import QtQuick
import QtTest
import DevDash.Gauges.Compounds 1.0

/**
 * @brief Unit tests for the GaugeNeedle compound component
 *
 * These tests verify animation behavior to catch issues like:
 * - Behavior not intercepting binding updates (requires explicit animation)
 * - Animation properties (spring, damping) being applied correctly
 * - Animation enable/disable working properly
 */
TestCase {
    id: testCase
    name: "GaugeNeedleCompoundTests"
    when: windowShown

    width: 400
    height: 400

    // Test needle with animation enabled (default)
    GaugeNeedle {
        id: animatedNeedle
        anchors.centerIn: parent
        width: 300
        height: 300
        angle: 0
        animated: true
        frontLength: 100
        frontColor: "#ff6600"
    }

    // Test needle with animation disabled
    GaugeNeedle {
        id: staticNeedle
        anchors.centerIn: parent
        width: 300
        height: 300
        visible: false
        angle: 0
        animated: false
        frontLength: 100
        frontColor: "#00ff00"
    }

    function init() {
        // Reset needles before each test
        animatedNeedle.animated = true
        animatedNeedle.spring = 3.5
        animatedNeedle.damping = 0.25
        animatedNeedle.angle = 0
        staticNeedle.animated = false
        staticNeedle.angle = 0
        wait(200)  // Let animations settle
    }

    // =========================================================================
    // Animation Interpolation Tests
    // =========================================================================

    function test_animation_interpolates() {
        // This test catches the bug where Behavior doesn't work with bindings
        // The _displayAngle should animate gradually, not jump instantly

        animatedNeedle.angle = 0
        wait(100)  // Let it settle

        // Set a new angle
        animatedNeedle.angle = 90

        // Wait a short time - less than animation would take to complete
        wait(30)

        // _displayAngle should be between 0 and 90 (animation in progress)
        // If it jumped instantly to 90, the animation is broken
        verify(animatedNeedle._displayAngle >= 0,
               "Animation should have started (displayAngle >= 0)")
        verify(animatedNeedle._displayAngle < 90,
               "Animation should not have completed yet (displayAngle < 90), got: " +
               animatedNeedle._displayAngle)

        // Wait for animation to complete
        wait(500)
        fuzzyCompare(animatedNeedle._displayAngle, 90, 0.5,
                     "Animation should complete at target angle")
    }

    function test_animation_disabled_jumps_instantly() {
        // When animated=false, angle changes should be instant

        staticNeedle.angle = 0
        wait(50)

        staticNeedle.angle = 45
        wait(10)  // Very short wait

        // Should have jumped immediately
        compare(staticNeedle._displayAngle, 45,
                "With animation disabled, displayAngle should jump instantly")
    }

    function test_animation_toggle() {
        // Test that toggling animated property works correctly

        animatedNeedle.angle = 0
        wait(100)

        // Disable animation
        animatedNeedle.animated = false
        animatedNeedle.angle = 60
        wait(10)
        compare(animatedNeedle._displayAngle, 60,
                "Should jump when animation disabled")

        // Re-enable animation
        animatedNeedle.animated = true
        animatedNeedle.angle = 120
        wait(30)
        verify(animatedNeedle._displayAngle < 120,
               "Should animate when animation re-enabled")
    }

    function test_animation_direction_positive() {
        // Test animation works for positive angle changes

        animatedNeedle.angle = 0
        wait(100)

        animatedNeedle.angle = 45
        wait(30)

        verify(animatedNeedle._displayAngle > 0,
               "Should be animating toward positive angle")
        verify(animatedNeedle._displayAngle < 45,
               "Should not have reached target yet")
    }

    function test_animation_direction_negative() {
        // Test animation works for negative angle changes

        animatedNeedle.angle = 90
        wait(500)  // Let it reach 90

        animatedNeedle.angle = 0
        wait(30)

        verify(animatedNeedle._displayAngle < 90,
               "Should be animating toward 0")
        verify(animatedNeedle._displayAngle > 0,
               "Should not have reached 0 yet")
    }

    // =========================================================================
    // Spring Animation Parameter Tests
    // =========================================================================

    function test_spring_parameter_affects_speed() {
        // Higher spring value = faster animation

        // Test with low spring (slower)
        animatedNeedle.spring = 1.0
        animatedNeedle.angle = 0
        wait(200)

        animatedNeedle.angle = 90
        wait(50)
        var lowSpringProgress = animatedNeedle._displayAngle

        // Reset
        animatedNeedle.angle = 0
        wait(500)

        // Test with high spring (faster)
        animatedNeedle.spring = 8.0
        animatedNeedle.angle = 90
        wait(50)
        var highSpringProgress = animatedNeedle._displayAngle

        verify(highSpringProgress > lowSpringProgress,
               "Higher spring should animate faster. Low: " + lowSpringProgress +
               ", High: " + highSpringProgress)

        // Reset to default
        animatedNeedle.spring = 3.5
    }

    // =========================================================================
    // Property Tests
    // =========================================================================

    function test_default_properties() {
        var needle = animatedNeedle
        compare(needle.animated, true, "Default animated")
        compare(needle.spring, 3.5, "Default spring")
        compare(needle.damping, 0.25, "Default damping")
        compare(needle.mass, 1.0, "Default mass")
    }

    function test_angle_property() {
        animatedNeedle.animated = false  // Disable for instant update

        animatedNeedle.angle = 45
        compare(animatedNeedle.angle, 45, "Angle set to 45")

        animatedNeedle.angle = -135
        compare(animatedNeedle.angle, -135, "Negative angle")

        animatedNeedle.angle = 180
        compare(animatedNeedle.angle, 180, "Half rotation")

        animatedNeedle.animated = true  // Re-enable
    }

    function test_front_body_properties() {
        compare(animatedNeedle.frontLength, 100, "Front length")
        compare(animatedNeedle.frontColor.toString(), "#ff6600", "Front color")

        animatedNeedle.frontShape = "straight"
        compare(animatedNeedle.frontShape, "straight", "Front shape")
        animatedNeedle.frontShape = "tapered"  // Reset
    }
}
