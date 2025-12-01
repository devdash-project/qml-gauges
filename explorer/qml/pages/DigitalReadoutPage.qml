import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Compounds 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "DigitalReadout"
    property string description: "Digital numeric display with unit label. Supports automatic color changes at warning and critical thresholds."

    // Property definitions for the editor
    property var properties: [
        // Value
        {name: "value", type: "real", min: 0, max: 10000, default: 0, category: "Value"},
        {name: "unit", type: "string", default: "", category: "Value"},
        {name: "precision", type: "int", min: 0, max: 3, default: 0, category: "Value"},

        // Thresholds
        {name: "warningThreshold", type: "real", min: 0, max: 10000, default: 6000, category: "Thresholds"},
        {name: "criticalThreshold", type: "real", min: 0, max: 10000, default: 7000, category: "Thresholds"},

        // Typography
        {name: "valueFontSize", type: "real", min: 16, max: 96, default: 48, category: "Typography"},
        {name: "unitFontSize", type: "real", min: 8, max: 48, default: 24, category: "Typography"},

        // Colors
        {name: "normalColor", type: "color", default: "#ffffff", category: "Colors"},
        {name: "warningColor", type: "color", default: "#ffaa00", category: "Colors"},
        {name: "criticalColor", type: "color", default: "#ff4444", category: "Colors"}
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

            DigitalReadout {
                id: digitalReadout
                anchors.centerIn: parent
                width: 200
                height: 100
                unit: "RPM"
                warningThreshold: 6000
                criticalThreshold: 7000

                // Animate value based on preview animation value (0-8000 RPM range)
                value: previewArea.animationValue * 80
            }
        }

        // Property panel (40% width)
        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: digitalReadout
            properties: root.properties
        }
    }
}
