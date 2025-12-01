import QtQuick
import QtQuick.Shapes

/**
 * @brief Needle body primitive extending from pivot backward (counterweight side).
 *
 * NeedleRearBody renders the rear shaft of a gauge needle from the pivot
 * point backward. Supports multiple body shapes and optional gradient shading.
 *
 * This primitive is designed to be composed with NeedleTailTip to form
 * a complete rear needle section. It does NOT include rotation - that
 * should be handled by the parent GaugeNeedle compound.
 *
 * Coordinate system:
 * - Origin at (0, 0) is the pivot point
 * - Body extends in positive Y direction (downward)
 * - Width is centered on X axis
 *
 * @example
 * @code
 * NeedleRearBody {
 *     length: 25
 *     pivotWidth: 12
 *     tipWidth: 8
 *     shape: "tapered"
 *     color: "#333333"
 * }
 * @endcode
 */
Item {
    id: root

    // === Geometry Properties ===

    /**
     * @brief Length of body from pivot to tip connection (pixels).
     * @default 25
     */
    property real length: 25

    /**
     * @brief Width at pivot end (pixels).
     * @default 10
     */
    property real pivotWidth: 10

    /**
     * @brief Width at tip end where NeedleTailTip attaches (pixels).
     * @default 6
     */
    property real tipWidth: 6

    /**
     * @brief Body shape style.
     *
     * Supported shapes:
     * - "tapered": Linear taper from pivotWidth to tipWidth
     * - "straight": Constant width (uses pivotWidth)
     * - "convex": Curved outward (barrel shape)
     * - "concave": Curved inward (hourglass shape)
     *
     * @default "tapered"
     */
    property string shape: "tapered"

    // === Appearance Properties ===

    /**
     * @brief Fill color.
     * @default "#ff6600" (orange)
     */
    property color color: "#ff6600"

    /**
     * @brief Enable gradient shading for 3D effect.
     * @default false
     */
    property bool hasGradient: false

    /**
     * @brief Gradient highlight color (left edge).
     * @default Qt.lighter(color, 1.3)
     */
    property color gradientHighlight: Qt.lighter(color, 1.3)

    /**
     * @brief Gradient shadow color (right edge).
     * @default Qt.darker(color, 1.3)
     */
    property color gradientShadow: Qt.darker(color, 1.3)

    /**
     * @brief Border/stroke width (pixels).
     * @default 0 (no border)
     */
    property real borderWidth: 0

    /**
     * @brief Border/stroke color.
     * @default "transparent"
     */
    property color borderColor: "transparent"

    // === Advanced ===

    /**
     * @brief Enable antialiasing.
     * @default true
     */
    property bool antialiasing: true

    // === Internal Implementation ===

    // Size to contain the body shape
    implicitWidth: Math.max(pivotWidth, tipWidth)
    implicitHeight: length

    // Gradient defined outside ShapePath to avoid pathElements conflict
    LinearGradient {
        id: bodyGradient
        x1: 0
        y1: root.length / 2
        x2: root.implicitWidth
        y2: root.length / 2

        GradientStop { position: 0.0; color: root.gradientHighlight }
        GradientStop { position: 0.4; color: root.color }
        GradientStop { position: 1.0; color: root.gradientShadow }
    }

    Shape {
        id: bodyShape
        anchors.fill: parent
        antialiasing: root.antialiasing

        // Use CurveRenderer for smooth edges (Qt 6.6+)
        preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
            ? Shape.CurveRenderer : Shape.GeometryRenderer

        ShapePath {
            id: bodyPath
            strokeColor: root.borderWidth > 0 ? root.borderColor : "transparent"
            strokeWidth: root.borderWidth
            fillColor: root.hasGradient ? "transparent" : root.color
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            // Gradient across needle width (left=highlight, right=shadow)
            fillGradient: root.hasGradient ? bodyGradient : null

            // Path: pivot at top, body extends downward
            // Calculate center X
            readonly property real centerX: root.implicitWidth / 2

            // Start at top-left (pivot end)
            startX: centerX - root.pivotWidth / 2
            startY: 0

            // Go down left edge to bottom-left (tip end)
            PathLine {
                x: bodyPath.centerX - (root.shape === "straight" ? root.pivotWidth : root.tipWidth) / 2
                y: root.length
            }

            // Go across the bottom (tip end)
            PathLine {
                x: bodyPath.centerX + (root.shape === "straight" ? root.pivotWidth : root.tipWidth) / 2
                y: root.length
            }

            // Go up right edge to top-right (pivot end)
            PathLine {
                x: bodyPath.centerX + root.pivotWidth / 2
                y: 0
            }

            // Close path back to start
            PathLine {
                x: bodyPath.centerX - root.pivotWidth / 2
                y: 0
            }
        }
    }
}
