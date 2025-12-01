import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Compounds 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "RollingDigitReadout"
    property string description: "Classic mechanical counter with animated rolling digits. Perfect for engine hours, mileage, trip counters, or any cumulative metric."

    // Property definitions for the editor
    property var properties: [
        // Value
        {name: "value", type: "real", min: 0, max: 999999, default: 0, category: "Value"},
        {name: "digitCount", type: "int", min: 3, max: 10, default: 6, category: "Value"},
        {name: "decimalPlaces", type: "int", min: 0, max: 3, default: 1, category: "Value"},
        {name: "label", type: "string", default: "", category: "Value"},

        // Colors
        {name: "backgroundColor", type: "color", default: "#0c0c0c", category: "Colors"},
        {name: "digitColor", type: "color", default: "#f8f8f8", category: "Colors"},
        {name: "frameColor", type: "color", default: "#2a2a2a", category: "Colors"},
        {name: "labelColor", type: "color", default: "#888888", category: "Colors"},

        // Typography
        {name: "digitFontSize", type: "int", min: 16, max: 64, default: 32, category: "Typography"},
        {name: "labelFontSize", type: "int", min: 8, max: 24, default: 12, category: "Typography"}
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

            RollingDigitReadout {
                id: rollingDigitReadout
                anchors.centerIn: parent
                width: 280
                height: 100
                label: "ENGINE HOURS"
                digitCount: 6
                decimalPlaces: 1

                // Animate value based on preview animation value
                value: previewArea.animationValue * 12.345  // Rolling up to ~1234.5
            }
        }

        // Property panel (40% width)
        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: rollingDigitReadout
            properties: root.properties
        }
    }
}
