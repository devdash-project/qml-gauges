import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Primitives 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "GaugeBezel"
    property string description: "Decorative bezel/frame primitive for gauge exterior. Supports flat, chrome, and textured styles."

    // State server for MCP integration (passed to PropertyPanel)
    property var stateServer: null

    // Expose property panel for external access
    property alias propertyPanel: propertyPanel

    // Property definitions for the editor (with descriptions for documentation panel)
    property var properties: [
        // Geometry
        {name: "outerRadius", type: "real", min: 50, max: 250, default: 200, category: "Geometry",
         description: "Outer edge radius of the bezel ring in pixels. Defines the overall gauge frame size."},
        {name: "innerRadius", type: "real", min: 40, max: 240, default: 190, category: "Geometry",
         description: "Inner edge radius of the bezel ring in pixels. The difference from outerRadius determines bezel thickness."},
        {name: "borderWidth", type: "real", min: 0, max: 10, default: 0, category: "Geometry",
         description: "Width of the outer border stroke in pixels. Set to 0 for no border."},

        // Appearance
        {name: "color", type: "color", default: "#444444", category: "Appearance",
         description: "Base fill color of the bezel ring. Used for flat style or as base for chrome gradient."},
        {name: "borderColor", type: "color", default: "#555555", category: "Appearance",
         description: "Color of the outer border stroke when borderWidth > 0."},
        {name: "bezelOpacity", type: "real", min: 0, max: 1, default: 1.0, category: "Appearance",
         description: "Overall opacity of the bezel. 0 = invisible, 1 = fully opaque."},

        // Chrome Style
        {name: "chromeHighlight", type: "color", default: "#888888", category: "Chrome Style",
         description: "Lighter color for chrome gradient highlight (top-left light reflection effect)."},
        {name: "chromeShadow", type: "color", default: "#222222", category: "Chrome Style",
         description: "Darker color for chrome gradient shadow (bottom-right shadow effect)."},

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

            GaugeBezel {
                id: gaugeBezel
                anchors.centerIn: parent
                width: 400
                height: 400
                style: "chrome"
            }
        }

        // Property panel (40% width)
        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: gaugeBezel
            properties: root.properties
            stateServer: root.stateServer
        }
    }
}
