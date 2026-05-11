import QtQuick
import QtQuick.Shapes
import QtQuick.Effects

/**
 * @brief Atomic fastener-ring primitive for bezel screws / rivets / bolts.
 *
 * BezelScrews renders N small circular fasteners evenly distributed
 * around a ring at a configurable radius. Each fastener may carry an
 * optional head detail (slot, cross, hex, dot) to suggest a specific
 * fastener type, and optionally casts a small drop shadow so the head
 * reads as if it is sitting in a recess.
 *
 * Typical use is layered on top of a GaugeBezel to convert a painted
 * ring into a "real instrument" look by giving it visible fasteners
 * at the cardinal or intercardinal positions.
 *
 * @example
 * @code
 * BezelScrews {
 *     anchors.fill: parent
 *     count: 4
 *     angleOffset: 0
 *     radius: width * 0.42
 *     screwDiameter: 10
 *     headStyle: "slot"
 * }
 * @endcode
 */
Item {
    id: root

    // === Layout ===

    /**
     * @brief Number of fasteners to render around the ring.
     *
     * Typical values 4, 6, 8. A value of 0 renders nothing.
     *
     * @default 4
     */
    property int count: 4

    /**
     * @brief Rotation offset applied to the first fastener position (degrees).
     *
     * 0 places the first screw at the 12 o'clock position (top), with
     * subsequent screws stepping clockwise. 45 with count=4 produces
     * intercardinal placement (1:30, 4:30, 7:30, 10:30).
     *
     * @default 0
     */
    property real angleOffset: 0

    /**
     * @brief Radial distance from center where fasteners are placed (pixels).
     *
     * Defaults to roughly 85% of the component half-extent so the screws
     * sit comfortably inside an enclosing bezel ring. Override when the
     * caller knows the bezel's actual inner radius.
     *
     * @default Math.min(width, height) / 2 * 0.85
     */
    property real radius: Math.min(root.width, root.height) / 2 * 0.85

    // === Per-screw appearance ===

    /**
     * @brief Diameter of each individual fastener head (pixels).
     * @default 8
     */
    property real screwDiameter: 8

    /**
     * @brief Fill color of the fastener head.
     *
     * The default matches the IndustrialGauge bezel so screws read as
     * the same painted metal as the bezel itself.
     *
     * @default "#1a1815"
     */
    property color screwColor: "#1a1815"

    /**
     * @brief Head detail style drawn on top of each fastener.
     *
     * Supported values:
     * - "plain": no detail (smooth head)
     * - "slot":  single horizontal slot line (slotted screw)
     * - "cross": perpendicular slot lines (Phillips screw)
     * - "hex":   hexagonal outline (Allen / hex bolt)
     * - "dot":   small filled circle in the center (rivet)
     *
     * @default "slot"
     */
    property string headStyle: "slot"

    /**
     * @brief Color of the head detail (slot / cross / hex / dot).
     * @default Qt.darker(screwColor, 1.8)
     */
    property color headDetailColor: Qt.darker(root.screwColor, 1.8)

    // === Form shading ===

    /**
     * @brief Whether the head renders with directional form shading.
     *
     * When true, the screw head is filled with a radial gradient that
     * simulates a light source catching one side, so the head reads as a
     * three-dimensional protrusion rather than a flat disc. When false,
     * the head is a flat-colored circle (the original behavior).
     *
     * @default true
     */
    property bool hasFormShading: true

    /**
     * @brief Direction of the simulated light source (degrees).
     *
     * 0 places the highlight at the top of the head; negative values
     * rotate it counterclockwise (toward the left). -45 yields an
     * upper-left highlight, the conventional instrument-lighting angle.
     *
     * @default -45
     */
    property real lightAngle: -45

    /**
     * @brief Strength of the form shading (0.0-1.0).
     *
     * 0 produces no visible shading (flat color, equivalent to
     * hasFormShading=false). 1.0 is maximum contrast between the
     * highlight and shadow sides of the head. 0.4 is noticeable but
     * restrained.
     *
     * @default 0.4
     */
    property real formShadingIntensity: 0.4

    /** @brief Highlight color used on the lit side of the head. */
    readonly property color _formHighlightColor:
        Qt.lighter(root.screwColor, 1.0 + root.formShadingIntensity * 0.6)

    /** @brief Shadow color used on the unlit side of the head. */
    readonly property color _formShadowColor:
        Qt.darker(root.screwColor, 1.0 + root.formShadingIntensity * 0.5)

    /** @brief Light direction unit vector (screen space, +x right, +y down). */
    readonly property real _lightDirX: Math.cos((root.lightAngle - 90) * Math.PI / 180)
    readonly property real _lightDirY: Math.sin((root.lightAngle - 90) * Math.PI / 180)

    /**
     * @brief Stroke width of the slot or cross detail (pixels).
     *
     * Also drives hex outline width. Ignored for "plain" and "dot".
     *
     * @default 1.5
     */
    property real headDetailWidth: 1.5

    // === Recess shadow ===

    /**
     * @brief Whether each fastener casts a small drop shadow.
     *
     * Suggests the screw is seated in a recess in the bezel.
     *
     * @default true
     */
    property bool hasShadow: true

    /**
     * @brief Drop shadow color.
     * @default "#000000"
     */
    property color shadowColor: "#000000"

    /**
     * @brief Drop shadow opacity (0.0-1.0).
     * @default 0.4
     */
    property real shadowOpacity: 0.4

    /**
     * @brief Drop shadow horizontal offset (pixels).
     * @default 0
     */
    property real shadowOffsetX: 0

    /**
     * @brief Drop shadow vertical offset (pixels).
     * @default 1
     */
    property real shadowOffsetY: 1

    // === Implementation ===

    implicitWidth: 200
    implicitHeight: 200

    Repeater {
        model: Math.max(0, root.count)

        delegate: Item {
            id: screwSlot
            required property int index

            readonly property real _angleDeg:
                root.angleOffset - 90 + (360 / Math.max(1, root.count)) * screwSlot.index
            readonly property real _angleRad: screwSlot._angleDeg * Math.PI / 180
            readonly property real _cx: root.width / 2 + root.radius * Math.cos(screwSlot._angleRad)
            readonly property real _cy: root.height / 2 + root.radius * Math.sin(screwSlot._angleRad)

            x: screwSlot._cx - root.screwDiameter / 2
            y: screwSlot._cy - root.screwDiameter / 2
            width: root.screwDiameter
            height: root.screwDiameter

            layer.enabled: root.hasShadow
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: root.shadowColor
                shadowOpacity: root.shadowOpacity
                shadowHorizontalOffset: root.shadowOffsetX
                shadowVerticalOffset: root.shadowOffsetY
                shadowBlur: 0.5
            }

            // Screw head — flat fill when form shading is disabled
            Rectangle {
                id: head
                anchors.fill: parent
                visible: !root.hasFormShading
                radius: width / 2
                color: root.screwColor
                antialiasing: true
            }

            // Screw head — radial-gradient fill simulating directional light
            Shape {
                anchors.fill: parent
                visible: root.hasFormShading
                preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
                    ? Shape.CurveRenderer
                    : Shape.GeometryRenderer

                ShapePath {
                    id: shadedHeadPath
                    strokeColor: "transparent"
                    fillColor: "transparent"

                    readonly property real _r: root.screwDiameter / 2

                    fillGradient: RadialGradient {
                        centerX: shadedHeadPath._r
                        centerY: shadedHeadPath._r
                        centerRadius: shadedHeadPath._r
                        focalX: shadedHeadPath._r + root.screwDiameter * 0.15 * root._lightDirX
                        focalY: shadedHeadPath._r + root.screwDiameter * 0.15 * root._lightDirY
                        focalRadius: 0

                        GradientStop { position: 0.0; color: root._formHighlightColor }
                        GradientStop { position: 0.5; color: root.screwColor }
                        GradientStop { position: 1.0; color: root._formShadowColor }
                    }

                    PathAngleArc {
                        centerX: shadedHeadPath._r
                        centerY: shadedHeadPath._r
                        radiusX: shadedHeadPath._r
                        radiusY: shadedHeadPath._r
                        startAngle: 0
                        sweepAngle: 360
                    }
                }
            }

            // Slot: single horizontal line
            Shape {
                anchors.fill: parent
                visible: root.headStyle === "slot"
                preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
                    ? Shape.CurveRenderer
                    : Shape.GeometryRenderer

                ShapePath {
                    strokeColor: root.headDetailColor
                    strokeWidth: root.headDetailWidth
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap

                    startX: root.screwDiameter * 0.2
                    startY: root.screwDiameter / 2
                    PathLine {
                        x: root.screwDiameter * 0.8
                        y: root.screwDiameter / 2
                    }
                }
            }

            // Cross: two perpendicular lines
            Shape {
                anchors.fill: parent
                visible: root.headStyle === "cross"
                preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
                    ? Shape.CurveRenderer
                    : Shape.GeometryRenderer

                ShapePath {
                    strokeColor: root.headDetailColor
                    strokeWidth: root.headDetailWidth
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap

                    startX: root.screwDiameter * 0.2
                    startY: root.screwDiameter / 2
                    PathLine {
                        x: root.screwDiameter * 0.8
                        y: root.screwDiameter / 2
                    }
                }
                ShapePath {
                    strokeColor: root.headDetailColor
                    strokeWidth: root.headDetailWidth
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap

                    startX: root.screwDiameter / 2
                    startY: root.screwDiameter * 0.2
                    PathLine {
                        x: root.screwDiameter / 2
                        y: root.screwDiameter * 0.8
                    }
                }
            }

            // Hex: six-sided outline inscribed in the head
            Shape {
                anchors.fill: parent
                visible: root.headStyle === "hex"
                preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
                    ? Shape.CurveRenderer
                    : Shape.GeometryRenderer

                ShapePath {
                    id: hexPath
                    strokeColor: root.headDetailColor
                    strokeWidth: root.headDetailWidth
                    fillColor: "transparent"
                    joinStyle: ShapePath.RoundJoin

                    readonly property real _r: root.screwDiameter * 0.32
                    readonly property real _cx: root.screwDiameter / 2
                    readonly property real _cy: root.screwDiameter / 2

                    startX: hexPath._cx + hexPath._r
                    startY: hexPath._cy
                    PathLine { x: hexPath._cx + hexPath._r * 0.5;  y: hexPath._cy + hexPath._r * 0.8660254 }
                    PathLine { x: hexPath._cx - hexPath._r * 0.5;  y: hexPath._cy + hexPath._r * 0.8660254 }
                    PathLine { x: hexPath._cx - hexPath._r;        y: hexPath._cy }
                    PathLine { x: hexPath._cx - hexPath._r * 0.5;  y: hexPath._cy - hexPath._r * 0.8660254 }
                    PathLine { x: hexPath._cx + hexPath._r * 0.5;  y: hexPath._cy - hexPath._r * 0.8660254 }
                    PathLine { x: hexPath._cx + hexPath._r;        y: hexPath._cy }
                }
            }

            // Dot: small filled circle in the head center (rivet)
            Rectangle {
                visible: root.headStyle === "dot"
                width: root.screwDiameter * 0.35
                height: width
                radius: width / 2
                anchors.centerIn: parent
                color: root.headDetailColor
                antialiasing: true
            }
        }
    }
}
