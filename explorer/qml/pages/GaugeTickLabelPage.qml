import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Primitives 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "GaugeTickLabel"
    property string description: "Text label primitive for gauge scales. Automatically keeps text upright and readable. Supports value formatting with divisors, prefixes, and suffixes."

    // State server for MCP integration (passed to PropertyPanel)
    property var stateServer: null

    // Expose property panel for external access
    property alias propertyPanel: propertyPanel

    // Property definitions for the editor (with descriptions for documentation panel)
    property var properties: [
        // Position
        {name: "angle", type: "real", min: -180, max: 180, default: 0, category: "Position",
         description: "Rotation angle in degrees from center. 0° = 3 o'clock position, positive = clockwise."},
        {name: "distanceFromCenter", type: "real", min: 30, max: 150, default: 80, category: "Position",
         description: "Radius from gauge center to label center in pixels. Position labels inside tick marks."},

        // Content
        {name: "text", type: "string", default: "0", category: "Content",
         description: "The text to display. Typically a numeric value from the gauge scale."},
        {name: "prefix", type: "string", default: "", category: "Content",
         description: "Text prepended before the main value. E.g., '$' for currency displays."},
        {name: "suffix", type: "string", default: "", category: "Content",
         description: "Text appended after the main value. E.g., '°C' for temperature displays."},

        // Typography
        {name: "fontSize", type: "int", min: 8, max: 48, default: 18, category: "Typography",
         description: "Font size in pixels. Larger sizes for primary readings, smaller for minor labels."},
        {name: "color", type: "color", default: "#888888", category: "Typography",
         description: "Text color. Use zone colors (normal/warning/critical) to match tick ring styling."},

        // Outline
        {name: "showOutline", type: "bool", default: false, category: "Outline",
         description: "Add contrasting stroke around text for visibility on busy backgrounds."},
        {name: "outlineColor", type: "color", default: "#000000", category: "Outline",
         description: "Color of the text outline stroke. Typically dark for light text, light for dark text."},

        // Behavior
        {name: "keepUpright", type: "bool", default: true, category: "Behavior",
         description: "Auto-rotate text to remain readable (not upside-down) at any angle. Disable for radial text effect."}
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

            Item {
                anchors.centerIn: parent
                width: 300
                height: 300

                // Reference circle to show positioning
                Rectangle {
                    anchors.centerIn: parent
                    width: gaugeTickLabel.distanceFromCenter * 2
                    height: gaugeTickLabel.distanceFromCenter * 2
                    radius: width / 2
                    color: "transparent"
                    border.color: "#333333"
                    border.width: 1
                }

                GaugeTickLabel {
                    id: gaugeTickLabel
                    anchors.fill: parent
                    distanceFromCenter: 100
                    text: Math.round(previewArea.animationValue / 10).toString()
                    fontSize: 24
                    color: "#ffffff"
                    showOutline: true

                    // Animate angle based on preview animation value
                    angle: -135 + (previewArea.animationValue * 2.7)
                }
            }
        }

        // Property panel (40% width)
        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: gaugeTickLabel
            properties: root.properties
            stateServer: root.stateServer
        }
    }
}
