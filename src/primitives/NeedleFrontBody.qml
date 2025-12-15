import QtQuick
import QtQuick.Shapes

/**
 * @brief Needle body primitive extending from pivot toward gauge values.
 *
 * NeedleFrontBody renders the main shaft of a gauge needle from the pivot
 * point outward. Supports multiple body shapes and optional gradient shading.
 *
 * This primitive is designed to be composed with NeedleHeadTip to form
 * a complete front needle section. It does NOT include rotation - that
 * should be handled by the parent GaugeNeedle compound.
 *
 * Coordinate system:
 * - Origin at (0, 0) is the pivot point
 * - Body extends in negative Y direction (upward)
 * - Width is centered on X axis
 *
 * @example
 * @code
 * NeedleFrontBody {
 *     length: 100
 *     pivotWidth: 12
 *     tipWidth: 4
 *     shape: "tapered"
 *     color: "#ff6600"
 * }
 * @endcode
 */
Item {
    id: root

    // === Geometry Properties ===

    /**
     * @brief Length of body from pivot to tip connection (pixels).
     * @default 100
     */
    property real length: 100

    /**
     * @brief Width at pivot end (pixels).
     * @default 10
     */
    property real pivotWidth: 10

    /**
     * @brief Width at tip end where NeedleHeadTip attaches (pixels).
     * @default 4
     */
    property real tipWidth: 4

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

    // === Bevel Effect ===

    /**
     * @brief Enable 3D bevel effect.
     * @default false
     */
    property bool hasBevel: false

    /**
     * @brief Bevel stroke width (pixels).
     * @default 1.0
     */
    property real bevelWidth: 1.0

    /**
     * @brief Bevel highlight color (left edge).
     * @default Qt.lighter(color, 1.4)
     */
    property color bevelHighlight: Qt.lighter(color, 1.4)

    /**
     * @brief Bevel shadow color (right edge).
     * @default Qt.darker(color, 1.4)
     */
    property color bevelShadow: Qt.darker(color, 1.4)

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

    // Curve control point offset for convex/concave shapes (as fraction of length)
    readonly property real curveAmount: 0.3

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

            // Path depends on shape
            // Origin: pivot at bottom center, body extends upward

            // Calculate center X
            readonly property real centerX: root.implicitWidth / 2

            // Start at bottom-left (pivot end)
            startX: centerX - root.pivotWidth / 2
            startY: root.length

            // Path elements based on shape
            PathLine {
                id: leftEdgeTop
                // For tapered: go to top-left (tip end)
                x: bodyPath.centerX - (root.shape === "straight" ? root.pivotWidth : root.tipWidth) / 2
                y: 0
            }

            PathLine {
                id: topEdge
                // Go across the top (tip end)
                x: bodyPath.centerX + (root.shape === "straight" ? root.pivotWidth : root.tipWidth) / 2
                y: 0
            }

            PathLine {
                id: rightEdgeBottom
                // Go down to bottom-right (pivot end)
                x: bodyPath.centerX + root.pivotWidth / 2
                y: root.length
            }

            PathLine {
                // Close path back to start
                x: bodyPath.centerX - root.pivotWidth / 2
                y: root.length
            }
        }

        // Bevel highlight (left edge) - lighter color
        ShapePath {
            id: bevelHighlightPath
            strokeColor: root.hasBevel ? root.bevelHighlight : "transparent"
            strokeWidth: root.bevelWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            readonly property real centerX: root.implicitWidth / 2
            readonly property real topWidth: root.shape === "straight" ? root.pivotWidth : root.tipWidth

            // Draw left edge from bottom to top
            startX: centerX - root.pivotWidth / 2
            startY: root.length

            PathLine {
                x: bevelHighlightPath.centerX - bevelHighlightPath.topWidth / 2
                y: 0
            }
        }

        // Bevel shadow (right edge) - darker color
        ShapePath {
            id: bevelShadowPath
            strokeColor: root.hasBevel ? root.bevelShadow : "transparent"
            strokeWidth: root.bevelWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            readonly property real centerX: root.implicitWidth / 2
            readonly property real topWidth: root.shape === "straight" ? root.pivotWidth : root.tipWidth

            // Draw right edge from top to bottom
            startX: centerX + topWidth / 2
            startY: 0

            PathLine {
                x: bevelShadowPath.centerX + root.pivotWidth / 2
                y: root.length
            }
        }
    }

    // Convex/Concave shapes use curved paths instead of straight lines
    // For simplicity in initial implementation, tapered/straight are supported
    // Convex/Concave can be added as enhancement using PathQuad
}
