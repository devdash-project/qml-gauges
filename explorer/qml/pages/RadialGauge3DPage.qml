import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges 1.0
import DevDash.Gauges.Theme 1.0
import "../components"

/**
 * @brief Explorer page demonstrating the "modernOEM" GaugeTheme preset.
 *
 * There is no longer a dedicated RadialGauge3D template — the modern OEM
 * digital-cluster aesthetic now lives in GaugeTheme as the `modernOEM` preset
 * (near-black gradient face, bright orange accent, light-grey marks). This page
 * renders a bare RadialGauge and activates that preset at page load.
 *
 * RadialGauge now consumes the structural tokens too, so the preset alone
 * gives this page its chrome3d bezel (`bezelStyle`), rectangle ticks and
 * tick/needle glow (`effectsGlow`) — not just the modern-OEM colours. Two
 * effects the retired RadialGauge3D template hard-wired have no theme token
 * yet — a glass overlay and a domed 3D centre cap — and RadialGauge has no
 * equivalent property, so they're simply absent here (see PLAN.md backlog);
 * the page approximates the metallic look with the per-instance gradient /
 * shadow flags below. The page keeps its old sidebar name ("RadialGauge3D")
 * as a semantic grouping.
 */
Item {
    id: root

    property string title: "RadialGauge3D"
    property string description: "RadialGauge under the 'modernOEM' GaugeTheme preset — near-black face, bright orange value arc and needle, light-grey ticks, chrome3d bezel, tick/needle glow, digital readout. (The old RadialGauge3D template's glass overlay and domed 3D centre cap have no theme token yet — see PLAN.md backlog.)"

    property var stateServer: null

    property alias propertyPanel: propertyPanel

    // Activate the modern-OEM preset for this page. We deliberately do not
    // restore a preset on destruction: StackView creates+completes the next
    // page before destroying this one, so a destruction-time setTheme() would
    // clobber the incoming page's choice. Each preset-demo page sets its own.
    Component.onCompleted: GaugeTheme.setTheme("modernOEM")

    property var properties: [
        // Value
        {name: "value", type: "real", min: 0, max: 10000, default: 0, category: "Value",
         description: "Current value displayed by the gauge."},
        {name: "minValue", type: "real", min: 0, max: 1000, default: 0, category: "Value",
         description: "Minimum value of the gauge range."},
        {name: "maxValue", type: "real", min: 100, max: 10000, default: 8000, category: "Value",
         description: "Maximum value of the gauge range."},
        {name: "label", type: "string", default: "RPM", category: "Value",
         description: "Label displayed below the gauge face."},
        {name: "unit", type: "string", default: "RPM", category: "Value",
         description: "Unit displayed in the digital readout."},

        // Thresholds
        {name: "warningThreshold", type: "real", min: 0, max: 10000, default: 6000, category: "Thresholds",
         description: "Value at which warning indicators activate."},
        {name: "redlineStart", type: "real", min: 0, max: 10000, default: 6500, category: "Thresholds",
         description: "Value where the redline zone begins."},

        // Geometry
        {name: "startAngle", type: "real", min: -360, max: 360, default: -225, category: "Geometry",
         description: "Starting angle in degrees. -225 = 7:30 position."},
        {name: "sweepAngle", type: "real", min: 0, max: 360, default: 270, category: "Geometry",
         description: "Total arc span in degrees."},

        // Features
        {name: "showValueArc", type: "bool", default: true, category: "Features",
         description: "Show the colored value arc that fills behind the needle."},
        {name: "showBackgroundArc", type: "bool", default: true, category: "Features",
         description: "Show the track arc behind the value arc."},
        {name: "showBezel", type: "bool", default: true, category: "Features",
         description: "Show the bezel ring (base colour from the theme's surfaceElevated token)."},
        {name: "showDigitalReadout", type: "bool", default: true, category: "Features",
         description: "Show the numeric digital readout."},

        // Colors (theme-token defaults; override per instance to verify overrides win)
        {name: "valueArcColor", type: "color", default: "#ff6600", category: "Colors",
         description: "Value arc fill. Defaults to GaugeTheme.colors.primary."},
        {name: "needleColor", type: "color", default: "#ff6600", category: "Colors",
         description: "Needle body colour. Defaults to GaugeTheme.colors.primary."},
        {name: "faceColor", type: "color", default: "#0d0d0d", category: "Colors",
         description: "Gauge face fill. Defaults to GaugeTheme.colors.surface."},
        {name: "bezelColor", type: "color", default: "#444444", category: "Colors",
         description: "Bezel ring base colour. Defaults to GaugeTheme.colors.surfaceElevated."},
        {name: "tickColor", type: "color", default: "#cccccc", category: "Colors",
         description: "Tick / numeral / label colour. Defaults to GaugeTheme.colors.foreground."},
        {name: "redlineColor", type: "color", default: "#cc2222", category: "Colors",
         description: "Redline zone colour. Defaults to GaugeTheme.colors.critical."},
        {name: "warningColor", type: "color", default: "#ffaa00", category: "Colors",
         description: "Warning zone colour. Defaults to GaugeTheme.colors.warning."},

        // Ticks
        {name: "majorTickInterval", type: "real", min: 1, max: 2000, default: 1000, category: "Ticks",
         description: "Value interval between major tick marks."},
        {name: "minorTickInterval", type: "real", min: 0, max: 500, default: 200, category: "Ticks",
         description: "Value interval between minor ticks. 0 disables."},
        {name: "labelDivisor", type: "real", min: 1, max: 1000, default: 1000, category: "Ticks",
         description: "Divides label values for display (e.g. 1000 → '8' for 8000)."}
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
                id: gauge3d
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
                showBezel: true

                // Modern-OEM flavour: gradient needle, gradient ticks, a bit of
                // metallic shine on the centre cap.
                needleGradient: true
                needleGradientStyle: "cylinder"
                needleShadow: true
                tickGradient: true
                centerCapGradient: true

                value: previewArea.animationValue * 80  // 0-8000 range
            }
        }

        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: gauge3d
            properties: root.properties
            stateServer: root.stateServer
        }
    }
}
