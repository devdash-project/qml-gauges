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

    // Property definitions for the editor
    property var properties: [
        // Value Range
        {name: "minValue", type: "real", min: 0, max: 1000, default: 0, category: "Value Range"},
        {name: "maxValue", type: "real", min: 100, max: 10000, default: 100, category: "Value Range"},
        {name: "startValue", type: "real", min: 0, max: 10000, default: 0, category: "Value Range"},
        {name: "endValue", type: "real", min: 0, max: 10000, default: 100, category: "Value Range"},

        // Geometry
        {name: "gaugeStartAngle", type: "real", min: -360, max: 360, default: -225, category: "Geometry"},
        {name: "gaugeTotalSweep", type: "real", min: 0, max: 360, default: 270, category: "Geometry"},
        {name: "strokeWidth", type: "real", min: 5, max: 50, default: 20, category: "Geometry"},

        // Appearance
        {name: "zoneColor", type: "color", default: "#aa2222", category: "Appearance"},
        {name: "zoneOpacity", type: "real", min: 0, max: 1, default: 0.3, category: "Appearance"}
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
        }
    }
}
