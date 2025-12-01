import QtQuick
import QtQuick.Shapes

/**
 * @brief Classic Instruments Velocity style needle with 3D gradient shading.
 *
 * Inspired by Classic Instruments Velocity gauges:
 * @see https://shop.classicinstruments.com/velocity-white-3-38-speedometer
 *
 * GaugeNeedleVelocity renders a wide tapered needle with:
 * - Linear gradient across width for 3D beveled appearance
 * - Dark outline stroke for definition
 * - Tail extension past pivot point
 * - Optional circular hub with drop shadow
 * - Configurable lighting direction
 *
 * @example
 * @code
 * GaugeNeedleVelocity {
 *     angle: 45
 *     length: 120
 *     color: "#ff6600"
 *     tailLength: 20
 * }
 * @endcode
 */
Item {
    id: root

    // === Rotation Properties ===

    /**
     * @brief Current rotation angle in degrees (0 = 12 o'clock / up).
     */
    property real angle: 0

    // === Geometry Properties ===

    /**
     * @brief Length of needle from pivot to tip (pixels).
     * @default 100
     */
    property real length: 100

    /**
     * @brief Width of needle at base near pivot (pixels).
     * @default 12
     */
    property real needleWidth: 12

    /**
     * @brief Length of tail extending past pivot point (pixels).
     * Set to 0 for no tail, or ~15-20% of length for classic look.
     * @default 20
     */
    property real tailLength: 20

    // === Hub Properties ===

    /**
     * @brief Radius of circular hub at pivot point (pixels).
     * Set to 0 to disable hub and show only tapered needle.
     * @default 0
     */
    property real hubRadius: 0

    /**
     * @brief Enable drop shadow under hub.
     * @default true
     */
    property bool hubShadow: true

    /**
     * @brief Shadow offset in pixels.
     * @default 3
     */
    property real shadowOffset: 3

    // === Color Properties ===

    /**
     * @brief Base needle color.
     * @default "#ff6600" (orange)
     */
    property color color: "#ff6600"

    /**
     * @brief Outline/stroke color.
     * @default "#1a1a1a" (near black)
     */
    property color outlineColor: "#1a1a1a"

    /**
     * @brief Outline stroke width in pixels.
     * @default 1.5
     */
    property real outlineWidth: 1.5

    // === Lighting Properties ===

    /**
     * @brief Light source angle in degrees (0=right, -45=upper-left).
     * Affects gradient direction for 3D appearance.
     * @default -45
     */
    property real lightAngle: -45

    /**
     * @brief Intensity of highlight (lighter edge). Range 1.0-2.0.
     * @default 1.3
     */
    property real highlightIntensity: 1.3

    /**
     * @brief Intensity of shadow (darker edge). Range 1.0-2.0.
     * @default 1.3
     */
    property real shadowIntensity: 1.3

    // === Animation Properties ===

    /**
     * @brief Enable SpringAnimation for rotation.
     * @default true
     */
    property bool animated: true

    /**
     * @brief Spring stiffness.
     * @default 3.5
     */
    property real spring: 3.5

    /**
     * @brief Damping factor.
     * @default 0.25
     */
    property real damping: 0.25

    /**
     * @brief Mass for spring animation.
     * @default 1.0
     */
    property real mass: 1.0

    /**
     * @brief Epsilon threshold for animation.
     * @default 0.25
     */
    property real epsilon: 0.25

    // === Advanced ===

    /**
     * @brief Enable antialiasing.
     * @default true
     */
    property bool antialiasing: true

    // === Internal Implementation ===

    implicitWidth: Math.max(length + tailLength, hubRadius * 2) * 2
    implicitHeight: Math.max(length + tailLength, hubRadius * 2) * 2

    // Calculate center point
    readonly property real centerX: width / 2
    readonly property real centerY: height / 2

    // Calculate gradient colors based on base color
    readonly property color highlightColor: Qt.lighter(color, highlightIntensity)
    readonly property color shadowColor_: Qt.darker(color, shadowIntensity)

    // Hub shadow (rendered first, behind everything)
    Rectangle {
        id: hubShadowRect
        visible: root.hubRadius > 0 && root.hubShadow
        x: root.centerX - root.hubRadius + root.shadowOffset
        y: root.centerY - root.hubRadius + root.shadowOffset
        width: root.hubRadius * 2
        height: root.hubRadius * 2
        radius: root.hubRadius
        color: Qt.rgba(0, 0, 0, 0.35)
    }

    // Main needle shape with gradient
    Shape {
        id: needleShape
        anchors.fill: parent
        antialiasing: root.antialiasing

        // Use CurveRenderer for smooth edges (Qt 6.6+)
        preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
            ? Shape.CurveRenderer : Shape.GeometryRenderer

        transform: Rotation {
            origin.x: root.centerX
            origin.y: root.centerY
            angle: root.angle

            Behavior on angle {
                enabled: root.animated
                SpringAnimation {
                    spring: root.spring
                    damping: root.damping
                    mass: root.mass
                    epsilon: root.epsilon
                }
            }
        }

        ShapePath {
            id: needlePath
            strokeColor: root.outlineColor
            strokeWidth: root.outlineWidth
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            // Linear gradient perpendicular to needle for 3D bevel effect
            fillGradient: LinearGradient {
                // Gradient runs horizontally across the needle width
                x1: root.centerX - root.needleWidth / 2
                y1: root.centerY
                x2: root.centerX + root.needleWidth / 2
                y2: root.centerY

                GradientStop { position: 0.0; color: root.highlightColor }
                GradientStop { position: 0.4; color: root.color }
                GradientStop { position: 1.0; color: root.shadowColor_ }
            }

            // Needle path: simple elongated triangle
            // Wide flat tail -> pointed tip -> back to tail
            // Starting at tail left corner
            startX: root.centerX - root.needleWidth / 2
            startY: root.centerY + root.tailLength

            // Pointed front tip (straight line from tail to tip)
            PathLine {
                x: root.centerX
                y: root.centerY - root.length
            }
            // Tail right corner (straight line from tip to tail)
            PathLine {
                x: root.centerX + root.needleWidth / 2
                y: root.centerY + root.tailLength
            }
            // Close path (flat tail bottom)
            PathLine {
                x: root.centerX - root.needleWidth / 2
                y: root.centerY + root.tailLength
            }
        }
    }

    // Hub circle with gradient (if enabled)
    Shape {
        id: hubShape
        visible: root.hubRadius > 0
        anchors.fill: parent
        antialiasing: root.antialiasing

        ShapePath {
            strokeColor: root.outlineColor
            strokeWidth: root.outlineWidth

            // Radial gradient for 3D sphere effect on hub
            fillGradient: RadialGradient {
                // Offset center toward light source for highlight
                centerX: root.centerX - root.hubRadius * 0.2
                centerY: root.centerY - root.hubRadius * 0.2
                focalX: root.centerX - root.hubRadius * 0.3
                focalY: root.centerY - root.hubRadius * 0.3
                centerRadius: root.hubRadius * 1.2

                GradientStop { position: 0.0; color: root.highlightColor }
                GradientStop { position: 0.5; color: root.color }
                GradientStop { position: 1.0; color: root.shadowColor_ }
            }

            // Draw circle using arc
            PathAngleArc {
                centerX: root.centerX
                centerY: root.centerY
                radiusX: root.hubRadius
                radiusY: root.hubRadius
                startAngle: 0
                sweepAngle: 360
            }
        }
    }

    // Hub highlight reflection (small bright spot)
    Rectangle {
        id: hubHighlight
        visible: root.hubRadius > 8  // Only show on larger hubs
        x: root.centerX - root.hubRadius * 0.5
        y: root.centerY - root.hubRadius * 0.5
        width: root.hubRadius * 0.4
        height: root.hubRadius * 0.3
        radius: height / 2
        color: Qt.rgba(1, 1, 1, 0.3)
        rotation: -30
    }
}
