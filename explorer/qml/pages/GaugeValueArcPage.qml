import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Compounds 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "GaugeValueArc"
    property string description: "Value-driven arc that fills from minValue to current value. Automatically changes color at warning and critical thresholds."

    // State server for MCP integration (passed to PropertyPanel)
    property var stateServer: null

    // Expose property panel for external access
    property alias propertyPanel: propertyPanel

    // Property definitions for the editor (with descriptions for documentation panel)
    property var properties: [
        // Value
        {name: "value", type: "real", min: 0, max: 10000, default: 0, category: "Value",
         description: "Current value to display. The arc fills proportionally from minValue to this value."},
        {name: "minValue", type: "real", min: 0, max: 1000, default: 0, category: "Value",
         description: "Minimum value of the gauge range. Arc starts at this value."},
        {name: "maxValue", type: "real", min: 100, max: 10000, default: 100, category: "Value",
         description: "Maximum value of the gauge range. Full arc when value equals maxValue."},

        // Thresholds
        {name: "warningThreshold", type: "real", min: 0, max: 10000, default: 100, category: "Thresholds",
         description: "Value at which arc color changes to warningColor. Set above maxValue to disable."},
        {name: "criticalThreshold", type: "real", min: 0, max: 10000, default: 100, category: "Thresholds",
         description: "Value at which arc color changes to criticalColor. Set above maxValue to disable."},

        // Geometry
        {name: "startAngle", type: "real", min: -360, max: 360, default: -225, category: "Geometry",
         description: "Starting angle in degrees. 0° = 3 o'clock, -225° = 7:30 position (typical gauge start)."},
        {name: "totalSweepAngle", type: "real", min: 0, max: 360, default: 270, category: "Geometry",
         description: "Total arc span in degrees at maxValue. 270° is standard (7:30 to 4:30)."},
        {name: "strokeWidth", type: "real", min: 5, max: 50, default: 20, category: "Geometry",
         description: "Thickness of the value arc stroke in pixels."},

        // Colors
        {name: "normalColor", type: "color", default: "#00aaff", category: "Colors",
         description: "Arc color in normal operating range (below warningThreshold). Typically blue/cyan."},
        {name: "warningColor", type: "color", default: "#ffaa00", category: "Colors",
         description: "Arc color in warning range (warningThreshold to criticalThreshold). Typically amber."},
        {name: "criticalColor", type: "color", default: "#ff4444", category: "Colors",
         description: "Arc color in critical range (above criticalThreshold). Typically red."},

        // Animation
        {name: "animated", type: "bool", default: true, category: "Animation",
         description: "Enable smooth transition animation when value changes."},
        {name: "animationVelocity", type: "real", min: 60, max: 720, default: 360, category: "Animation",
         description: "Animation speed in degrees per second. Higher = faster arc movement."}
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

            GaugeValueArc {
                id: gaugeValueArc
                anchors.centerIn: parent
                width: 400
                height: 400
                minValue: 0
                maxValue: 8000
                warningThreshold: 6000
                criticalThreshold: 6500
                strokeWidth: 25
                animated: false  // Disable internal animation for explorer preview

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

            target: gaugeValueArc
            properties: root.properties
            stateServer: root.stateServer
        }
    }
}
