import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges 1.0
import "../components"

Item {
    id: root

    property string title: "IndustrialGauge"
    property string description: "Industrial / military-aesthetic preset. Painted matte face, cream chevron ticks, oxidized-red zone, painted needle with drop shadow. No value arc, no glow."

    property var stateServer: null

    property alias propertyPanel: propertyPanel

    property var properties: [
        // Value
        {name: "value", type: "real", min: 0, max: 10000, default: 0, category: "Value",
         description: "Current value displayed by the gauge."},
        {name: "minValue", type: "real", min: 0, max: 1000, default: 0, category: "Value",
         description: "Minimum value of the gauge range."},
        {name: "maxValue", type: "real", min: 100, max: 10000, default: 8000, category: "Value",
         description: "Maximum value of the gauge range."},
        {name: "label", type: "string", default: "TACH", category: "Value",
         description: "Label rendered inside the dial face."},
        {name: "unit", type: "string", default: "RPM", category: "Value",
         description: "Unit (unused by template visually; reserved for future readout)."},

        // Thresholds
        {name: "warningThreshold", type: "real", min: 0, max: 10000, default: 6000, category: "Thresholds",
         description: "Value at which warning starts. IndustrialGauge does not change colors at this threshold; reserved for downstream use."},
        {name: "redlineStart", type: "real", min: 0, max: 10000, default: 6500, category: "Thresholds",
         description: "Value where redline zone begins. Shows the oxidized-red zone arc."},

        // Geometry
        {name: "startAngle", type: "real", min: -360, max: 360, default: -225, category: "Geometry",
         description: "Starting angle in degrees."},
        {name: "sweepAngle", type: "real", min: 0, max: 360, default: 270, category: "Geometry",
         description: "Total arc span in degrees."},

        // Ticks
        {name: "majorTickInterval", type: "real", min: 1, max: 2000, default: 1000, category: "Ticks",
         description: "Value interval between major ticks."},
        {name: "minorTickInterval", type: "real", min: 0, max: 500, default: 200, category: "Ticks",
         description: "Value interval between minor ticks (0 disables)."},
        {name: "labelDivisor", type: "real", min: 1, max: 1000, default: 1000, category: "Ticks",
         description: "Divides displayed label values (e.g. 1000 → '8' for 8000)."},

        // Aesthetic overrides
        {name: "faceColor", type: "color", default: "#0a0905", category: "Appearance",
         description: "Painted face plate fill."},
        {name: "bezelColor", type: "color", default: "#1a1815", category: "Appearance",
         description: "Bezel and hub disc fill."},
        {name: "tickColor", type: "color", default: "#e8e4d8", category: "Appearance",
         description: "Cream paint color for ticks, numerals, and label."},
        {name: "needleColor", type: "color", default: "#d4cfc0", category: "Appearance",
         description: "Painted needle body color."},
        {name: "redlineColor", type: "color", default: "#7a1f15", category: "Appearance",
         description: "Oxidized-red redline zone color."},
        {name: "fontFamily", type: "string", default: "DIN, DIN 1451, sans-serif", category: "Appearance",
         description: "Font family fallback chain. FontLoader-installed industrial typefaces will take effect automatically."}
    ]

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        PreviewArea {
            id: previewArea
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width * 0.6
            properties: root.properties

            IndustrialGauge {
                id: industrialGauge
                anchors.centerIn: parent
                width: 400
                height: 400
                minValue: 0
                maxValue: 8000
                label: "TACH"
                unit: "RPM"
                warningThreshold: 6000
                redlineStart: 6500
                majorTickInterval: 1000
                minorTickInterval: 200
                labelDivisor: 1000

                value: previewArea.animationValue * 80  // 0-8000
            }
        }

        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: industrialGauge
            properties: root.properties
            stateServer: root.stateServer
        }
    }
}
