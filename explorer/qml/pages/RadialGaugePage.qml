import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "RadialGauge"
    property string description: "Complete analog radial gauge template. Composes all primitives and compounds into a professional gauge display with extensive customization."

    // Property definitions for the editor
    property var properties: [
        // Value
        {name: "value", type: "real", min: 0, max: 10000, default: 0, category: "Value"},
        {name: "minValue", type: "real", min: 0, max: 1000, default: 0, category: "Value"},
        {name: "maxValue", type: "real", min: 100, max: 10000, default: 100, category: "Value"},
        {name: "label", type: "string", default: "", category: "Value"},
        {name: "unit", type: "string", default: "", category: "Value"},

        // Thresholds
        {name: "warningThreshold", type: "real", min: 0, max: 10000, default: 100, category: "Thresholds"},
        {name: "redlineStart", type: "real", min: 0, max: 10000, default: 100, category: "Thresholds"},

        // Geometry
        {name: "startAngle", type: "real", min: -360, max: 360, default: -225, category: "Geometry"},
        {name: "sweepAngle", type: "real", min: 0, max: 360, default: 270, category: "Geometry"},

        // Feature Toggles
        {name: "showFace", type: "bool", default: true, category: "Features"},
        {name: "showBackgroundArc", type: "bool", default: true, category: "Features"},
        {name: "showValueArc", type: "bool", default: true, category: "Features"},
        {name: "showRedline", type: "bool", default: true, category: "Features"},
        {name: "showTicks", type: "bool", default: true, category: "Features"},
        {name: "showNeedle", type: "bool", default: true, category: "Features"},
        {name: "showCenterCap", type: "bool", default: true, category: "Features"},
        {name: "showDigitalReadout", type: "bool", default: false, category: "Features"},
        {name: "showBezel", type: "bool", default: false, category: "Features"},

        // Tick Configuration
        {name: "majorTickInterval", type: "real", min: 1, max: 2000, default: 10, category: "Ticks"},
        {name: "minorTickInterval", type: "real", min: 0, max: 500, default: 2, category: "Ticks"},
        {name: "labelDivisor", type: "real", min: 1, max: 1000, default: 1, category: "Ticks"},
        {name: "showTickInnerCircles", type: "bool", default: false, category: "Ticks"},
        {name: "tickInnerCircleDiameter", type: "real", min: 2, max: 12, default: 6, category: "Ticks"},
        {name: "showTickLabelOutline", type: "bool", default: false, category: "Ticks"},

        // Colors
        {name: "faceColor", type: "color", default: "#1a1a1a", category: "Colors"},
        {name: "bezelColor", type: "color", default: "#2a2a2a", category: "Colors"},
        {name: "backgroundArcColor", type: "color", default: "#333333", category: "Colors"},
        {name: "valueArcColor", type: "color", default: "#00aaff", category: "Colors"},
        {name: "needleColor", type: "color", default: "#ffffff", category: "Colors"},
        {name: "tickColor", type: "color", default: "#888888", category: "Colors"},
        {name: "redlineColor", type: "color", default: "#aa2222", category: "Colors"},
        {name: "warningColor", type: "color", default: "#ffaa00", category: "Colors"},
        {name: "criticalColor", type: "color", default: "#ff4444", category: "Colors"},

        // Needle
        {name: "needleWidth", type: "real", min: 2, max: 12, default: 4, category: "Needle"},
        {name: "needleTipWidth", type: "real", min: 0, max: 8, default: 2, category: "Needle"},
        {name: "needleBorderWidth", type: "real", min: 0, max: 4, default: 0, category: "Needle"},
        {name: "needleBorderColor", type: "color", default: "transparent", category: "Needle"},
        {name: "needlePivotOffset", type: "real", min: 0, max: 30, default: 0, category: "Needle"},

        // Center Cap
        {name: "centerCapDiameter", type: "real", min: 10, max: 60, default: 30, category: "Center Cap"},
        {name: "centerCapColor", type: "color", default: "#1a1a1a", category: "Center Cap"},
        {name: "centerCapBorderColor", type: "color", default: "#ffffff", category: "Center Cap"},
        {name: "centerCapBorderWidth", type: "real", min: 0, max: 6, default: 2, category: "Center Cap"},
        {name: "centerCapGradient", type: "bool", default: false, category: "Center Cap"},

        // Typography
        {name: "tickLabelFontSize", type: "int", min: 10, max: 32, default: 18, category: "Typography"},
        {name: "gaugeLabelFontSize", type: "int", min: 10, max: 32, default: 18, category: "Typography"}
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

            RadialGauge {
                id: radialGauge
                anchors.centerIn: parent
                width: 400
                height: 400
                minValue: 0
                maxValue: 8000
                label: "RPM"
                unit: "RPM"
                warningThreshold: 6000
                redlineStart: 6500
                majorTickInterval: 1000
                minorTickInterval: 200
                labelDivisor: 1000
                showDigitalReadout: true

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

            target: radialGauge
            properties: root.properties
        }
    }
}
