import QtQuick
import QtQuick.Shapes

/**
 * @brief Glass/lens overlay effect for gauges.
 *
 * GlassOverlay creates a realistic curved glass effect over gauges,
 * including a curved highlight arc at the top (light reflection),
 * edge vignette (lens curvature), and optional subtle reflections.
 *
 * Layer this on top of a gauge to simulate a glass cover.
 *
 * @example
 * @code
 * GlassOverlay {
 *     anchors.fill: gaugeComponent
 *     highlightIntensity: 0.3
 *     vignetteIntensity: 0.15
 * }
 * @endcode
 */
Item {
    id: root

    // === Geometry ===

    /**
     * @brief Radius of the circular glass area.
     *
     * Defaults to half the component width.
     *
     * @default width / 2
     */
    property real radius: width / 2

    // === Highlight Properties ===

    /**
     * @brief Enable top highlight arc (light reflection).
     * @default true
     */
    property bool highlightEnabled: true

    /**
     * @brief Highlight arc intensity (0.0-1.0).
     * @default 0.25
     */
    property real highlightIntensity: 0.25

    /**
     * @brief Highlight color.
     * @default "#ffffff"
     */
    property color highlightColor: "#ffffff"

    /**
     * @brief Angle of highlight arc from top (degrees).
     *
     * Larger values create a wider highlight arc.
     *
     * @default 60
     */
    property real highlightAngle: 60

    /**
     * @brief Vertical offset of highlight from center (0.0-1.0).
     *
     * 0.0 = centered, positive = toward top.
     *
     * @default 0.3
     */
    property real highlightOffset: 0.3

    // === Vignette Properties ===

    /**
     * @brief Enable edge vignette (darkening at edges).
     * @default true
     */
    property bool vignetteEnabled: true

    /**
     * @brief Vignette intensity (0.0-1.0).
     * @default 0.12
     */
    property real vignetteIntensity: 0.12

    /**
     * @brief Vignette color.
     * @default "#000000"
     */
    property color vignetteColor: "#000000"

    /**
     * @brief Vignette inner radius as fraction of total radius.
     *
     * Area inside this radius is fully transparent.
     *
     * @default 0.7
     */
    property real vignetteInnerRadius: 0.7

    // === Reflection Properties ===

    /**
     * @brief Enable subtle curved reflection line.
     * @default false
     */
    property bool reflectionEnabled: false

    /**
     * @brief Reflection line intensity (0.0-1.0).
     * @default 0.1
     */
    property real reflectionIntensity: 0.1

    // === Internal ===

    readonly property real _centerX: width / 2
    readonly property real _centerY: height / 2

    implicitWidth: 400
    implicitHeight: 400

    // Top highlight arc (curved glass reflection)
    Shape {
        id: highlightShape
        visible: root.highlightEnabled && root.highlightIntensity > 0
        anchors.fill: parent
        layer.enabled: true
        layer.smooth: true

        // Use CurveRenderer for smooth curves on Qt 6.10+
        preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
            ? Shape.CurveRenderer
            : Shape.GeometryRenderer

        ShapePath {
            id: highlightPath
            fillColor: "transparent"
            strokeColor: "transparent"

            // Radial gradient from top edge fading inward
            fillGradient: RadialGradient {
                centerX: root._centerX
                centerY: root._centerY - root.radius * root.highlightOffset
                focalX: centerX
                focalY: centerY - root.radius * 0.3
                centerRadius: root.radius * 0.8
                focalRadius: 0

                GradientStop {
                    position: 0.0
                    color: Qt.rgba(
                        root.highlightColor.r,
                        root.highlightColor.g,
                        root.highlightColor.b,
                        root.highlightIntensity
                    )
                }
                GradientStop {
                    position: 0.4
                    color: Qt.rgba(
                        root.highlightColor.r,
                        root.highlightColor.g,
                        root.highlightColor.b,
                        root.highlightIntensity * 0.3
                    )
                }
                GradientStop {
                    position: 1.0
                    color: "transparent"
                }
            }

            // Arc at top of circle
            PathAngleArc {
                centerX: root._centerX
                centerY: root._centerY
                radiusX: root.radius - 2
                radiusY: root.radius - 2
                startAngle: -90 - root.highlightAngle
                sweepAngle: root.highlightAngle * 2
            }

            // Close path back through center area
            PathLine {
                x: root._centerX + Math.cos((-90 + root.highlightAngle) * Math.PI / 180) * root.radius * 0.3
                y: root._centerY + Math.sin((-90 + root.highlightAngle) * Math.PI / 180) * root.radius * 0.3
            }
            PathLine {
                x: root._centerX + Math.cos((-90 - root.highlightAngle) * Math.PI / 180) * root.radius * 0.3
                y: root._centerY + Math.sin((-90 - root.highlightAngle) * Math.PI / 180) * root.radius * 0.3
            }
        }
    }

    // Edge vignette (lens curvature effect)
    Rectangle {
        id: vignetteLayer
        visible: root.vignetteEnabled && root.vignetteIntensity > 0
        anchors.fill: parent

        // Circular clip
        layer.enabled: true
        layer.smooth: true

        color: "transparent"

        // Radial gradient: transparent center, dark edges
        Rectangle {
            anchors.fill: parent
            radius: root.radius

            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // Use Canvas for true radial vignette
        Canvas {
            id: vignetteCanvas
            anchors.fill: parent

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                var cx = width / 2
                var cy = height / 2
                var r = root.radius

                // Radial gradient: transparent center, dark edges
                var gradient = ctx.createRadialGradient(cx, cy, r * root.vignetteInnerRadius, cx, cy, r)
                gradient.addColorStop(0, "transparent")
                gradient.addColorStop(1, Qt.rgba(
                    root.vignetteColor.r,
                    root.vignetteColor.g,
                    root.vignetteColor.b,
                    root.vignetteIntensity
                ))

                ctx.beginPath()
                ctx.arc(cx, cy, r, 0, Math.PI * 2)
                ctx.fillStyle = gradient
                ctx.fill()
            }

            // Repaint when properties change
            Connections {
                target: root
                function onVignetteIntensityChanged() { vignetteCanvas.requestPaint() }
                function onVignetteInnerRadiusChanged() { vignetteCanvas.requestPaint() }
                function onRadiusChanged() { vignetteCanvas.requestPaint() }
            }

            Component.onCompleted: requestPaint()
        }
    }

    // Subtle curved reflection line
    Shape {
        id: reflectionShape
        visible: root.reflectionEnabled && root.reflectionIntensity > 0
        anchors.fill: parent

        preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
            ? Shape.CurveRenderer
            : Shape.GeometryRenderer

        ShapePath {
            strokeWidth: 1.5
            strokeColor: Qt.rgba(1, 1, 1, root.reflectionIntensity)
            fillColor: "transparent"

            // Curved reflection line near top
            PathAngleArc {
                centerX: root._centerX
                centerY: root._centerY
                radiusX: root.radius * 0.85
                radiusY: root.radius * 0.85
                startAngle: -120
                sweepAngle: 60
            }
        }
    }
}
