import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Primitives 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "GaugeTick"
    property string description: "Individual tick mark primitive for gauge scales. Supports rounded ends and optional decorative inner circles for classic gauge aesthetics."

    // Property definitions for the editor
    property var properties: [
        // Position
        {name: "angle", type: "real", min: -180, max: 180, default: 0, category: "Position"},
        {name: "distanceFromCenter", type: "real", min: 50, max: 200, default: 100, category: "Position"},

        // Geometry
        {name: "length", type: "real", min: 5, max: 40, default: 15, category: "Geometry"},
        {name: "tickWidth", type: "real", min: 1, max: 10, default: 3, category: "Geometry"},

        // Appearance
        {name: "color", type: "color", default: "#888888", category: "Appearance"},
        {name: "tickOpacity", type: "real", min: 0, max: 1, default: 1.0, category: "Appearance"},
        {name: "roundedEnds", type: "bool", default: true, category: "Appearance"},

        // Inner Circle
        {name: "showInnerCircle", type: "bool", default: false, category: "Inner Circle"},
        {name: "innerCircleDiameter", type: "real", min: 2, max: 20, default: 6, category: "Inner Circle"},
        {name: "innerCircleColor", type: "color", default: "#888888", category: "Inner Circle"}
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
                    width: gaugeTick.distanceFromCenter * 2
                    height: gaugeTick.distanceFromCenter * 2
                    radius: width / 2
                    color: "transparent"
                    border.color: "#333333"
                    border.width: 1
                }

                GaugeTick {
                    id: gaugeTick
                    anchors.fill: parent
                    distanceFromCenter: 120
                    length: 20
                    tickWidth: 4
                    showInnerCircle: true

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

            target: gaugeTick
            properties: root.properties
        }
    }
}
