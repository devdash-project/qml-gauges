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

    // Property definitions for the editor
    property var properties: [
        // Geometry
        {name: "outerRadius", type: "real", min: 50, max: 250, default: 200, category: "Geometry"},
        {name: "innerRadius", type: "real", min: 40, max: 240, default: 190, category: "Geometry"},
        {name: "borderWidth", type: "real", min: 0, max: 10, default: 0, category: "Geometry"},

        // Appearance
        {name: "color", type: "color", default: "#444444", category: "Appearance"},
        {name: "borderColor", type: "color", default: "#555555", category: "Appearance"},
        {name: "bezelOpacity", type: "real", min: 0, max: 1, default: 1.0, category: "Appearance"},

        // Chrome Style
        {name: "chromeHighlight", type: "color", default: "#888888", category: "Chrome Style"},
        {name: "chromeShadow", type: "color", default: "#222222", category: "Chrome Style"},

        // Advanced
        {name: "antialiasing", type: "bool", default: true, category: "Advanced"}
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
        }
    }
}
