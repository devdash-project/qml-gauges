import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Primitives 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "GaugeNeedleVelocity"
    property string description: "High-fidelity 3D needle with gradient shading, dark outline, and realistic lighting. Based on Classic Instruments Velocity style."

    // Property definitions for the editor
    property var properties: [
        // Geometry
        {name: "length", type: "real", min: 50, max: 200, default: 120, category: "Geometry"},
        {name: "needleWidth", type: "real", min: 4, max: 30, default: 14, category: "Geometry"},
        {name: "tailLength", type: "real", min: 0, max: 50, default: 25, category: "Geometry"},

        // Hub
        {name: "hubRadius", type: "real", min: 0, max: 40, default: 0, category: "Hub"},
        {name: "hubShadow", type: "bool", default: true, category: "Hub"},
        {name: "shadowOffset", type: "real", min: 0, max: 10, default: 3, category: "Hub"},

        // Appearance
        {name: "color", type: "color", default: "#ff6600", category: "Appearance"},
        {name: "outlineColor", type: "color", default: "#1a1a1a", category: "Appearance"},
        {name: "outlineWidth", type: "real", min: 0, max: 5, default: 1.5, category: "Appearance"},

        // Lighting
        {name: "highlightIntensity", type: "real", min: 1.0, max: 2.0, default: 1.3, category: "Lighting"},
        {name: "shadowIntensity", type: "real", min: 1.0, max: 2.0, default: 1.3, category: "Lighting"},

        // Animation
        {name: "animated", type: "bool", default: true, category: "Animation"},
        {name: "spring", type: "real", min: 1, max: 10, default: 3.5, category: "Animation"},
        {name: "damping", type: "real", min: 0, max: 1, default: 0.25, category: "Animation"},
        {name: "mass", type: "real", min: 0.1, max: 5, default: 1.0, category: "Animation"},

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

            GaugeNeedleVelocity {
                id: gaugeNeedleVelocity
                anchors.centerIn: parent
                width: 300
                height: 300
                length: 120
                needleWidth: 14
                tailLength: 25
                color: "#ff6600"
                animated: false  // Disable internal spring animation for explorer preview

                // Animate angle based on preview animation value
                angle: -135 + (previewArea.animationValue * 2.7)  // -135 to +135 degrees
            }
        }

        // Property panel (40% width)
        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: gaugeNeedleVelocity
            properties: root.properties
        }
    }
}
