import QtQuick
import QtQuick.Shapes

/**
 * @brief Decorative tip shape for the rear end of a gauge needle (counterweight area).
 *
 * NeedleTailTip renders decorative tip shapes that attach to the rear
 * end of NeedleRearBody. Supports multiple tail styles including tapered,
 * crescent, counterweight circle, and wedge.
 *
 * Coordinate system:
 * - Origin at (0, 0) is where the tip attaches to body
 * - Tip extends in positive Y direction (downward)
 * - Width at origin matches the body's tipWidth
 *
 * @example
 * @code
 * NeedleTailTip {
 *     shape: "crescent"
 *     baseWidth: 8
 *     length: 15
 *     color: "#333333"
 * }
 * @endcode
 */
Item {
    id: root

    // === Geometry Properties ===

    /**
     * @brief Tail tip shape style.
     *
     * Supported shapes:
     * - "none": No tip rendered
     * - "tapered": Simple tapered point (mirror of front)
     * - "crescent": Crescent moon / wrench shape
     * - "counterweight": Circular dot
     * - "wedge": Wide wedge shape
     * - "flat": Flat rectangular cap
     *
     * @default "none"
     */
    property string shape: "none"

    /**
     * @brief Width at base where tip attaches to body (pixels).
     * Should match NeedleRearBody.tipWidth.
     * @default 6
     */
    property real baseWidth: 6

    /**
     * @brief Length of tip from base to end (pixels).
     * Set to 0 for auto-calculation based on baseWidth.
     * @default 0 (auto)
     */
    property real length: 0

    /**
     * @brief Curve amount for crescent shape (0.0-1.0).
     * Higher values create more pronounced curves.
     * @default 0.5
     */
    property real curveAmount: 0.5

    // === Appearance Properties ===

    /**
     * @brief Fill color.
     * @default "#333333" (dark gray)
     */
    property color color: "#333333"

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

    // Calculate actual length (auto or explicit)
    readonly property real actualLength: length > 0 ? length : baseWidth * 1.5

    // Size to contain the tip shape
    implicitWidth: shape === "crescent" || shape === "wedge"
        ? baseWidth * (1 + curveAmount)
        : shape === "counterweight" ? baseWidth * 1.5 : baseWidth
    implicitHeight: shape === "counterweight" ? baseWidth * 1.5 : actualLength

    // Don't render if shape is "none"
    visible: shape !== "none"

    // Tapered tip: simple triangle to a point (mirror of front)
    Loader {
        active: root.shape === "tapered"
        anchors.fill: parent

        sourceComponent: Item {
            LinearGradient {
                id: taperedGradient
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
                    id: taperedPath
                    strokeColor: root.borderWidth > 0 ? root.borderColor : "transparent"
                    strokeWidth: root.borderWidth
                    fillColor: root.hasGradient ? "transparent" : root.color
                    fillGradient: root.hasGradient ? taperedGradient : null

                    readonly property real cx: root.implicitWidth / 2

                    // Triangle from base to point (downward)
                    startX: taperedPath.cx - root.baseWidth / 2
                    startY: 0

                    PathLine { x: taperedPath.cx; y: root.actualLength }  // To point
                    PathLine { x: taperedPath.cx + root.baseWidth / 2; y: 0 }  // To right corner
                    PathLine { x: taperedPath.cx - root.baseWidth / 2; y: 0 }  // Close
                }
            }
        }
    }

    // Crescent/wrench counterweight shape
    Loader {
        active: root.shape === "crescent"
        anchors.fill: parent

        sourceComponent: Item {
            LinearGradient {
                id: crescentGradient
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
                    id: crescentPath
                    strokeColor: root.borderWidth > 0 ? root.borderColor : "transparent"
                    strokeWidth: root.borderWidth
                    fillColor: root.hasGradient ? "transparent" : root.color
                    fillGradient: root.hasGradient ? crescentGradient : null

                    readonly property real cx: root.implicitWidth / 2
                    readonly property real curveOffset: root.baseWidth * root.curveAmount

                    // Crescent/wrench shape with curved sides
                    startX: crescentPath.cx - root.baseWidth / 2
                    startY: 0

                    // Left side curves outward
                    PathQuad {
                        controlX: crescentPath.cx - root.baseWidth / 2 - crescentPath.curveOffset
                        controlY: root.actualLength * 0.5
                        x: crescentPath.cx - root.baseWidth * 0.3
                        y: root.actualLength
                    }

                    // Bottom curve
                    PathQuad {
                        controlX: crescentPath.cx
                        controlY: root.actualLength + root.baseWidth * 0.3
                        x: crescentPath.cx + root.baseWidth * 0.3
                        y: root.actualLength
                    }

                    // Right side curves outward
                    PathQuad {
                        controlX: crescentPath.cx + root.baseWidth / 2 + crescentPath.curveOffset
                        controlY: root.actualLength * 0.5
                        x: crescentPath.cx + root.baseWidth / 2
                        y: 0
                    }

                    // Close at top
                    PathLine { x: crescentPath.cx - root.baseWidth / 2; y: 0 }
                }
            }
        }
    }

    // Counterweight: circular dot
    Loader {
        active: root.shape === "counterweight"
        anchors.fill: parent

        sourceComponent: Item {
            RadialGradient {
                id: counterweightGradient
                centerX: root.implicitWidth / 2
                centerY: root.implicitHeight / 2
                focalX: root.implicitWidth / 2 - root.baseWidth * 0.2
                focalY: root.implicitHeight / 2 - root.baseWidth * 0.2
                centerRadius: root.baseWidth * 0.75
                GradientStop { position: 0.0; color: root.gradientHighlight }
                GradientStop { position: 0.5; color: root.color }
                GradientStop { position: 1.0; color: root.gradientShadow }
            }

            Shape {
                anchors.fill: parent
                antialiasing: root.antialiasing
                preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
                    ? Shape.CurveRenderer : Shape.GeometryRenderer

                ShapePath {
                    id: counterweightPath
                    strokeColor: root.borderWidth > 0 ? root.borderColor : "transparent"
                    strokeWidth: root.borderWidth
                    fillColor: root.hasGradient ? "transparent" : root.color
                    fillGradient: root.hasGradient ? counterweightGradient : null

                    readonly property real cx: root.implicitWidth / 2
                    readonly property real radius: root.baseWidth * 0.75

                    // Circle via PathAngleArc
                    PathAngleArc {
                        centerX: counterweightPath.cx
                        centerY: root.implicitHeight / 2
                        radiusX: counterweightPath.radius
                        radiusY: counterweightPath.radius
                        startAngle: 0
                        sweepAngle: 360
                    }
                }
            }
        }
    }

    // Wedge: wide triangular shape
    Loader {
        active: root.shape === "wedge"
        anchors.fill: parent

        sourceComponent: Item {
            LinearGradient {
                id: wedgeGradient
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
                    id: wedgePath
                    strokeColor: root.borderWidth > 0 ? root.borderColor : "transparent"
                    strokeWidth: root.borderWidth
                    fillColor: root.hasGradient ? "transparent" : root.color
                    fillGradient: root.hasGradient ? wedgeGradient : null

                    readonly property real cx: root.implicitWidth / 2
                    readonly property real wedgeWidth: root.baseWidth * (1 + root.curveAmount)

                    // Wide wedge
                    startX: wedgePath.cx - root.baseWidth / 2
                    startY: 0

                    PathLine { x: wedgePath.cx - wedgePath.wedgeWidth / 2; y: root.actualLength }  // To left outer corner
                    PathLine { x: wedgePath.cx + wedgePath.wedgeWidth / 2; y: root.actualLength }  // Across bottom
                    PathLine { x: wedgePath.cx + root.baseWidth / 2; y: 0 }  // To right base
                    PathLine { x: wedgePath.cx - root.baseWidth / 2; y: 0 }  // Close
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
}
