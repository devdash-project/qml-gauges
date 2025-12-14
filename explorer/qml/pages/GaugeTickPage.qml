import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Primitives 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "GaugeTick"
    property string description: "Individual tick mark primitive for gauge scales. Supports multiple shapes, gradients, glow effects, and shadows."

    // State server for MCP integration (passed to PropertyPanel)
    property var stateServer: null

    // Expose property panel for external access
    property alias propertyPanel: propertyPanel

    // Property definitions for the editor (with descriptions for documentation panel)
    property var properties: [
        // Position
        {name: "angle", type: "real", min: -180, max: 180, default: 0, category: "Position",
         description: "Rotation angle in degrees. 0\u00B0 points to 3 o'clock, positive values rotate clockwise. Use -135\u00B0 for typical gauge start (7:30 position)."},
        {name: "distanceFromCenter", type: "real", min: 50, max: 200, default: 100, category: "Position",
         description: "Radius from gauge center to the tick's outer edge (in pixels). The tick extends inward from this point by 'length' pixels."},

        // Geometry
        {name: "length", type: "real", min: 5, max: 40, default: 15, category: "Geometry",
         description: "How far the tick extends inward from distanceFromCenter (in pixels). Major ticks are typically 15px, minor ticks 8px."},
        {name: "tickWidth", type: "real", min: 1, max: 10, default: 3, category: "Geometry",
         description: "Thickness of the tick mark (in pixels). Major ticks are typically 3px, minor ticks 2px."},
        {name: "tickShape", type: "enum", options: ["rectangle", "block", "triangle", "rounded-dot", "chevron"], default: "rectangle", category: "Geometry",
         description: "Visual style of the tick. Rectangle is standard with optional rounded ends, block has flat ends, triangle points inward, rounded-dot has a circle at outer end, chevron is V-shaped."},

        // Appearance
        {name: "color", type: "color", default: "#888888", category: "Appearance",
         description: "Base color of the tick mark. Used as solid fill when gradient is disabled."},
        {name: "tickOpacity", type: "real", min: 0, max: 1, default: 1.0, category: "Appearance",
         description: "Overall opacity of the tick mark including any effects. 0 = invisible, 1 = fully opaque."},
        {name: "roundedEnds", type: "bool", default: true, category: "Appearance",
         description: "When true, rectangle ticks have rounded caps instead of flat ends. Only applies to 'rectangle' tickShape."},

        // Gradient
        {name: "hasGradient", type: "bool", default: false, category: "Gradient",
         description: "Enable gradient fill from outer edge to inner end. Creates depth effect on tick marks."},
        {name: "gradientStart", type: "color", default: "#888888", category: "Gradient",
         description: "Color at the outer edge of the tick (at distanceFromCenter). Typically the brighter color."},
        {name: "gradientEnd", type: "color", default: "#444444", category: "Gradient",
         description: "Color at the inner end of the tick. Typically darker to create depth illusion."},

        // Glow
        {name: "hasGlow", type: "bool", default: false, category: "Glow",
         description: "Add luminous blur effect around the tick. Simulates backlit gauges with glowing/luminous paint."},
        {name: "glowColor", type: "color", default: "#888888", category: "Glow",
         description: "Color of the glow effect. Often matches the tick color for a natural luminous appearance."},
        {name: "glowBlur", type: "real", min: 0, max: 1, default: 0.4, category: "Glow",
         description: "Blur intensity for the glow effect. Higher values create a softer, more diffuse glow."},

        // Shadow
        {name: "hasShadow", type: "bool", default: false, category: "Shadow",
         description: "Add drop shadow for 3D depth effect. Makes tick appear raised from the gauge face."},
        {name: "shadowColor", type: "color", default: "#000000", category: "Shadow",
         description: "Color of the drop shadow. Black is typical, but can be tinted to match gauge theme."},
        {name: "shadowOffsetX", type: "real", min: -10, max: 10, default: 2, category: "Shadow",
         description: "Horizontal offset of shadow (in pixels). Positive values cast shadow to the right."},
        {name: "shadowOffsetY", type: "real", min: -10, max: 10, default: 2, category: "Shadow",
         description: "Vertical offset of shadow (in pixels). Positive values cast shadow downward."},
        {name: "shadowBlur", type: "real", min: 0, max: 1, default: 0.25, category: "Shadow",
         description: "Blur intensity of the shadow. Higher values create softer, more diffuse shadows."},
        {name: "shadowOpacity", type: "real", min: 0, max: 1, default: 0.5, category: "Shadow",
         description: "Opacity of the shadow. Lower values create more subtle shadows."},

        // Inner Circle
        {name: "showInnerCircle", type: "bool", default: false, category: "Inner Circle",
         description: "Display a decorative dot at the tick's inner end. Classic vintage gauge style seen on Speedhut and AutoMeter gauges."},
        {name: "innerCircleDiameter", type: "real", min: 2, max: 20, default: 6, category: "Inner Circle",
         description: "Diameter of the inner circle decoration (in pixels). Typically 1.5-2x the tick width."},
        {name: "innerCircleColor", type: "color", default: "#888888", category: "Inner Circle",
         description: "Color of the inner circle. Often matches tick color, or uses accent color for emphasis."}
    ]

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Preview area (60% width)
        PreviewArea {
            id: previewArea
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width * 0.6
            properties: root.properties

            Item {
                anchors.centerIn: parent
                width: 300
                height: 300

                // Reference circle to show positioning
                Rectangle {
                    anchors.centerIn: parent
                    width: gaugeTick.distanceFromCenter * 2
                    height: gaugeTick.distanceFromCenter * 2
                    radius: width / 2
                    color: "transparent"
                    border.color: "#333333"
                    border.width: 1
                }

                GaugeTick {
                    id: gaugeTick
                    anchors.fill: parent
                    distanceFromCenter: 120
                    length: 20
                    tickWidth: 4
                    showInnerCircle: true

                    // Animate angle based on preview animation value
                    angle: -135 + (previewArea.animationValue * 2.7)
                }
            }
        }

        // Property panel (40% width)
        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: gaugeTick
            properties: root.properties
            stateServer: root.stateServer
        }
    }
}
