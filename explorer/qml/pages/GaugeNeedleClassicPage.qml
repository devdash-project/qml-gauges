import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Primitives 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "GaugeNeedleClassic"
    property string description: "Classic vintage-style gauge needle. Simple solid bar with optional counterweight, perfect for retro gauge aesthetics."

    // Property definitions for the editor
    property var properties: [
        // Geometry
        {name: "length", type: "real", min: 50, max: 200, default: 100, category: "Geometry"},
        {name: "needleWidth", type: "real", min: 1, max: 10, default: 3, category: "Geometry"},
        {name: "counterweightRadius", type: "real", min: 0, max: 20, default: 0, category: "Geometry"},

        // Appearance
        {name: "color", type: "color", default: "#000000", category: "Appearance"},
        {name: "borderWidth", type: "real", min: 0, max: 5, default: 0, category: "Appearance"},
        {name: "borderColor", type: "color", default: "transparent", category: "Appearance"},
        {name: "needleOpacity", type: "real", min: 0, max: 1, default: 1.0, category: "Appearance"},

        // Animation
        {name: "animated", type: "bool", default: true, category: "Animation"},
        {name: "spring", type: "real", min: 1, max: 10, default: 3.5, category: "Animation"},
        {name: "damping", type: "real", min: 0, max: 1, default: 0.25, category: "Animation"},
        {name: "mass", type: "real", min: 0.1, max: 5, default: 1.0, category: "Animation"},
        {name: "epsilon", type: "real", min: 0.01, max: 1, default: 0.25, category: "Animation"}
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

            GaugeNeedleClassic {
                id: gaugeNeedleClassic
                anchors.centerIn: parent
                width: 300
                height: 300
                length: 120
                color: "#cc0000"
                counterweightRadius: 8
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

            target: gaugeNeedleClassic
            properties: root.properties
        }
    }
}
