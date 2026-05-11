import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges 1.0
import DevDash.Gauges.Theme 1.0
import "../components"

/**
 * @brief Explorer page demonstrating the "industrial" GaugeTheme preset.
 *
 * There is no longer a dedicated IndustrialGauge template — the industrial /
 * military aesthetic now lives entirely in GaugeTheme as the `industrial`
 * preset (warm-black painted surfaces, aged-cream marks, oxidized-red redline,
 * painted needle with a drop shadow). This page renders a bare RadialGauge and
 * activates that preset at page load via GaugeTheme.setTheme("industrial").
 *
 * The page keeps its old sidebar name ("IndustrialGauge") because it remains a
 * useful semantic grouping even though it is implemented as RadialGauge + theme.
 */
Item {
    id: root

    property string title: "IndustrialGauge"
    property string description: "RadialGauge under the 'industrial' GaugeTheme preset. Warm-black painted face, aged-cream ticks, oxidized-red redline zone, painted needle with drop shadow. Value arc / background arc disabled to match the utilitarian look."

    property var stateServer: null

    property alias propertyPanel: propertyPanel

    // Activate the industrial preset for the duration of this page. Other
    // theme-demo pages activate their own preset; this is the default preset
    // so nothing needs to be restored when navigating away.
    Component.onCompleted: GaugeTheme.setTheme("industrial")

    property var properties: [
        // Value
        {name: "value", type: "real", min: 0, max: 10000, default: 0, category: "Value",
         description: "Current value displayed by the gauge."},
        {name: "minValue", type: "real", min: 0, max: 1000, default: 0, category: "Value",
         description: "Minimum value of the gauge range."},
        {name: "maxValue", type: "real", min: 100, max: 10000, default: 8000, category: "Value",
         description: "Maximum value of the gauge range."},
        {name: "label", type: "string", default: "TACH", category: "Value",
         description: "Label rendered below the dial face."},
        {name: "unit", type: "string", default: "RPM", category: "Value",
         description: "Unit (used by the optional digital readout)."},

        // Thresholds
        {name: "warningThreshold", type: "real", min: 0, max: 10000, default: 6000, category: "Thresholds",
         description: "Value at which warning starts. With the industrial preset the tick colors do not change here (the redline zone arc is the cue)."},
        {name: "redlineStart", type: "real", min: 0, max: 10000, default: 6500, category: "Thresholds",
         description: "Value where the redline zone begins. Shows the oxidized-red zone arc."},

        // Geometry
        {name: "startAngle", type: "real", min: -360, max: 360, default: -225, category: "Geometry",
         description: "Starting angle in degrees."},
        {name: "sweepAngle", type: "real", min: 0, max: 360, default: 270, category: "Geometry",
         description: "Total arc span in degrees."},

        // Features
        {name: "showValueArc", type: "bool", default: false, category: "Features",
         description: "Show the colored value arc. Off for the industrial look — the needle alone indicates value."},
        {name: "showBackgroundArc", type: "bool", default: false, category: "Features",
         description: "Show the track arc behind the value arc."},
        {name: "showBezel", type: "bool", default: true, category: "Features",
         description: "Show the bezel ring (matte black via the theme's surfaceElevated token)."},
        {name: "showDigitalReadout", type: "bool", default: false, category: "Features",
         description: "Show numeric digital readout near the bottom of the face."},

        // Ticks
        {name: "majorTickInterval", type: "real", min: 1, max: 2000, default: 1000, category: "Ticks",
         description: "Value interval between major ticks."},
        {name: "minorTickInterval", type: "real", min: 0, max: 500, default: 200, category: "Ticks",
         description: "Value interval between minor ticks (0 disables)."},
        {name: "labelDivisor", type: "real", min: 1, max: 1000, default: 1000, category: "Ticks",
         description: "Divides displayed label values (e.g. 1000 → '8' for 8000)."},

        // Appearance (theme-token defaults; override per instance to verify overrides win)
        {name: "faceColor", type: "color", default: "#0a0905", category: "Appearance",
         description: "Painted face plate fill. Defaults to GaugeTheme.colors.surface; an explicit value here overrides the theme for this gauge."},
        {name: "bezelColor", type: "color", default: "#1a1815", category: "Appearance",
         description: "Bezel ring fill. Defaults to GaugeTheme.colors.surfaceElevated."},
        {name: "tickColor", type: "color", default: "#e8e4d8", category: "Appearance",
         description: "Tick / numeral / label color. Defaults to GaugeTheme.colors.foreground."},
        {name: "needleColor", type: "color", default: "#d4cfc0", category: "Appearance",
         description: "Painted needle body color. Defaults to GaugeTheme.colors.primary."},
        {name: "redlineColor", type: "color", default: "#7a1f15", category: "Appearance",
         description: "Oxidized-red redline zone color. Defaults to GaugeTheme.colors.critical."}
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

            RadialGauge {
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

                // Industrial aesthetic: needle indicates value, no arcs, bezel on.
                showValueArc: false
                showBackgroundArc: false
                showBezel: true
                needleGradient: true
                needleGradientStyle: "cylinder"
                needleShadow: true

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
