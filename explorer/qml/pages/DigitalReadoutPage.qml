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

    // State server for MCP integration (passed to PropertyPanel)
    property var stateServer: null

    // Expose property panel for external access
    property alias propertyPanel: propertyPanel

    // Property definitions for the editor (with descriptions for documentation panel)
    property var properties: [
        // Value
        {name: "value", type: "real", min: 0, max: 10000, default: 0, category: "Value",
         description: "Current numeric value to display. Automatically formatted based on precision setting."},
        {name: "unit", type: "string", default: "", category: "Value",
         description: "Unit label displayed below the value. E.g., 'RPM', 'MPH', 'PSI', '°C'."},
        {name: "precision", type: "int", min: 0, max: 3, default: 0, category: "Value",
         description: "Number of decimal places to show. 0 for integers, 1-3 for floating point values."},

        // Thresholds
        {name: "warningThreshold", type: "real", min: 0, max: 10000, default: 6000, category: "Thresholds",
         description: "Value at which display switches to warningColor. Set above maxValue to disable."},
        {name: "criticalThreshold", type: "real", min: 0, max: 10000, default: 7000, category: "Thresholds",
         description: "Value at which display switches to criticalColor. Set above maxValue to disable."},

        // Typography
        {name: "valueFontSize", type: "real", min: 16, max: 96, default: 48, category: "Typography",
         description: "Font size for the main numeric value in pixels."},
        {name: "unitFontSize", type: "real", min: 8, max: 48, default: 24, category: "Typography",
         description: "Font size for the unit label in pixels. Typically smaller than value font."},

        // Colors
        {name: "normalColor", type: "color", default: "#ffffff", category: "Colors",
         description: "Text color in normal operating range (below warningThreshold)."},
        {name: "warningColor", type: "color", default: "#ffaa00", category: "Colors",
         description: "Text color in warning range (warningThreshold to criticalThreshold). Typically amber."},
        {name: "criticalColor", type: "color", default: "#ff4444", category: "Colors",
         description: "Text color in critical range (above criticalThreshold). Typically red."}
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
            stateServer: root.stateServer
        }
    }
}
