import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Compounds 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "GaugeValueArc"
    property string description: "Value-driven arc that fills from minValue to current value. Automatically changes color at warning and critical thresholds."

    // Property definitions for the editor
    property var properties: [
        // Value
        {name: "value", type: "real", min: 0, max: 10000, default: 0, category: "Value"},
        {name: "minValue", type: "real", min: 0, max: 1000, default: 0, category: "Value"},
        {name: "maxValue", type: "real", min: 100, max: 10000, default: 100, category: "Value"},

        // Thresholds
        {name: "warningThreshold", type: "real", min: 0, max: 10000, default: 100, category: "Thresholds"},
        {name: "criticalThreshold", type: "real", min: 0, max: 10000, default: 100, category: "Thresholds"},

        // Geometry
        {name: "startAngle", type: "real", min: -360, max: 360, default: -225, category: "Geometry"},
        {name: "totalSweepAngle", type: "real", min: 0, max: 360, default: 270, category: "Geometry"},
        {name: "strokeWidth", type: "real", min: 5, max: 50, default: 20, category: "Geometry"},

        // Colors
        {name: "normalColor", type: "color", default: "#00aaff", category: "Colors"},
        {name: "warningColor", type: "color", default: "#ffaa00", category: "Colors"},
        {name: "criticalColor", type: "color", default: "#ff4444", category: "Colors"},

        // Animation
        {name: "animated", type: "bool", default: true, category: "Animation"},
        {name: "animationVelocity", type: "real", min: 60, max: 720, default: 360, category: "Animation"}
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

            GaugeValueArc {
                id: gaugeValueArc
                anchors.centerIn: parent
                width: 400
                height: 400
                minValue: 0
                maxValue: 8000
                warningThreshold: 6000
                criticalThreshold: 6500
                strokeWidth: 25
                animated: false  // Disable internal animation for explorer preview

                // Animate value based on preview animation value
                value: previewArea.animationValue * 80  // 0-8000 range
            }
        }

        // Property panel (40% width)
        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: gaugeValueArc
            properties: root.properties
        }
    }
}
