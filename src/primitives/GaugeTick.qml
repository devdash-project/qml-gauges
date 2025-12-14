pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import QtQuick.Effects

/**
 * @brief Atomic tick mark primitive for gauge scales.
 *
 * GaugeTick renders a single rotatable tick mark at a specified angle
 * and distance from the gauge center. Used by GaugeTickRing to create
 * complete gauge scales.
 *
 * Supports multiple shapes, gradients, glow effects, and shadows.
 *
 * @example
 * @code
 * GaugeTick {
 *     angle: 45
 *     length: 15
 *     tickWidth: 3
 *     distanceFromCenter: 140
 *     color: "#888888"
 *     tickShape: "triangle"
 *     hasGlow: true
 * }
 * @endcode
 */
Item {
    id: root

    // === Position Properties ===

    /**
     * @brief Rotation angle in degrees (0 = 3 o'clock).
     *
     * The tick rotates around the gauge center to this position.
     *
     * @default 0
     */
    property real angle: 0

    /**
     * @brief Distance from gauge center to tick start (pixels).
     *
     * This is the radius at which the tick begins.
     * The tick extends inward by `length` pixels.
     *
     * @default 100
     */
    property real distanceFromCenter: 100

    // === Geometry Properties ===

    /**
     * @brief Length of tick mark (pixels).
     *
     * Major ticks are typically 15px, minor ticks 8px.
     *
     * @default 15
     */
    property real length: 15

    /**
     * @brief Width of tick mark (pixels).
     *
     * Major ticks are typically 3px, minor ticks 2px.
     *
     * @default 3
     */
    property real tickWidth: 3

    /**
     * @brief Tick mark shape style.
     *
     * Supported shapes:
     * - "rectangle": Standard rectangular tick (default)
     * - "rounded-dot": Circle at outer end, tapers to point inward
     * - "triangle": Pointed at inner end, flat base at outer
     * - "chevron": V-shaped tick pointing inward
     * - "block": Thick rectangular tick with flat ends
     *
     * @default "rectangle"
     */
    property string tickShape: "rectangle"

    // === Appearance Properties ===

    /**
     * @brief Tick mark color.
     * @default "#888888" (gray)
     */
    property color color: "#888888"

    /**
     * @brief Overall opacity.
     * @default 1.0
     */
    property real tickOpacity: 1.0

    /**
     * @brief Rounded ends for rectangle shape.
     * Only applies when tickShape is "rectangle".
     * @default true
     */
    property bool roundedEnds: true

    // === Gradient Properties ===

    /**
     * @brief Enable gradient fill for tick.
     * @default false
     */
    property bool hasGradient: false

    /**
     * @brief Gradient start color (outer end of tick).
     * @default color
     */
    property color gradientStart: color

    /**
     * @brief Gradient end color (inner end of tick).
     * @default Qt.darker(color, 1.3)
     */
    property color gradientEnd: Qt.darker(color, 1.3)

    // === Glow Properties ===

    /**
     * @brief Enable glow effect for luminous paint appearance.
     * @default false
     */
    property bool hasGlow: false

    /**
     * @brief Glow color.
     * @default color
     */
    property color glowColor: color

    /**
     * @brief Glow blur amount (0.0-1.0).
     * @default 0.4
     */
    property real glowBlur: 0.4

    // === Shadow Properties ===

    /**
     * @brief Enable drop shadow for 3D depth.
     * @default false
     */
    property bool hasShadow: false

    /**
     * @brief Shadow color.
     * @default "#000000"
     */
    property color shadowColor: "#000000"

    /**
     * @brief Shadow horizontal offset (pixels).
     * @default 2
     */
    property real shadowOffsetX: 2

    /**
     * @brief Shadow vertical offset (pixels).
     * @default 2
     */
    property real shadowOffsetY: 2

    /**
     * @brief Shadow blur amount (0.0-1.0).
     * @default 0.25
     */
    property real shadowBlur: 0.25

    /**
     * @brief Shadow opacity.
     * @default 0.5
     */
    property real shadowOpacity: 0.5

    // === Inner Circle Decoration ===

    /**
     * @brief Show decorative circle at inner end of tick.
     *
     * Creates a classic gauge aesthetic like vintage speedometers.
     *
     * @default false
     */
    property bool showInnerCircle: false

    /**
     * @brief Diameter of inner circle (if enabled).
     * @default tickWidth * 2
     */
    property real innerCircleDiameter: tickWidth * 2

    /**
     * @brief Color of inner circle.
     * @default color (matches tick mark)
     */
    property color innerCircleColor: color

    // === Internal Implementation ===

    implicitWidth: distanceFromCenter * 2
    implicitHeight: distanceFromCenter * 2

    // Shared computed values
    readonly property real tickX: width / 2 - tickWidth / 2
    readonly property real tickY: (height / 2) - distanceFromCenter

    // Main tick container with effects
    Item {
        id: tickContainer
        anchors.fill: parent
        opacity: root.tickOpacity

        layer.enabled: root.hasGlow || root.hasShadow
        layer.effect: MultiEffect {
            // Glow effect (blur + colorization)
            blurEnabled: root.hasGlow
            blur: root.glowBlur
            blurMax: 32
            colorization: root.hasGlow ? 0.8 : 0.0
            colorizationColor: root.glowColor

            // Shadow effect
            shadowEnabled: root.hasShadow
            shadowColor: root.shadowColor
            shadowHorizontalOffset: root.shadowOffsetX
            shadowVerticalOffset: root.shadowOffsetY
            shadowBlur: root.shadowBlur
            shadowOpacity: root.shadowOpacity
        }

        // Shared gradient for Rectangle-based shapes
        Gradient {
            id: rectGradient
            GradientStop { position: 0.0; color: root.gradientStart }
            GradientStop { position: 1.0; color: root.gradientEnd }
        }

        // Rectangle shape (default)
        Rectangle {
            id: rectangleTick
            visible: root.tickShape === "rectangle"
            x: root.tickX
            y: root.tickY
            width: root.tickWidth
            height: root.length
            radius: root.roundedEnds ? root.tickWidth / 2 : 0
            color: root.hasGradient ? "transparent" : root.color
            gradient: root.hasGradient ? rectGradient : null

            transform: Rotation {
                origin.x: root.tickWidth / 2
                origin.y: root.distanceFromCenter
                angle: root.angle
            }
        }

        // Block shape (thick flat rectangle)
        Rectangle {
            id: blockTick
            visible: root.tickShape === "block"
            x: root.tickX
            y: root.tickY
            width: root.tickWidth
            height: root.length
            radius: 0
            color: root.hasGradient ? "transparent" : root.color
            gradient: root.hasGradient ? rectGradient : null

            transform: Rotation {
                origin.x: root.tickWidth / 2
                origin.y: root.distanceFromCenter
                angle: root.angle
            }
        }

        // Gradient for triangle shape
        LinearGradient {
            id: triangleGradient
            x1: root.width / 2
            y1: root.tickY
            x2: root.width / 2
            y2: root.tickY + root.length
            GradientStop { position: 0.0; color: root.gradientStart }
            GradientStop { position: 1.0; color: root.gradientEnd }
        }

        // Triangle shape (pointed at inner end)
        Shape {
            id: triangleTick
            visible: root.tickShape === "triangle"
            anchors.fill: parent
            antialiasing: true
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: "transparent"
                strokeWidth: 0
                fillColor: root.hasGradient ? "transparent" : root.color
                fillGradient: root.hasGradient ? triangleGradient : null

                // Triangle from flat base to point
                startX: root.width / 2 - root.tickWidth / 2
                startY: root.tickY

                PathLine { x: root.width / 2 + root.tickWidth / 2; y: root.tickY }
                PathLine { x: root.width / 2; y: root.tickY + root.length }
                PathLine { x: root.width / 2 - root.tickWidth / 2; y: root.tickY }
            }

            transform: Rotation {
                origin.x: root.width / 2
                origin.y: root.height / 2
                angle: root.angle
            }
        }

        // Rounded-dot shape (circle at outer, tapers inward)
        Item {
            id: roundedDotTick
            visible: root.tickShape === "rounded-dot"
            anchors.fill: parent

            // Outer circle (dot)
            Rectangle {
                x: root.width / 2 - root.tickWidth / 2
                y: root.tickY
                width: root.tickWidth
                height: root.tickWidth
                radius: root.tickWidth / 2
                color: root.hasGradient ? root.gradientStart : root.color

                transform: Rotation {
                    origin.x: root.tickWidth / 2
                    origin.y: root.distanceFromCenter
                    angle: root.angle
                }
            }

            // Gradient for rounded-dot taper
            LinearGradient {
                id: roundedDotGradient
                x1: root.width / 2
                y1: root.tickY + root.tickWidth / 2
                x2: root.width / 2
                y2: root.tickY + root.length
                GradientStop { position: 0.0; color: root.gradientStart }
                GradientStop { position: 1.0; color: root.gradientEnd }
            }

            // Tapered line from dot to inner point
            Shape {
                anchors.fill: parent
                antialiasing: true
                preferredRendererType: Shape.CurveRenderer
                visible: root.length > root.tickWidth

                ShapePath {
                    strokeColor: "transparent"
                    strokeWidth: 0
                    fillColor: root.hasGradient ? "transparent" : root.color
                    fillGradient: root.hasGradient ? roundedDotGradient : null

                    // Taper from dot bottom to point
                    startX: root.width / 2 - root.tickWidth / 2
                    startY: root.tickY + root.tickWidth / 2

                    PathLine { x: root.width / 2 + root.tickWidth / 2; y: root.tickY + root.tickWidth / 2 }
                    PathLine { x: root.width / 2; y: root.tickY + root.length }
                    PathLine { x: root.width / 2 - root.tickWidth / 2; y: root.tickY + root.tickWidth / 2 }
                }

                transform: Rotation {
                    origin.x: root.width / 2
                    origin.y: root.height / 2
                    angle: root.angle
                }
            }
        }

        // Chevron shape (V pointing inward)
        Shape {
            id: chevronTick
            visible: root.tickShape === "chevron"
            anchors.fill: parent
            antialiasing: true
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                id: chevronPath
                strokeColor: root.color
                strokeWidth: root.tickWidth / 2
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin

                readonly property real armWidth: root.tickWidth * 1.5

                // V shape
                startX: root.width / 2 - chevronPath.armWidth
                startY: root.tickY

                PathLine { x: root.width / 2; y: root.tickY + root.length / 2 }
                PathLine { x: root.width / 2 + chevronPath.armWidth; y: root.tickY }
            }

            transform: Rotation {
                origin.x: root.width / 2
                origin.y: root.height / 2
                angle: root.angle
            }
        }

        // Inner decorative circle (classic gauge style)
        Rectangle {
            id: innerCircle
            visible: root.showInnerCircle
            width: root.innerCircleDiameter
            height: root.innerCircleDiameter
            radius: root.innerCircleDiameter / 2
            color: root.innerCircleColor

            x: root.width / 2 - root.innerCircleDiameter / 2
            y: root.tickY + root.length - root.innerCircleDiameter / 2

            transform: Rotation {
                origin.x: root.innerCircleDiameter / 2
                origin.y: root.distanceFromCenter - root.length + root.innerCircleDiameter / 2
                angle: root.angle
            }
        }
    }
}
