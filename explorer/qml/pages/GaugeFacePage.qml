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

    // Property definitions for the editor
    property var properties: [
        // Geometry
        {name: "diameter", type: "real", min: 100, max: 500, default: 380, category: "Geometry"},
        {name: "borderWidth", type: "real", min: 0, max: 20, default: 0, category: "Geometry"},

        // Appearance
        {name: "color", type: "color", default: "#222222", category: "Appearance"},
        {name: "borderColor", type: "color", default: "#444444", category: "Appearance"},
        {name: "faceOpacity", type: "real", min: 0, max: 1, default: 1.0, category: "Appearance"},

        // Gradient
        {name: "useGradient", type: "bool", default: false, category: "Gradient"},
        {name: "gradientCenter", type: "color", default: "#222222", category: "Gradient"},
        {name: "gradientEdge", type: "color", default: "#111111", category: "Gradient"},

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
        }
    }
}
