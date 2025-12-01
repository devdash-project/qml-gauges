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

    // Property definitions for the editor
    property var properties: [
        // Position
        {name: "angle", type: "real", min: -180, max: 180, default: 0, category: "Position"},
        {name: "distanceFromCenter", type: "real", min: 30, max: 150, default: 80, category: "Position"},

        // Content
        {name: "text", type: "string", default: "0", category: "Content"},
        {name: "prefix", type: "string", default: "", category: "Content"},
        {name: "suffix", type: "string", default: "", category: "Content"},

        // Typography
        {name: "fontSize", type: "int", min: 8, max: 48, default: 18, category: "Typography"},
        {name: "color", type: "color", default: "#888888", category: "Typography"},

        // Outline
        {name: "showOutline", type: "bool", default: false, category: "Outline"},
        {name: "outlineColor", type: "color", default: "#000000", category: "Outline"},

        // Behavior
        {name: "keepUpright", type: "bool", default: true, category: "Behavior"}
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
        }
    }
}
