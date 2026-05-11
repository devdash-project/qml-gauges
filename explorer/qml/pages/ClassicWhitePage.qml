import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges 1.0
import DevDash.Gauges.Theme 1.0
import "../components"

/**
 * @brief Explorer page demonstrating the "classicWhite" GaugeTheme preset.
 *
 * Vintage white-face aesthetic — a cool pearl-white dial in a thick matte-black
 * bezel, bold orange-red geometric numerals and ticks, an orange-red painted
 * needle with form shading, and a small orange centre hub. No value arc, no
 * glass, no glow. Influences include classic aftermarket white-face speedos;
 * the library reproduces none of those products' wordmarks — the `scriptLabel`
 * and `brandLabel` slots are left empty for the user to fill.
 *
 * Renders a bare RadialGauge and activates the preset on page load. (The
 * active preset is a global; it simply persists until another page changes it.)
 */
Item {
    id: root

    property string title: "ClassicWhite"
    property string description: "RadialGauge under the 'classicWhite' GaugeTheme preset — pearl-white dial, matte-black bezel, orange-red numerals and needle, small orange hub. Needle-only (no value arc). scriptLabel / brandLabel are empty by default; type into them in the panel to place your own wordmark / branding."

    property var stateServer: null

    property alias propertyPanel: propertyPanel

    // Activate the classic-white preset. No destruction-time restore: StackView
    // completes the next page before destroying this one, so resetting here
    // would clobber the incoming page's choice. Each preset-demo page sets its own.
    Component.onCompleted: GaugeTheme.setTheme("classicWhite")

    property var properties: [
        // Value
        {name: "value", type: "real", min: 0, max: 200, default: 0, category: "Value",
         description: "Current value displayed by the gauge."},
        {name: "minValue", type: "real", min: 0, max: 100, default: 0, category: "Value",
         description: "Minimum value of the gauge range."},
        {name: "maxValue", type: "real", min: 20, max: 300, default: 160, category: "Value",
         description: "Maximum value of the gauge range."},
        {name: "label", type: "string", default: "MPH", category: "Value",
         description: "Label displayed below the dial."},
        {name: "unit", type: "string", default: "mph", category: "Value",
         description: "Unit (used by the optional digital readout)."},

        // Face text (decorative slots — empty ships nothing; the library has no wordmark of its own)
        {name: "scriptLabel", type: "string", default: "", category: "Face Text",
         description: "Decorative script word just below the dial centre, under the needle — the spot a vintage-gauge wordmark traditionally sits. Empty by default; supply your own word."},
        {name: "brandLabel", type: "string", default: "", category: "Face Text",
         description: "Small branding line low on the dial face near 6 o'clock. Empty by default; supply your own text."},

        // Geometry
        {name: "startAngle", type: "real", min: -360, max: 360, default: -225, category: "Geometry",
         description: "Starting angle in degrees. -225 = 7:30 position."},
        {name: "sweepAngle", type: "real", min: 0, max: 360, default: 270, category: "Geometry",
         description: "Total arc span in degrees."},

        // Features
        {name: "showValueArc", type: "bool", default: false, category: "Features",
         description: "Show the colored value arc. Off for the classic look — the needle alone indicates value."},
        {name: "showBackgroundArc", type: "bool", default: false, category: "Features",
         description: "Show the track arc behind the value arc."},
        {name: "showRedline", type: "bool", default: false, category: "Features",
         description: "Show the redline zone arc (off by default for a plain speedo)."},
        {name: "showBezel", type: "bool", default: true, category: "Features",
         description: "Show the thick matte-black bezel ring."},
        {name: "showDigitalReadout", type: "bool", default: false, category: "Features",
         description: "Show the numeric digital readout."},

        // Ticks
        {name: "majorTickInterval", type: "real", min: 1, max: 100, default: 20, category: "Ticks",
         description: "Value interval between major (numbered) ticks."},
        {name: "minorTickInterval", type: "real", min: 0, max: 50, default: 5, category: "Ticks",
         description: "Value interval between minor ticks. 0 disables."},
        {name: "labelDivisor", type: "real", min: 1, max: 1000, default: 1, category: "Ticks",
         description: "Divides label values for display."},
        {name: "tickLabelFontSize", type: "int", min: 10, max: 32, default: 22, category: "Ticks",
         description: "Font size for the numerals around the dial."},

        // Needle
        {name: "needleGradient", type: "bool", default: true, category: "Needle",
         description: "Form shading on the painted needle."},
        {name: "needleShadow", type: "bool", default: true, category: "Needle",
         description: "Drop shadow under the needle."},
        {name: "needleRearRatio", type: "real", min: 0.0, max: 0.5, default: 0.12, category: "Needle",
         description: "Length of the small counterweight tail behind the hub, as a fraction of the front length."},

        // Colors (theme-token defaults; override per instance to verify overrides win)
        {name: "faceColor", type: "color", default: "#f4f3f0", category: "Colors",
         description: "Pearl-white dial fill. Defaults to GaugeTheme.colors.surface."},
        {name: "bezelColor", type: "color", default: "#171717", category: "Colors",
         description: "Matte-black bezel ring fill. Defaults to GaugeTheme.colors.surfaceElevated."},
        {name: "needleColor", type: "color", default: "#d44820", category: "Colors",
         description: "Orange-red painted needle colour. Defaults to GaugeTheme.colors.primary."},
        {name: "tickColor", type: "color", default: "#c2401c", category: "Colors",
         description: "Orange-red numeral / tick / label colour. Defaults to GaugeTheme.colors.foreground."},
        {name: "redlineColor", type: "color", default: "#8f2c14", category: "Colors",
         description: "Redline zone colour (only visible when showRedline is on). Defaults to GaugeTheme.colors.critical."}
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
                id: classicGauge
                anchors.centerIn: parent
                width: 400
                height: 400

                minValue: 0
                maxValue: 160
                label: "MPH"
                unit: "mph"
                majorTickInterval: 20
                minorTickInterval: 5
                labelDivisor: 1
                tickLabelFontSize: 22

                // Needle-only, no arcs, thick bezel.
                showValueArc: false
                showBackgroundArc: false
                showRedline: false
                showBezel: true

                // Painted needle with a small counterweight tail and a solid
                // orange centre hub (no chrome ring).
                needleShape: "tapered"
                needleHeadTipShape: "pointed"
                needleGradient: true
                needleGradientStyle: "cylinder"
                needleShadow: true
                needleRearRatio: 0.12
                centerCapDiameter: 20
                centerCapColor: GaugeTheme.colors.primary
                centerCapBorderWidth: 0

                value: previewArea.animationValue * 1.6  // 0-160 range
            }
        }

        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: classicGauge
            properties: root.properties
            stateServer: root.stateServer
        }
    }
}
