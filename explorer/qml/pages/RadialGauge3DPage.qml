import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges 1.0
import "../components"

/**
 * @brief Explorer page for RadialGauge3D showcase component.
 *
 * Demonstrates the premium 3D gauge effects:
 * - Chrome3D bezel with ConicalGradient
 * - Domed center cap with spherical gradient
 * - Glass overlay with curved highlight
 * - Gradient needle with glow and shadow
 * - Performance overlay for FPS monitoring
 */
Item {
    id: root

    // Component metadata
    property string title: "RadialGauge3D"
    property string description: "Premium 3D showcase gauge template. Demonstrates photorealistic effects with chrome bezel, domed center cap, glass overlay, and gradient needle with glow effects."

    // State server for MCP integration (passed to PropertyPanel)
    property var stateServer: null

    // Expose property panel for external access
    property alias propertyPanel: propertyPanel

    // Property definitions for the editor
    property var properties: [
        // Value
        {name: "value", type: "real", min: 0, max: 10000, default: 0, category: "Value",
         description: "Current value displayed by the gauge."},
        {name: "minValue", type: "real", min: 0, max: 1000, default: 0, category: "Value",
         description: "Minimum value of the gauge range."},
        {name: "maxValue", type: "real", min: 100, max: 10000, default: 100, category: "Value",
         description: "Maximum value of the gauge range."},
        {name: "label", type: "string", default: "", category: "Value",
         description: "Label displayed on the gauge face."},
        {name: "unit", type: "string", default: "", category: "Value",
         description: "Unit displayed in digital readout."},

        // Thresholds
        {name: "warningThreshold", type: "real", min: 0, max: 10000, default: 100, category: "Thresholds",
         description: "Value at which warning indicators activate."},
        {name: "redlineStart", type: "real", min: 0, max: 10000, default: 100, category: "Thresholds",
         description: "Value where redline zone begins."},

        // Geometry
        {name: "startAngle", type: "real", min: -360, max: 360, default: -225, category: "Geometry",
         description: "Starting angle in degrees. -225 = 7:30 position."},
        {name: "sweepAngle", type: "real", min: 0, max: 360, default: 270, category: "Geometry",
         description: "Total arc span in degrees."},

        // Features
        {name: "showPerformance", type: "bool", default: false, category: "Features",
         description: "Show FPS counter and frame time graph for performance monitoring."},
        {name: "showGlass", type: "bool", default: true, category: "Features",
         description: "Show glass overlay effect with curved highlight and vignette."},
        {name: "glassIntensity", type: "real", min: 0.0, max: 0.5, default: 0.2, category: "Features",
         description: "Intensity of the glass overlay highlight (0.0-0.5)."},
        {name: "showBezel", type: "bool", default: true, category: "Features",
         description: "Show chrome3D bezel with ConicalGradient effect."},
        {name: "showDigitalReadout", type: "bool", default: false, category: "Features",
         description: "Show numeric digital readout."},

        // Colors
        {name: "accentColor", type: "color", default: "#ff6600", category: "Colors",
         description: "Primary accent color for needle and value arc."},
        {name: "faceColor", type: "color", default: "#0d0d0d", category: "Colors",
         description: "Background color of the gauge face."},
        {name: "bezelColor", type: "color", default: "#444444", category: "Colors",
         description: "Base color for the chrome3D bezel."},
        {name: "tickColor", type: "color", default: "#cccccc", category: "Colors",
         description: "Color of tick marks and labels."},
        {name: "redlineColor", type: "color", default: "#cc2222", category: "Colors",
         description: "Color of the redline zone."},
        {name: "warningColor", type: "color", default: "#ffaa00", category: "Colors",
         description: "Color for warning zone indicators."},

        // Ticks
        {name: "majorTickInterval", type: "real", min: 1, max: 2000, default: 10, category: "Ticks",
         description: "Value interval between major tick marks."},
        {name: "minorTickInterval", type: "real", min: 0, max: 500, default: 2, category: "Ticks",
         description: "Value interval between minor ticks. 0 disables."},
        {name: "labelDivisor", type: "real", min: 1, max: 1000, default: 1, category: "Ticks",
         description: "Divides label values for display."}
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

            RadialGauge3D {
                id: gauge3d
                anchors.centerIn: parent
                width: 400
                height: 400

                // Value range
                minValue: 0
                maxValue: 8000
                label: "RPM"
                unit: "RPM"

                // Thresholds
                warningThreshold: 6000
                redlineStart: 6500

                // Ticks
                majorTickInterval: 1000
                minorTickInterval: 200
                labelDivisor: 1000

                // Show digital readout
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

            target: gauge3d
            properties: root.properties
            stateServer: root.stateServer
        }
    }
}
