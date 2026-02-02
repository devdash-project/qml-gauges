import QtQuick
import QtQuick.Shapes

/**
 * @brief Atomic bezel/frame primitive for gauge exterior.
 *
 * GaugeBezel renders the outer decorative frame around a gauge.
 * Supports solid colors, chrome/metallic gradients, and various styles.
 *
 * @example
 * @code
 * GaugeBezel {
 *     outerRadius: 200
 *     innerRadius: 190
 *     style: "chrome"
 * }
 * @endcode
 */
Item {
    id: root

    // === Geometry Properties ===

    /**
     * @brief Outer radius of bezel (pixels).
     * @default 200
     */
    property real outerRadius: 200

    /**
     * @brief Inner radius of bezel (pixels).
     *
     * Bezel thickness = outerRadius - innerRadius
     *
     * @default 190
     */
    property real innerRadius: 190

    /**
     * @brief Additional border width (pixels).
     *
     * Adds thin line at inner/outer edges.
     *
     * @default 0
     */
    property real borderWidth: 0

    // === Appearance Properties ===

    /**
     * @brief Bezel fill color.
     * @default "#444444"
     */
    property color color: "#444444"

    /**
     * @brief Border color (if borderWidth > 0).
     * @default "#555555"
     */
    property color borderColor: "#555555"

    /**
     * @brief Bezel visual style.
     *
     * Supported styles:
     * - "flat": Solid color
     * - "chrome": Metallic vertical gradient
     * - "chrome3d": Cylindrical chrome with ConicalGradient (realistic 3D)
     * - "carbon": Carbon fiber texture (if textureSource set)
     * - "brushed": Brushed metal effect
     *
     * @default "flat"
     */
    property string style: "flat"

    /**
     * @brief Chrome gradient highlight color.
     * @default "#888888"
     */
    property color chromeHighlight: "#888888"

    /**
     * @brief Chrome gradient shadow color.
     * @default "#222222"
     */
    property color chromeShadow: "#222222"

    /**
     * @brief Overall opacity.
     * @default 1.0
     */
    property real bezelOpacity: 1.0

    /**
     * @brief Texture image source (for carbon, brushed styles).
     * @default ""
     */
    property string textureSource: ""

    // === Chrome3D Properties ===

    /**
     * @brief Light source angle for chrome3d style (degrees).
     *
     * Rotates the conical gradient to simulate light direction.
     * 0 = light from right, 90 = light from top, 180 = light from left.
     *
     * @default 45
     */
    property real chrome3dLightAngle: 45

    /**
     * @brief Number of highlight bands for chrome3d style.
     *
     * More bands create a more complex reflection pattern.
     *
     * @default 2
     */
    property int chrome3dBands: 2

    /**
     * @brief Chrome3d midtone color.
     * @default color (uses main bezel color)
     */
    property color chrome3dMidtone: color

    // === Advanced ===

    /**
     * @brief Enable antialiasing.
     * @default true
     */
    property bool antialiasing: true

    // === Internal Implementation ===

    implicitWidth: outerRadius * 2
    implicitHeight: outerRadius * 2

    // Bezel ring - using thick border for donut shape (pure Qt6, no masking needed)
    Rectangle {
        id: bezelRing
        width: root.outerRadius * 2
        height: root.outerRadius * 2
        radius: root.outerRadius
        anchors.centerIn: parent

        // Transparent fill - the border IS the bezel
        color: "transparent"

        // Thick border creates the ring/donut shape
        border.width: root.outerRadius - root.innerRadius
        border.color: (root.style === "chrome" || root.style === "chrome3d") ? "transparent" : root.color

        opacity: root.bezelOpacity
        antialiasing: root.antialiasing

        // Chrome gradient (applied to border via nested Rectangle)
        Rectangle {
            visible: root.style === "chrome"
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"

            border.width: parent.border.width
            gradient: chromeGradient

            Gradient {
                id: chromeGradient
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: root.chromeHighlight }
                GradientStop { position: 0.3; color: Qt.lighter(root.chromeHighlight, 1.2) }
                GradientStop { position: 0.5; color: root.color }
                GradientStop { position: 0.7; color: Qt.darker(root.color, 1.2) }
                GradientStop { position: 1.0; color: root.chromeShadow }
            }
        }

        // Chrome3D: Cylindrical chrome with ConicalGradient for realistic 3D appearance
        Shape {
            id: chrome3dShape
            visible: root.style === "chrome3d"
            anchors.fill: parent

            // Use CurveRenderer for smooth curves on Qt 6.10+
            preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
                ? Shape.CurveRenderer
                : Shape.GeometryRenderer

            // Outer ring with conical gradient (simulates cylindrical chrome)
            ShapePath {
                fillColor: "transparent"
                strokeWidth: root.outerRadius - root.innerRadius
                strokeColor: "transparent"

                fillGradient: ConicalGradient {
                    centerX: root.outerRadius
                    centerY: root.outerRadius
                    angle: root.chrome3dLightAngle

                    // Create realistic chrome ring with highlight bands
                    // The pattern repeats to simulate cylindrical reflections
                    GradientStop { position: 0.0; color: root.chromeShadow }
                    GradientStop { position: 0.1; color: root.chrome3dMidtone }
                    GradientStop { position: 0.25; color: root.chromeHighlight }
                    GradientStop { position: 0.35; color: Qt.lighter(root.chromeHighlight, 1.3) }
                    GradientStop { position: 0.45; color: root.chromeHighlight }
                    GradientStop { position: 0.55; color: root.chrome3dMidtone }
                    GradientStop { position: 0.65; color: root.chromeShadow }
                    GradientStop { position: 0.75; color: root.chrome3dMidtone }
                    GradientStop { position: 0.85; color: root.chromeHighlight }
                    GradientStop { position: 0.95; color: root.chrome3dMidtone }
                    GradientStop { position: 1.0; color: root.chromeShadow }
                }

                // Draw ring as circular arc
                PathAngleArc {
                    centerX: root.outerRadius
                    centerY: root.outerRadius
                    radiusX: (root.outerRadius + root.innerRadius) / 2
                    radiusY: (root.outerRadius + root.innerRadius) / 2
                    startAngle: 0
                    sweepAngle: 360
                }
            }
        }

        // Texture overlay for carbon/brushed styles
        Item {
            visible: root.textureSource !== ""
            anchors.fill: parent
            clip: true

            Image {
                id: texture
                anchors.fill: parent
                source: root.textureSource
                fillMode: Image.PreserveAspectCrop
                smooth: true

                // Clip to ring shape using parent's circular clip
                layer.enabled: true
                layer.smooth: true
            }

            // Mask to create ring (hide center)
            Rectangle {
                width: root.innerRadius * 2
                height: root.innerRadius * 2
                radius: root.innerRadius
                anchors.centerIn: parent
                color: "#000000"  // Hides texture in center
            }
        }

        // Optional inner border accent
        Rectangle {
            visible: root.borderWidth > 0
            width: root.innerRadius * 2
            height: root.innerRadius * 2
            radius: root.innerRadius
            anchors.centerIn: parent
            color: "transparent"
            border.width: root.borderWidth
            border.color: root.borderColor
            antialiasing: root.antialiasing
        }
    }
}
