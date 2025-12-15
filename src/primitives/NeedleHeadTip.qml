import QtQuick
import QtQuick.Shapes

/**
 * @brief Decorative tip shape for the front end of a gauge needle.
 *
 * NeedleHeadTip renders decorative tip shapes that attach to the front
 * end of NeedleFrontBody. Supports multiple tip styles including pointed,
 * arrow, rounded, and flat.
 *
 * Coordinate system:
 * - Origin at (0, 0) is where the tip attaches to body
 * - Tip extends in negative Y direction (upward)
 * - Width at origin matches the body's tipWidth
 *
 * @example
 * @code
 * NeedleHeadTip {
 *     shape: "pointed"
 *     baseWidth: 4
 *     length: 8
 *     color: "#ff6600"
 * }
 * @endcode
 */
Item {
    id: root

    // === Geometry Properties ===

    /**
     * @brief Tip shape style.
     *
     * Supported shapes:
     * - "none": No tip rendered (body ends flat)
     * - "pointed": Sharp triangular point
     * - "arrow": Open arrow/V-notch outline
     * - "rounded": Rounded/blunt end
     * - "flat": Flat rectangular cap
     * - "diamond": Diamond/rhombus shape
     *
     * @default "pointed"
     */
    property string shape: "pointed"

    /**
     * @brief Width at base where tip attaches to body (pixels).
     * Should match NeedleFrontBody.tipWidth.
     * @default 4
     */
    property real baseWidth: 4

    /**
     * @brief Length of tip from base to point (pixels).
     * Set to 0 for auto-calculation based on baseWidth.
     * @default 0 (auto)
     */
    property real length: 0

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

    // Calculate actual length (auto or explicit)
    readonly property real actualLength: length > 0 ? length : baseWidth * 2

    // Size to contain the tip shape
    implicitWidth: shape === "arrow" || shape === "diamond" ? baseWidth * 1.5 : baseWidth
    implicitHeight: actualLength

    // Don't render if shape is "none"
    visible: shape !== "none"

    // Pointed tip: simple triangle to a point
    Loader {
        active: root.shape === "pointed"
        anchors.fill: parent

        sourceComponent: Item {
            LinearGradient {
                id: pointedGradient
                x1: 0
                y1: root.actualLength / 2
                x2: root.implicitWidth
                y2: root.actualLength / 2
                GradientStop { position: 0.0; color: root.gradientHighlight }
                GradientStop { position: 0.4; color: root.color }
                GradientStop { position: 1.0; color: root.gradientShadow }
            }

            Shape {
                anchors.fill: parent
                antialiasing: root.antialiasing
                preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
                    ? Shape.CurveRenderer : Shape.GeometryRenderer

                ShapePath {
                    id: pointedPath
                    strokeColor: root.borderWidth > 0 ? root.borderColor : "transparent"
                    strokeWidth: root.borderWidth
                    fillColor: root.hasGradient ? "transparent" : root.color
                    fillGradient: root.hasGradient ? pointedGradient : null

                    readonly property real cx: root.implicitWidth / 2

                    // Triangle from base to point
                    startX: cx - root.baseWidth / 2
                    startY: root.actualLength

                    PathLine { x: pointedPath.cx; y: 0 }  // To point
                    PathLine { x: pointedPath.cx + root.baseWidth / 2; y: root.actualLength }  // To right corner
                    PathLine { x: pointedPath.cx - root.baseWidth / 2; y: root.actualLength }  // Close
                }

                // Bevel highlight (left edge to point)
                ShapePath {
                    strokeColor: root.hasBevel ? root.bevelHighlight : "transparent"
                    strokeWidth: root.bevelWidth
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap

                    readonly property real cx: root.implicitWidth / 2

                    startX: cx - root.baseWidth / 2
                    startY: root.actualLength

                    PathLine { x: cx; y: 0 }
                }

                // Bevel shadow (right edge from point)
                ShapePath {
                    strokeColor: root.hasBevel ? root.bevelShadow : "transparent"
                    strokeWidth: root.bevelWidth
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap

                    readonly property real cx: root.implicitWidth / 2

                    startX: cx
                    startY: 0

                    PathLine { x: cx + root.baseWidth / 2; y: root.actualLength }
                }
            }
        }
    }

    // Rounded tip: tapered with arc at end
    Loader {
        active: root.shape === "rounded"
        anchors.fill: parent

        sourceComponent: Item {
            LinearGradient {
                id: roundedGradient
                x1: 0
                y1: root.actualLength / 2
                x2: root.implicitWidth
                y2: root.actualLength / 2
                GradientStop { position: 0.0; color: root.gradientHighlight }
                GradientStop { position: 0.4; color: root.color }
                GradientStop { position: 1.0; color: root.gradientShadow }
            }

            Shape {
                anchors.fill: parent
                antialiasing: root.antialiasing
                preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
                    ? Shape.CurveRenderer : Shape.GeometryRenderer

                ShapePath {
                    id: roundedPath
                    strokeColor: root.borderWidth > 0 ? root.borderColor : "transparent"
                    strokeWidth: root.borderWidth
                    fillColor: root.hasGradient ? "transparent" : root.color
                    fillGradient: root.hasGradient ? roundedGradient : null

                    readonly property real cx: root.implicitWidth / 2
                    readonly property real tipRadius: root.baseWidth / 2

                    // Rectangle with semicircle cap
                    startX: cx - root.baseWidth / 2
                    startY: root.actualLength

                    PathLine { x: roundedPath.cx - root.baseWidth / 2; y: roundedPath.tipRadius }  // Up left edge
                    PathArc {
                        x: roundedPath.cx + root.baseWidth / 2
                        y: roundedPath.tipRadius
                        radiusX: roundedPath.tipRadius
                        radiusY: roundedPath.tipRadius
                    }
                    PathLine { x: roundedPath.cx + root.baseWidth / 2; y: root.actualLength }  // Down right edge
                    PathLine { x: roundedPath.cx - root.baseWidth / 2; y: root.actualLength }  // Close
                }
            }
        }
    }

    // Flat tip: simple rectangle cap
    Loader {
        active: root.shape === "flat"
        anchors.fill: parent

        sourceComponent: Rectangle {
            width: root.baseWidth
            height: root.actualLength
            x: (root.implicitWidth - root.baseWidth) / 2
            color: root.color
            border.width: root.borderWidth
            border.color: root.borderColor
            antialiasing: root.antialiasing
        }
    }

    // Arrow tip: V-notched arrow head
    Loader {
        active: root.shape === "arrow"
        anchors.fill: parent

        sourceComponent: Item {
            LinearGradient {
                id: arrowGradient
                x1: 0
                y1: root.actualLength / 2
                x2: root.implicitWidth
                y2: root.actualLength / 2
                GradientStop { position: 0.0; color: root.gradientHighlight }
                GradientStop { position: 0.4; color: root.color }
                GradientStop { position: 1.0; color: root.gradientShadow }
            }

            Shape {
                anchors.fill: parent
                antialiasing: root.antialiasing
                preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
                    ? Shape.CurveRenderer : Shape.GeometryRenderer

                ShapePath {
                    id: arrowPath
                    strokeColor: root.borderWidth > 0 ? root.borderColor : "transparent"
                    strokeWidth: root.borderWidth
                    fillColor: root.hasGradient ? "transparent" : root.color
                    fillGradient: root.hasGradient ? arrowGradient : null

                    readonly property real cx: root.implicitWidth / 2
                    readonly property real arrowWidth: root.baseWidth * 1.5
                    readonly property real notchDepth: root.actualLength * 0.3

                    // Arrow shape with V notch
                    startX: arrowPath.cx - root.baseWidth / 2
                    startY: root.actualLength

                    // Left edge to outer arrow point
                    PathLine { x: arrowPath.cx - arrowPath.arrowWidth / 2; y: arrowPath.notchDepth }
                    // To tip
                    PathLine { x: arrowPath.cx; y: 0 }
                    // To right outer arrow point
                    PathLine { x: arrowPath.cx + arrowPath.arrowWidth / 2; y: arrowPath.notchDepth }
                    // Right edge down
                    PathLine { x: arrowPath.cx + root.baseWidth / 2; y: root.actualLength }
                    // Close
                    PathLine { x: arrowPath.cx - root.baseWidth / 2; y: root.actualLength }
                }
            }
        }
    }

    // Diamond tip: rhombus shape
    Loader {
        active: root.shape === "diamond"
        anchors.fill: parent

        sourceComponent: Item {
            LinearGradient {
                id: diamondGradient
                x1: 0
                y1: root.actualLength / 2
                x2: root.implicitWidth
                y2: root.actualLength / 2
                GradientStop { position: 0.0; color: root.gradientHighlight }
                GradientStop { position: 0.4; color: root.color }
                GradientStop { position: 1.0; color: root.gradientShadow }
            }

            Shape {
                anchors.fill: parent
                antialiasing: root.antialiasing
                preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
                    ? Shape.CurveRenderer : Shape.GeometryRenderer

                ShapePath {
                    id: diamondPath
                    strokeColor: root.borderWidth > 0 ? root.borderColor : "transparent"
                    strokeWidth: root.borderWidth
                    fillColor: root.hasGradient ? "transparent" : root.color
                    fillGradient: root.hasGradient ? diamondGradient : null

                    readonly property real cx: root.implicitWidth / 2
                    readonly property real diamondWidth: root.baseWidth * 1.2

                    // Diamond/rhombus
                    startX: diamondPath.cx - root.baseWidth / 2
                    startY: root.actualLength

                    // To left point (widest)
                    PathLine { x: diamondPath.cx - diamondPath.diamondWidth / 2; y: root.actualLength / 2 }
                    // To top point
                    PathLine { x: diamondPath.cx; y: 0 }
                    // To right point (widest)
                    PathLine { x: diamondPath.cx + diamondPath.diamondWidth / 2; y: root.actualLength / 2 }
                    // To base right
                    PathLine { x: diamondPath.cx + root.baseWidth / 2; y: root.actualLength }
                    // Close
                    PathLine { x: diamondPath.cx - root.baseWidth / 2; y: root.actualLength }
                }
            }
        }
    }
}
