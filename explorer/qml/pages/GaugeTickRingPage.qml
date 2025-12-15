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

    // State server for MCP integration (passed to PropertyPanel)
    property var stateServer: null

    // Expose property panel for external access
    property alias propertyPanel: propertyPanel

    // Property definitions for the editor (with descriptions for documentation panel)
    property var properties: [
        // Value Range
        {name: "minValue", type: "real", min: 0, max: 1000, default: 0, category: "Value Range",
         description: "Minimum value shown on the gauge scale. Labels and ticks start from this value."},
        {name: "maxValue", type: "real", min: 100, max: 10000, default: 100, category: "Value Range",
         description: "Maximum value shown on the gauge scale. Labels and ticks end at this value."},
        {name: "majorTickInterval", type: "real", min: 1, max: 1000, default: 10, category: "Value Range",
         description: "Value interval between major tick marks. E.g., 1000 for an 8000 RPM gauge = ticks at 0, 1, 2... 8."},
        {name: "minorTickInterval", type: "real", min: 0, max: 100, default: 2, category: "Value Range",
         description: "Value interval between minor tick marks. Set to 0 to disable minor ticks. E.g., 200 = 5 minor ticks per major."},
        {name: "labelDivisor", type: "real", min: 1, max: 1000, default: 1, category: "Value Range",
         description: "Divides displayed label values. E.g., 1000 shows '8' instead of '8000' for RPM gauges."},

        // Zones
        {name: "warningStart", type: "real", min: 0, max: 10000, default: 100, category: "Zones",
         description: "Value where warning zone begins. Ticks and labels from this point use warningColor. Set above maxValue to disable."},
        {name: "criticalStart", type: "real", min: 0, max: 10000, default: 100, category: "Zones",
         description: "Value where critical/redline zone begins. Ticks and labels use criticalColor. Set above maxValue to disable."},

        // Geometry
        {name: "startAngle", type: "real", min: -360, max: 360, default: -225, category: "Geometry",
         description: "Starting angle in degrees. 0° = 3 o'clock, -225° = 7:30 position (typical gauge start)."},
        {name: "sweepAngle", type: "real", min: 0, max: 360, default: 270, category: "Geometry",
         description: "Total arc span in degrees. 270° is standard (7:30 to 4:30). Use 360° for full circle gauges."},
        {name: "majorTickLength", type: "real", min: 5, max: 30, default: 15, category: "Geometry",
         description: "Length of major tick marks in pixels. These appear at each majorTickInterval value."},
        {name: "majorTickWidth", type: "real", min: 1, max: 5, default: 2, category: "Geometry",
         description: "Thickness of major tick marks in pixels."},
        {name: "minorTickLength", type: "real", min: 3, max: 20, default: 8, category: "Geometry",
         description: "Length of minor tick marks in pixels. Typically shorter than major ticks."},
        {name: "minorTickWidth", type: "real", min: 1, max: 3, default: 1, category: "Geometry",
         description: "Thickness of minor tick marks in pixels. Typically thinner than major ticks."},

        // Colors
        {name: "normalColor", type: "color", default: "#888888", category: "Colors",
         description: "Color for ticks and labels in the normal operating range (below warningStart)."},
        {name: "warningColor", type: "color", default: "#ffaa00", category: "Colors",
         description: "Color for ticks and labels in the warning zone (warningStart to criticalStart). Typically amber/orange."},
        {name: "criticalColor", type: "color", default: "#ff4444", category: "Colors",
         description: "Color for ticks and labels in the critical/redline zone (above criticalStart). Typically red."},

        // Typography
        {name: "fontSize", type: "real", min: 8, max: 32, default: 16, category: "Typography",
         description: "Font size for tick labels in pixels."},
        {name: "showLabelOutline", type: "bool", default: false, category: "Typography",
         description: "Add a contrasting outline/stroke around labels for better visibility on busy backgrounds."},
        {name: "labelOutlineColor", type: "color", default: "#000000", category: "Typography",
         description: "Color of the label outline stroke when showLabelOutline is enabled."},

        // Decorations
        {name: "showInnerCircles", type: "bool", default: false, category: "Decorations",
         description: "Display decorative dots at the inner end of major ticks. Classic vintage gauge style (Speedhut, AutoMeter)."},
        {name: "innerCircleDiameter", type: "real", min: 2, max: 12, default: 6, category: "Decorations",
         description: "Diameter of the decorative inner circles in pixels."}
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
            stateServer: root.stateServer
        }
    }
}
