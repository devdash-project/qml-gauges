import QtQuick
import QtQuick.Effects

/**
 * @brief Atomic tick label primitive for gauge scales.
 *
 * GaugeTickLabel renders a single text label at a specified angle,
 * with automatic rotation to keep text upright and readable.
 *
 * Supports value formatting (precision, divisor, prefix/suffix).
 *
 * @example
 * @code
 * GaugeTickLabel {
 *     angle: 45
 *     distanceFromCenter: 120
 *     text: "4"
 *     fontSize: 18
 *     color: "#ffffff"
 * }
 * @endcode
 */
Item {
    id: root

    // === Position Properties ===

    /**
     * @brief Rotation angle in degrees (0 = 3 o'clock).
     * @default 0
     */
    property real angle: 0

    /**
     * @brief Distance from gauge center to label center (pixels).
     * @default 80
     */
    property real distanceFromCenter: 80

    // === Content Properties ===

    /**
     * @brief Display text.
     *
     * Can be set directly or auto-generated from `value`.
     *
     * @default "0"
     */
    property string text: "0"

    /**
     * @brief Numeric value (for formatting).
     *
     * When set, text is auto-generated using precision, divisor, etc.
     *
     * @default 0
     */
    property real value: 0

    /**
     * @brief Decimal places for value formatting.
     * @default 0 (integer)
     */
    property int precision: 0

    /**
     * @brief Divide value by this before display.
     *
     * Useful for showing "8" instead of "8000" on RPM gauge.
     *
     * @default 1 (no division)
     */
    property real divisor: 1

    /**
     * @brief Text prefix (e.g., "$", "+").
     * @default ""
     */
    property string prefix: ""

    /**
     * @brief Text suffix (e.g., "k", "°", "%").
     * @default ""
     */
    property string suffix: ""

    // === Typography Properties ===

    /**
     * @brief Font family.
     * @default "sans-serif"
     */
    property string fontFamily: "sans-serif"

    /**
     * @brief Font size in pixels.
     * @default 18
     */
    property int fontSize: 18

    /**
     * @brief Font weight.
     * @default Font.Bold
     */
    property int fontWeight: Font.Bold

    /**
     * @brief Text color.
     * @default "#888888"
     */
    property color color: "#888888"

    /**
     * @brief Enable text outline/stroke.
     *
     * Creates a border around text for better visibility.
     * Classic gauge aesthetic.
     *
     * @default false
     */
    property bool showOutline: false

    /**
     * @brief Outline color.
     * @default "#000000" (black)
     */
    property color outlineColor: "#000000"

    // === Form-shading Properties ===
    //
    // Form shading simulates a directional light hitting a slightly raised
    // painted glyph. The base text is rendered as usual; a MultiEffect
    // shadow is added behind it, offset away from the (notional) light
    // source. With a small offset and a soft blur the result reads as
    // "painted with depth" rather than "duplicated text" — the opposite
    // visual goal of a regular drop shadow, which intentionally separates
    // the glyph from the background.

    /**
     * @brief Apply a directional shadow that reads as paint depth.
     *
     * When true, the label gains a soft offset shadow whose direction is
     * controlled by `lightAngle` and whose strength by `formShadingIntensity`.
     * @default false
     */
    property bool hasFormShading: false

    /**
     * @brief How pronounced the form shading is, in [0, 1].
     *
     * Drives shadow alpha *and* shadow offset magnitude: low values produce
     * a faint dimensionality cue, high values an overtly raised look. Above
     * about 0.7 the shadow stops reading as depth and starts reading as a
     * duplicate glyph.
     * @default 0.4
     */
    property real formShadingIntensity: 0.4

    /**
     * @brief Direction of the simulated light, in degrees.
     *
     * 0° = light from the right, -90° = light from above. Default of -45°
     * = light from upper-left, which is the conventional drawing convention.
     * The shadow is cast in the opposite direction.
     * @default -45
     */
    property real lightAngle: -45

    /**
     * @brief Shadow color used by form shading.
     *
     * Defaults to a darkened version of the text colour, which keeps the
     * shading hue-consistent with the glyph (the painted-paint look). Set
     * explicitly to override (e.g., a fixed deep tone independent of text
     * colour).
     * @default Qt.darker(color, 1.8) with reduced alpha
     */
    property color formShadingColor: Qt.darker(root.color, 1.8)

    // === Behavior Properties ===

    /**
     * @brief Keep text upright regardless of gauge rotation.
     *
     * When true, text rotates to remain readable.
     * When false, text rotates with gauge.
     *
     * @default true
     */
    property bool keepUpright: true

    // === Internal Implementation ===

    implicitWidth: distanceFromCenter * 2
    implicitHeight: distanceFromCenter * 2

    // Formatted text (if using value instead of text)
    readonly property string displayText: {
        if (text !== "0" || value === 0) {
            return prefix + text + suffix
        }
        var formatted = (value / divisor).toFixed(precision)
        return prefix + formatted + suffix
    }

    // Shadow offset vector derived from lightAngle + intensity. Magnitude
    // scales with font size so the depth cue looks proportional at any size.
    readonly property real _shadowMagnitude: root.fontSize * 0.08 * root.formShadingIntensity
    readonly property real _shadowDx: -Math.cos(root.lightAngle * Math.PI / 180) * _shadowMagnitude
    readonly property real _shadowDy: -Math.sin(root.lightAngle * Math.PI / 180) * _shadowMagnitude

    Text {
        id: label
        text: root.displayText
        font.family: root.fontFamily
        font.pixelSize: root.fontSize
        font.weight: root.fontWeight
        color: root.color

        // Text outline for classic gauge aesthetic
        style: root.showOutline ? Text.Outline : Text.Normal
        styleColor: root.outlineColor

        // Position at specified radius from center
        // Convert from gauge angle convention (0° = 12 o'clock, clockwise positive)
        // to standard trig (0° = 3 o'clock), by subtracting 90°
        readonly property real trigAngle: (root.angle - 90) * Math.PI / 180
        x: (parent.width / 2) + (root.distanceFromCenter * Math.cos(trigAngle)) - (width / 2)
        y: (parent.height / 2) + (root.distanceFromCenter * Math.sin(trigAngle)) - (height / 2)

        // Rotate to keep upright (if enabled)
        // When keepUpright is true, text stays horizontal (no rotation)
        // When false, text rotates tangent to the gauge arc
        rotation: root.keepUpright ? 0 : root.angle

        // Form-shading: a soft directional drop-shadow applied via MultiEffect
        // when hasFormShading is set. layer.enabled must be true for the
        // effect to attach — Qt's MultiEffect operates on the rasterised
        // texture of the source item, so the Text glyphs need a layer.
        // smooth: true keeps the rasterisation crisp on high-DPI displays.
        layer.enabled: root.hasFormShading
        layer.smooth: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: root.formShadingColor
            shadowHorizontalOffset: root._shadowDx
            shadowVerticalOffset: root._shadowDy
            shadowBlur: 0.6
            shadowOpacity: Math.min(1.0, root.formShadingIntensity * 1.5)
        }
    }
}
