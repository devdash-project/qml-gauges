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

    // Property definitions for the editor
    property var properties: [
        // Geometry
        {name: "diameter", type: "real", min: 10, max: 100, default: 20, category: "Geometry"},
        {name: "borderWidth", type: "real", min: 0, max: 10, default: 2, category: "Geometry"},

        // Appearance
        {name: "color", type: "color", default: "#444444", category: "Appearance"},
        {name: "borderColor", type: "color", default: "#666666", category: "Appearance"},
        {name: "capOpacity", type: "real", min: 0, max: 1, default: 1.0, category: "Appearance"},

        // Gradient
        {name: "hasGradient", type: "bool", default: false, category: "Gradient"},
        {name: "gradientTop", type: "color", default: "#666666", category: "Gradient"},
        {name: "gradientBottom", type: "color", default: "#333333", category: "Gradient"},

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
        }
    }
}
