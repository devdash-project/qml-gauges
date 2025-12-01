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

    // Property definitions for the editor
    property var properties: [
        // Geometry
        {name: "startAngle", type: "real", min: -360, max: 360, default: -225, category: "Geometry"},
        {name: "sweepAngle", type: "real", min: 0, max: 360, default: 270, category: "Geometry"},
        {name: "radius", type: "real", min: 50, max: 200, default: 150, category: "Geometry"},
        {name: "strokeWidth", type: "real", min: 1, max: 50, default: 20, category: "Geometry"},

        // Appearance
        {name: "strokeColor", type: "color", default: "#00aaff", category: "Appearance"},
        {name: "fillColor", type: "color", default: "transparent", category: "Appearance"},
        {name: "arcOpacity", type: "real", min: 0, max: 1, default: 1.0, category: "Appearance"},
        {name: "antialiasing", type: "bool", default: true, category: "Appearance"},

        // Animation
        {name: "animated", type: "bool", default: true, category: "Animation"},
        {name: "animationDuration", type: "int", min: 0, max: 1000, default: 100, category: "Animation"},

        // Gradient
        {name: "useGradient", type: "bool", default: false, category: "Gradient"},
        {name: "gradientStart", type: "color", default: "#00aaff", category: "Gradient"},
        {name: "gradientStop", type: "color", default: "#ff00aa", category: "Gradient"}
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
        }
    }
}
