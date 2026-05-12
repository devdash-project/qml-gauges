import QtQuick
import QtQuick.Shapes

/**
 * @brief Atomic gauge face/dial plate primitive.
 *
 * GaugeFace renders the background circle or plate behind gauge elements.
 * Supports solid colors, gradients, opacity for video overlay mode,
 * and optional border/bezel integration.
 *
 * @example
 * @code
 * GaugeFace {
 *     diameter: 380
 *     color: "#222222"
 *     borderWidth: 2
 *     borderColor: "#444444"
 * }
 * @endcode
 */
Item {
    id: root

    // === Geometry Properties ===

    /**
     * @brief Diameter of the gauge face (pixels).
     * @default 380
     */
    property real diameter: 380

    /**
     * @brief Border width around face edge (pixels).
     * @default 0
     */
    property real borderWidth: 0

    // === Appearance Properties ===

    /**
     * @brief Face background color.
     * @default "#222222" (dark gray)
     */
    property color color: "#222222"

    /**
     * @brief Border color (if borderWidth > 0).
     * @default "#444444"
     */
    property color borderColor: "#444444"

    /**
     * @brief Overall opacity (0-1).
     *
     * For video overlay mode, set to ~0.3-0.6 for translucent effect.
     *
     * @default 1.0 (fully opaque)
     */
    property real faceOpacity: 1.0

    /**
     * @brief Enable radial gradient fill.
     *
     * When true, creates gradient from center to edge
     * using gradientCenter and gradientEdge colors.
     *
     * @default false
     */
    property bool useGradient: false

    /**
     * @brief Gradient color at center (if useGradient is true).
     * @default color
     */
    property color gradientCenter: color

    /**
     * @brief Gradient color at edge (if useGradient is true).
     * @default Qt.darker(color, 1.2)
     */
    property color gradientEdge: Qt.darker(color, 1.2)

    /**
     * @brief Enable texture/image background.
     *
     * When set, loads an image for gauge face background.
     * Useful for carbon fiber, brushed metal, etc.
     *
     * @default "" (no texture)
     */
    property string textureSource: ""

    // === Subtle face gradient ===
    //
    // A soft radial gradient making the dial centre slightly brighter than its
    // edge — the gentle depth of a real white-face dial, and what gives the
    // outer highlight ring something to read against. Distinct from
    // `useGradient` (a plain top-to-bottom linear fill): this is a centred
    // radial wash, deliberately subtle. When both are set, this one wins.

    /**
     * @brief Render the face fill as a subtle centre-to-edge radial gradient.
     * @default false
     */
    property bool hasFaceGradient: false

    /**
     * @brief Gradient colour at (and around) the dial centre.
     * @default color (unchanged centre)
     */
    property color faceGradientCenterColor: color

    /**
     * @brief Gradient colour at the dial's outer edge.
     * @default Qt.darker(color, 1.05) (a hair darker)
     */
    property color faceGradientEdgeColor: Qt.darker(color, 1.05)

    /**
     * @brief Radius (fraction of the dial radius) held at the centre colour
     * before the gradient begins transitioning toward the edge colour.
     * @default 0.3
     */
    property real faceGradientCenterStop: 0.3

    // === Outer highlight ring ===
    //
    // A thin bright ring hugging the *outer* edge of the face — the bright
    // halo just inside a bezel on classic white-face gauges, where the dial's
    // curved edge catches light. It is part of the face's own appearance (the
    // face is what catches the light), not a separate layered primitive.

    /**
     * @brief Render a bright ring on the outer edge of the face.
     * @default false
     */
    property bool hasOuterHighlight: false

    /**
     * @brief Colour of the outer highlight ring.
     * @default "#ffffff"
     */
    property color outerHighlightColor: "#ffffff"

    /**
     * @brief Pixel width of the outer highlight ring.
     * @default 3.0
     */
    property real outerHighlightWidth: 3.0

    /**
     * @brief Opacity of the outer highlight ring.
     * @default 1.0
     */
    property real outerHighlightOpacity: 1.0

    // === Advanced ===

    /**
     * @brief Enable antialiasing on this component's shapes.
     *
     * Named `customAntialiasing` to avoid shadowing the inherited
     * `QQuickItem.antialiasing` property (a qmllint [property-override] warning).
     *
     * @default true
     */
    property bool customAntialiasing: true

    // === Internal Implementation ===

    implicitWidth: diameter
    implicitHeight: diameter

    Rectangle {
        id: face
        width: root.diameter
        height: root.diameter
        radius: root.diameter / 2
        anchors.centerIn: parent

        color: (root.useGradient || root.hasFaceGradient) ? "transparent" : root.color
        border.width: root.borderWidth
        border.color: root.borderColor
        opacity: root.faceOpacity

        antialiasing: root.customAntialiasing
        clip: true  // Enable clipping for circular texture

        // Linear gradient (if enabled and the radial face gradient isn't)
        gradient: (root.useGradient && !root.hasFaceGradient) ? faceGradient : undefined

        Gradient {
            id: faceGradient
            GradientStop { position: 0.0; color: root.gradientCenter }
            GradientStop { position: 1.0; color: root.gradientEdge }
        }

        // Subtle radial face gradient (drawn under texture / highlight).
        Shape {
            id: faceGradientShape
            visible: root.hasFaceGradient
            anchors.fill: parent
            antialiasing: root.customAntialiasing
            preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
                ? Shape.CurveRenderer
                : Shape.GeometryRenderer

            ShapePath {
                strokeColor: "transparent"
                fillColor: "transparent"
                fillGradient: RadialGradient {
                    centerX: root.diameter / 2
                    centerY: root.diameter / 2
                    centerRadius: root.diameter / 2
                    focalX: root.diameter / 2
                    focalY: root.diameter / 2
                    focalRadius: 0
                    GradientStop { position: 0.0; color: root.faceGradientCenterColor }
                    GradientStop { position: Math.max(0, Math.min(1, root.faceGradientCenterStop)); color: root.faceGradientCenterColor }
                    GradientStop { position: 1.0; color: root.faceGradientEdgeColor }
                }
                startX: root.diameter
                startY: root.diameter / 2
                PathAngleArc {
                    centerX: root.diameter / 2
                    centerY: root.diameter / 2
                    radiusX: root.diameter / 2
                    radiusY: root.diameter / 2
                    startAngle: 0
                    sweepAngle: 360
                }
            }
        }

        // Texture overlay (if set) - clipped to circle by parent
        Image {
            id: texture
            visible: root.textureSource !== ""
            anchors.fill: parent
            source: root.textureSource
            fillMode: Image.PreserveAspectCrop
            smooth: true
        }

        // Outer highlight ring: a centred border on a slightly inset circle so
        // the band occupies exactly the outermost `outerHighlightWidth` pixels
        // of the face. Painted last so it sits over fill / texture.
        Rectangle {
            visible: root.hasOuterHighlight
            width: root.diameter - root.outerHighlightWidth
            height: root.diameter - root.outerHighlightWidth
            radius: width / 2
            anchors.centerIn: parent
            color: "transparent"
            border.width: root.outerHighlightWidth
            border.color: root.outerHighlightColor
            opacity: root.outerHighlightOpacity
            antialiasing: root.customAntialiasing
        }
    }
}
