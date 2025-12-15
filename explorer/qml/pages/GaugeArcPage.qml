import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import DevDash.Gauges.Primitives 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "GaugeArc"
    property string description: "Atomic arc primitive for gauge components. The foundational building block for value arcs, warning zones, and background tracks."

    // State server for MCP integration (passed to PropertyPanel)
    property var stateServer: null

    // Expose property panel for external access
    property alias propertyPanel: propertyPanel

    // Property definitions for the editor (with descriptions for documentation panel)
    property var properties: [
        // Geometry
        {name: "startAngle", type: "real", min: -360, max: 360, default: -225, category: "Geometry",
         description: "Starting angle in degrees. 0\u00B0 = 3 o'clock, 90\u00B0 = 6 o'clock. Use -225\u00B0 for typical gauge start (7:30 position)."},
        {name: "sweepAngle", type: "real", min: 0, max: 360, default: 270, category: "Geometry",
         description: "Arc length in degrees from startAngle. 270\u00B0 is typical for gauges (7:30 to 4:30). Use 360\u00B0 for full circle."},
        {name: "radius", type: "real", min: 50, max: 200, default: 150, category: "Geometry",
         description: "Distance from center to the middle of the arc stroke (in pixels)."},
        {name: "strokeWidth", type: "real", min: 1, max: 50, default: 20, category: "Geometry",
         description: "Thickness of the arc stroke (in pixels). The arc extends strokeWidth/2 on each side of the radius."},

        // Appearance
        {name: "strokeColor", type: "color", default: "#00aaff", category: "Appearance",
         description: "Color of the arc stroke. Used as solid fill when gradient is disabled."},
        {name: "fillColor", type: "color", default: "transparent", category: "Appearance",
         description: "Fill color for the arc wedge area. Usually 'transparent' for gauge arcs."},
        {name: "arcOpacity", type: "real", min: 0, max: 1, default: 1.0, category: "Appearance",
         description: "Overall opacity of the arc. 0 = invisible, 1 = fully opaque."},
        {name: "antialiasing", type: "bool", default: true, category: "Appearance",
         description: "Enable smooth edge rendering. Disable for pixel-perfect but jagged edges."},

        // Animation
        {name: "animated", type: "bool", default: true, category: "Animation",
         description: "Enable smooth transitions when sweepAngle changes. Creates fluid gauge needle movement."},
        {name: "animationDuration", type: "int", min: 0, max: 1000, default: 100, category: "Animation",
         description: "Duration of sweep animation in milliseconds. Lower = snappier, higher = smoother."},

        // Gradient
        {name: "useGradient", type: "bool", default: false, category: "Gradient",
         description: "Enable gradient fill along the arc. Creates visual depth or value indication."},
        {name: "gradientStart", type: "color", default: "#00aaff", category: "Gradient",
         description: "Color at the start of the arc (at startAngle)."},
        {name: "gradientStop", type: "color", default: "#ff00aa", category: "Gradient",
         description: "Color at the end of the arc (at startAngle + sweepAngle)."}
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

            GaugeArc {
                id: gaugeArc
                anchors.centerIn: parent
                width: 300
                height: 300
                animated: false  // Disable internal animation for explorer preview

                // Bind to animation value for demonstration
                sweepAngle: previewArea.animationValue * 2.7  // Scale 0-100 to 0-270
            }
        }

        // Property panel (40% width)
        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: gaugeArc
            properties: root.properties
            stateServer: root.stateServer
        }
    }
}
