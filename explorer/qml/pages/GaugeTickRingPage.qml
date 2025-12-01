import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Compounds 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "GaugeTickRing"
    property string description: "Complete ring of major and minor tick marks with labels. Supports warning/critical zone coloring and classic gauge decorations."

    // Property definitions for the editor
    property var properties: [
        // Value Range
        {name: "minValue", type: "real", min: 0, max: 1000, default: 0, category: "Value Range"},
        {name: "maxValue", type: "real", min: 100, max: 10000, default: 100, category: "Value Range"},
        {name: "majorTickInterval", type: "real", min: 1, max: 1000, default: 10, category: "Value Range"},
        {name: "minorTickInterval", type: "real", min: 0, max: 100, default: 2, category: "Value Range"},
        {name: "labelDivisor", type: "real", min: 1, max: 1000, default: 1, category: "Value Range"},

        // Zones
        {name: "warningStart", type: "real", min: 0, max: 10000, default: 100, category: "Zones"},
        {name: "criticalStart", type: "real", min: 0, max: 10000, default: 100, category: "Zones"},

        // Geometry
        {name: "startAngle", type: "real", min: -360, max: 360, default: -225, category: "Geometry"},
        {name: "sweepAngle", type: "real", min: 0, max: 360, default: 270, category: "Geometry"},
        {name: "majorTickLength", type: "real", min: 5, max: 30, default: 15, category: "Geometry"},
        {name: "majorTickWidth", type: "real", min: 1, max: 5, default: 2, category: "Geometry"},
        {name: "minorTickLength", type: "real", min: 3, max: 20, default: 8, category: "Geometry"},
        {name: "minorTickWidth", type: "real", min: 1, max: 3, default: 1, category: "Geometry"},

        // Colors
        {name: "normalColor", type: "color", default: "#888888", category: "Colors"},
        {name: "warningColor", type: "color", default: "#ffaa00", category: "Colors"},
        {name: "criticalColor", type: "color", default: "#ff4444", category: "Colors"},

        // Typography
        {name: "fontSize", type: "real", min: 8, max: 32, default: 16, category: "Typography"},
        {name: "showLabelOutline", type: "bool", default: false, category: "Typography"},
        {name: "labelOutlineColor", type: "color", default: "#000000", category: "Typography"},

        // Decorations
        {name: "showInnerCircles", type: "bool", default: false, category: "Decorations"},
        {name: "innerCircleDiameter", type: "real", min: 2, max: 12, default: 6, category: "Decorations"}
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

            GaugeTickRing {
                id: gaugeTickRing
                anchors.centerIn: parent
                width: 400
                height: 400
                minValue: 0
                maxValue: 8000
                majorTickInterval: 1000
                minorTickInterval: 200
                labelDivisor: 1000
                warningStart: 6000
                criticalStart: 6500
            }
        }

        // Property panel (40% width)
        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: gaugeTickRing
            properties: root.properties
        }
    }
}
