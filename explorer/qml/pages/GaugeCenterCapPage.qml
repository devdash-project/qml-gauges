import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Primitives 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "GaugeCenterCap"
    property string description: "Center cap primitive that covers the gauge needle pivot point. Supports solid colors and metallic gradients."

    // State server for MCP integration (passed to PropertyPanel)
    property var stateServer: null

    // Expose property panel for external access
    property alias propertyPanel: propertyPanel

    // Property definitions for the editor (with descriptions for documentation panel)
    property var properties: [
        // Geometry
        {name: "diameter", type: "real", min: 10, max: 100, default: 20, category: "Geometry",
         description: "Diameter of the center cap in pixels. Should be sized to cover the needle pivot point."},
        {name: "borderWidth", type: "real", min: 0, max: 10, default: 2, category: "Geometry",
         description: "Width of the cap border stroke in pixels. Adds definition around the cap edge."},

        // Appearance
        {name: "color", type: "color", default: "#444444", category: "Appearance",
         description: "Base fill color of the center cap. Metallic colors (silver, chrome, black) are typical."},
        {name: "borderColor", type: "color", default: "#666666", category: "Appearance",
         description: "Color of the cap border stroke. Often slightly lighter than cap color for highlight effect."},
        {name: "capOpacity", type: "real", min: 0, max: 1, default: 1.0, category: "Appearance",
         description: "Overall opacity of the center cap. 0 = invisible, 1 = fully opaque."},

        // Gradient
        {name: "hasGradient", type: "bool", default: false, category: "Gradient",
         description: "Enable vertical gradient for metallic/3D appearance. Simulates dome or spherical cap."},
        {name: "gradientTop", type: "color", default: "#666666", category: "Gradient",
         description: "Color at the top of the cap (light reflection). Typically lighter."},
        {name: "gradientBottom", type: "color", default: "#333333", category: "Gradient",
         description: "Color at the bottom of the cap (shadow area). Typically darker."},

        // Advanced
        {name: "antialiasing", type: "bool", default: true, category: "Advanced",
         description: "Enable smooth edge rendering. Disable for pixel-perfect but jagged edges."}
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

            GaugeCenterCap {
                id: gaugeCenterCap
                anchors.centerIn: parent
                width: 100
                height: 100
                diameter: 60
                hasGradient: true
            }
        }

        // Property panel (40% width)
        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: gaugeCenterCap
            properties: root.properties
            stateServer: root.stateServer
        }
    }
}
