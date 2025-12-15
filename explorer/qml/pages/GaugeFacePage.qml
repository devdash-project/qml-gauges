import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Primitives 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "GaugeFace"
    property string description: "Background face/dial plate primitive. Supports solid colors, gradients, and configurable opacity for video overlay mode."

    // State server for MCP integration (passed to PropertyPanel)
    property var stateServer: null

    // Expose property panel for external access
    property alias propertyPanel: propertyPanel

    // Property definitions for the editor (with descriptions for documentation panel)
    property var properties: [
        // Geometry
        {name: "diameter", type: "real", min: 100, max: 500, default: 380, category: "Geometry",
         description: "Diameter of the gauge face circle in pixels. Should be slightly smaller than the bezel inner radius."},
        {name: "borderWidth", type: "real", min: 0, max: 20, default: 0, category: "Geometry",
         description: "Width of the face border stroke in pixels. Set to 0 for no border."},

        // Appearance
        {name: "color", type: "color", default: "#222222", category: "Appearance",
         description: "Base fill color of the gauge face. Dark colors (black/charcoal) are typical for automotive gauges."},
        {name: "borderColor", type: "color", default: "#444444", category: "Appearance",
         description: "Color of the face border stroke when borderWidth > 0."},
        {name: "faceOpacity", type: "real", min: 0, max: 1, default: 1.0, category: "Appearance",
         description: "Face opacity for video overlay mode. Set < 1 to allow background video to show through."},

        // Gradient
        {name: "useGradient", type: "bool", default: false, category: "Gradient",
         description: "Enable radial gradient fill from center to edge. Creates depth effect on the face."},
        {name: "gradientCenter", type: "color", default: "#222222", category: "Gradient",
         description: "Color at the center of the radial gradient. Typically lighter to simulate dome lighting."},
        {name: "gradientEdge", type: "color", default: "#111111", category: "Gradient",
         description: "Color at the edge of the radial gradient. Typically darker for depth effect."},

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

            GaugeFace {
                id: gaugeFace
                anchors.centerIn: parent
                width: 400
                height: 400
            }
        }

        // Property panel (40% width)
        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: gaugeFace
            properties: root.properties
            stateServer: root.stateServer
        }
    }
}
