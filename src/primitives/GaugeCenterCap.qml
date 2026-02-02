import QtQuick
import QtQuick.Shapes
import QtQuick.Effects

/**
 * @brief Atomic center cap primitive for gauge needle pivot.
 *
 * GaugeCenterCap renders a decorative cap that covers the needle
 * pivot point. Supports solid colors, gradients, and border effects.
 *
 * @example
 * @code
 * GaugeCenterCap {
 *     diameter: 20
 *     color: "#444444"
 *     borderWidth: 2
 *     borderColor: "#666666"
 * }
 * @endcode
 */
Item {
    id: root

    // === Geometry Properties ===

    /**
     * @brief Diameter of center cap (pixels).
     * @default 20
     */
    property real diameter: 20

    /**
     * @brief Border width (pixels).
     * @default 2
     */
    property real borderWidth: 2

    // === Appearance Properties ===

    /**
     * @brief Fill color.
     * @default "#444444" (dark gray)
     */
    property color color: "#444444"

    /**
     * @brief Border color.
     * @default "#666666" (medium gray)
     */
    property color borderColor: "#666666"

    /**
     * @brief Enable radial gradient.
     *
     * Creates metallic/3D effect with light at top.
     *
     * @default false
     */
    property bool hasGradient: false

    /**
     * @brief Gradient highlight color (top).
     * @default "#666666"
     */
    property color gradientTop: "#666666"

    /**
     * @brief Gradient shadow color (bottom).
     * @default "#333333"
     */
    property color gradientBottom: "#333333"

    /**
     * @brief Overall opacity.
     * @default 1.0
     */
    property real capOpacity: 1.0

    // === 3D Effects ===

    /**
     * @brief Enable drop shadow for raised appearance.
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
     * @default 0.3
     */
    property real shadowBlur: 0.3

    /**
     * @brief Shadow opacity.
     * @default 0.5
     */
    property real shadowOpacity: 0.5

    /**
     * @brief Enable highlight ring for domed/beveled appearance.
     * Creates a lighter arc on top edge simulating 3D curvature.
     * @default false
     */
    property bool hasHighlight: false

    /**
     * @brief Highlight color (top edge).
     * @default Qt.lighter(borderColor, 1.5)
     */
    property color highlightColor: Qt.lighter(borderColor, 1.5)

    /**
     * @brief Highlight ring width (pixels).
     * @default borderWidth
     */
    property real highlightWidth: borderWidth

    // === Domed/3D Style ===

    /**
     * @brief Enable domed/spherical appearance.
     *
     * Creates a 3D dome effect using radial gradients with off-center
     * highlight to simulate a curved reflective surface.
     *
     * @default false
     */
    property bool domed: false

    /**
     * @brief Domed highlight position X (0.0-1.0).
     *
     * Position of the highlight within the cap. 0.5 = center.
     * Default 0.35 places highlight slightly upper-left.
     *
     * @default 0.35
     */
    property real domedHighlightX: 0.35

    /**
     * @brief Domed highlight position Y (0.0-1.0).
     *
     * Position of the highlight within the cap. 0.5 = center.
     * Default 0.35 places highlight slightly upper-left.
     *
     * @default 0.35
     */
    property real domedHighlightY: 0.35

    /**
     * @brief Domed highlight color (brightest point).
     * @default Qt.lighter(color, 2.0)
     */
    property color domedHighlightColor: Qt.lighter(color, 2.0)

    /**
     * @brief Domed midtone color (middle of gradient).
     * @default color
     */
    property color domedMidtoneColor: color

    /**
     * @brief Domed shadow color (edge of dome).
     * @default Qt.darker(color, 1.8)
     */
    property color domedShadowColor: Qt.darker(color, 1.8)

    /**
     * @brief Show chrome reflection arc on domed cap.
     * @default false
     */
    property bool domedChromeReflection: false

    // === Advanced ===

    /**
     * @brief Enable antialiasing.
     * @default true
     */
    property bool antialiasing: true

    // === Internal Implementation ===

    implicitWidth: diameter
    implicitHeight: diameter

    // Container for shadow effect
    Item {
        id: capContainer
        anchors.centerIn: parent
        width: root.diameter
        height: root.diameter
        opacity: root.capOpacity

        layer.enabled: root.hasShadow
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: root.shadowColor
            shadowHorizontalOffset: root.shadowOffsetX
            shadowVerticalOffset: root.shadowOffsetY
            shadowBlur: root.shadowBlur
            shadowOpacity: root.shadowOpacity
        }

        Rectangle {
            id: cap
            anchors.fill: parent
            radius: root.diameter / 2

            color: root.hasGradient && !root.domed ? "transparent" : (root.domed ? "transparent" : root.color)
            border.width: root.borderWidth
            border.color: root.borderColor
            antialiasing: root.antialiasing

            // Radial gradient for metallic effect (only when not domed)
            gradient: root.hasGradient && !root.domed ? capGradient : undefined

            Gradient {
                id: capGradient
                GradientStop { position: 0.0; color: root.gradientTop }
                GradientStop { position: 1.0; color: root.gradientBottom }
            }
        }

        // Domed/spherical gradient overlay
        // Creates 3D dome effect with off-center highlight
        Shape {
            id: domedShape
            visible: root.domed
            anchors.fill: parent

            preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
                ? Shape.CurveRenderer
                : Shape.GeometryRenderer

            ShapePath {
                strokeColor: "transparent"
                fillGradient: RadialGradient {
                    // Off-center focal point creates 3D highlight effect
                    centerX: root.diameter / 2
                    centerY: root.diameter / 2
                    centerRadius: root.diameter / 2
                    focalX: root.diameter * root.domedHighlightX
                    focalY: root.diameter * root.domedHighlightY
                    focalRadius: 0

                    GradientStop { position: 0.0; color: root.domedHighlightColor }
                    GradientStop { position: 0.3; color: root.domedMidtoneColor }
                    GradientStop { position: 0.7; color: Qt.darker(root.domedMidtoneColor, 1.3) }
                    GradientStop { position: 1.0; color: root.domedShadowColor }
                }

                // Circle path
                PathAngleArc {
                    centerX: root.diameter / 2
                    centerY: root.diameter / 2
                    radiusX: root.diameter / 2 - root.borderWidth
                    radiusY: root.diameter / 2 - root.borderWidth
                    startAngle: 0
                    sweepAngle: 360
                }
            }
        }

        // Chrome reflection arc on domed cap (like light reflecting off curved chrome)
        Shape {
            id: chromeReflection
            visible: root.domed && root.domedChromeReflection
            anchors.fill: parent

            preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
                ? Shape.CurveRenderer
                : Shape.GeometryRenderer

            ShapePath {
                strokeWidth: 1.5
                strokeColor: Qt.rgba(1, 1, 1, 0.6)
                fillColor: "transparent"

                // Curved reflection arc near highlight
                PathAngleArc {
                    centerX: root.diameter / 2
                    centerY: root.diameter / 2
                    radiusX: root.diameter * 0.3
                    radiusY: root.diameter * 0.3
                    startAngle: -160
                    sweepAngle: 50
                }
            }
        }

        // Inner highlight ring for domed/beveled 3D effect
        // A lighter inner ring creates the illusion of a raised/domed surface
        Rectangle {
            id: highlightRing
            visible: root.hasHighlight
            anchors.centerIn: parent
            width: root.diameter - root.borderWidth * 2
            height: root.diameter - root.borderWidth * 2
            radius: width / 2
            color: "transparent"
            border.width: root.highlightWidth
            border.color: root.highlightColor
            antialiasing: root.antialiasing
            opacity: 0.4
        }
    }
}
