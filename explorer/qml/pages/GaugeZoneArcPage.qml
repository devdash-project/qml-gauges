import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Compounds 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "GaugeZoneArc"
    property string description: "Static colored zone arc for warning/redline regions. Displays a semi-transparent arc segment between startValue and endValue."

    // State server for MCP integration (passed to PropertyPanel)
    property var stateServer: null

    // Expose property panel for external access
    property alias propertyPanel: propertyPanel

    // Property definitions for the editor (with descriptions for documentation panel)
    property var properties: [
        // Value Range
        {name: "minValue", type: "real", min: 0, max: 1000, default: 0, category: "Value Range",
         description: "Minimum value of the gauge scale. Used to calculate zone arc position."},
        {name: "maxValue", type: "real", min: 100, max: 10000, default: 100, category: "Value Range",
         description: "Maximum value of the gauge scale. Used to calculate zone arc position."},
        {name: "startValue", type: "real", min: 0, max: 10000, default: 0, category: "Value Range",
         description: "Value where the zone arc begins. E.g., 6500 for redline start on 8000 RPM gauge."},
        {name: "endValue", type: "real", min: 0, max: 10000, default: 100, category: "Value Range",
         description: "Value where the zone arc ends. Typically maxValue for redline zones."},

        // Geometry
        {name: "gaugeStartAngle", type: "real", min: -360, max: 360, default: -225, category: "Geometry",
         description: "Starting angle of the gauge scale in degrees. Must match parent gauge for alignment."},
        {name: "gaugeTotalSweep", type: "real", min: 0, max: 360, default: 270, category: "Geometry",
         description: "Total sweep angle of the gauge scale. Must match parent gauge for alignment."},
        {name: "strokeWidth", type: "real", min: 5, max: 50, default: 20, category: "Geometry",
         description: "Thickness of the zone arc stroke in pixels. Often matches background arc width."},

        // Appearance
        {name: "zoneColor", type: "color", default: "#aa2222", category: "Appearance",
         description: "Fill color of the zone arc. Red for redline, amber for warning, etc."},
        {name: "zoneOpacity", type: "real", min: 0, max: 1, default: 0.3, category: "Appearance",
         description: "Opacity of the zone arc. Semi-transparent (0.3-0.5) allows ticks to show through."}
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
                width: 400
                height: 400

                // Background reference arc
                Rectangle {
                    anchors.centerIn: parent
                    width: 340
                    height: 340
                    radius: width / 2
                    color: "transparent"
                    border.color: "#333333"
                    border.width: 20
                }

                GaugeZoneArc {
                    id: gaugeZoneArc
                    anchors.fill: parent
                    minValue: 0
                    maxValue: 8000
                    startValue: 6500
                    endValue: 8000
                    strokeWidth: 22
                    zoneOpacity: 0.5
                }
            }
        }

        // Property panel (40% width)
        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: gaugeZoneArc
            properties: root.properties
            stateServer: root.stateServer
        }
    }
}
