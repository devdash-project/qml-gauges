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

    // Property definitions for the editor (with descriptions for documentation panel)
    property var properties: [
        // Value
        {name: "value", type: "real", min: 0, max: 999999, default: 0, category: "Value",
         description: "Current numeric value to display. Digits roll smoothly during value changes."},
        {name: "digitCount", type: "int", min: 3, max: 10, default: 6, category: "Value",
         description: "Total number of digit positions including decimal places. E.g., 6 for '12345.6'."},
        {name: "decimalPlaces", type: "int", min: 0, max: 3, default: 1, category: "Value",
         description: "Number of digits after the decimal point. 0 for whole numbers, 1 for tenths."},
        {name: "label", type: "string", default: "", category: "Value",
         description: "Description label shown above the counter. E.g., 'ENGINE HOURS', 'MILES', 'TRIP'."},

        // Colors
        {name: "backgroundColor", type: "color", default: "#0c0c0c", category: "Colors",
         description: "Background color of the digit windows. Typically black for classic odometer look."},
        {name: "digitColor", type: "color", default: "#f8f8f8", category: "Colors",
         description: "Color of the digit text. White or off-white for visibility on dark background."},
        {name: "frameColor", type: "color", default: "#2a2a2a", category: "Colors",
         description: "Color of the frame/housing around the digit windows."},
        {name: "labelColor", type: "color", default: "#888888", category: "Colors",
         description: "Color of the description label text. Typically muted/gray."},

        // Typography
        {name: "digitFontSize", type: "int", min: 16, max: 64, default: 32, category: "Typography",
         description: "Font size for the rolling digits in pixels."},
        {name: "labelFontSize", type: "int", min: 8, max: 24, default: 12, category: "Typography",
         description: "Font size for the description label in pixels."}
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
