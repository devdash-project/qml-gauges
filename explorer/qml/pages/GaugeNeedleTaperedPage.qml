import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Primitives 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "GaugeNeedleTapered"
    property string description: "Modern tapered needle with thin tip and wide base. Supports multiple styles, shadow effects, and physics-based spring animation."

    // Property definitions for the editor
    property var properties: [
        // Geometry
        {name: "length", type: "real", min: 50, max: 200, default: 100, category: "Geometry"},
        {name: "needleWidth", type: "real", min: 2, max: 20, default: 4, category: "Geometry"},
        {name: "tipWidth", type: "real", min: 0, max: 10, default: 2, category: "Geometry"},
        {name: "pivotOffset", type: "real", min: 0, max: 30, default: 0, category: "Geometry"},

        // Appearance
        {name: "color", type: "color", default: "#ff6600", category: "Appearance"},
        {name: "borderWidth", type: "real", min: 0, max: 5, default: 0, category: "Appearance"},
        {name: "borderColor", type: "color", default: "transparent", category: "Appearance"},
        {name: "needleOpacity", type: "real", min: 0, max: 1, default: 1.0, category: "Appearance"},

        // Shadow
        {name: "hasShadow", type: "bool", default: false, category: "Shadow"},
        {name: "shadowOffset", type: "real", min: 0, max: 10, default: 2, category: "Shadow"},

        // Animation
        {name: "animated", type: "bool", default: true, category: "Animation"},
        {name: "spring", type: "real", min: 1, max: 10, default: 3.5, category: "Animation"},
        {name: "damping", type: "real", min: 0, max: 1, default: 0.25, category: "Animation"},
        {name: "mass", type: "real", min: 0.1, max: 5, default: 1.0, category: "Animation"},
        {name: "epsilon", type: "real", min: 0.01, max: 1, default: 0.25, category: "Animation"},

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

            GaugeNeedleTapered {
                id: gaugeNeedleTapered
                anchors.centerIn: parent
                width: 300
                height: 300
                length: 120
                needleWidth: 8
                tipWidth: 2
                hasShadow: true
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

            target: gaugeNeedleTapered
            properties: root.properties
        }
    }
}
