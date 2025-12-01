import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Compounds 1.0
import DevDash.Gauges.Primitives 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "GaugeNeedle"
    property string description: "Unified gauge needle compound with 4-part architecture: front body, head tip, rear body, and tail tip. Supports multiple shapes, independent colors, gradients, and shadow effects."

    // Property definitions for the editor
    property var properties: [
        // Rotation
        {name: "angle", type: "real", min: -180, max: 180, default: 0, category: "Rotation"},

        // Front Body
        {name: "frontShape", type: "enum", options: ["tapered", "straight"], default: "tapered", category: "Front Body"},
        {name: "frontLength", type: "real", min: 20, max: 200, default: 100, category: "Front Body"},
        {name: "frontPivotWidth", type: "real", min: 2, max: 30, default: 10, category: "Front Body"},
        {name: "frontTipWidth", type: "real", min: 1, max: 20, default: 4, category: "Front Body"},
        {name: "frontColor", type: "color", default: "#ff6600", category: "Front Body"},
        {name: "frontGradient", type: "bool", default: false, category: "Front Body"},
        {name: "frontBorderWidth", type: "real", min: 0, max: 5, default: 0, category: "Front Body"},
        {name: "frontBorderColor", type: "color", default: "#000000", category: "Front Body"},

        // Head Tip
        {name: "headTipShape", type: "enum", options: ["none", "pointed", "arrow", "rounded", "flat", "diamond"], default: "pointed", category: "Head Tip"},
        {name: "headTipLength", type: "real", min: 0, max: 30, default: 0, category: "Head Tip"},
        {name: "headTipColor", type: "color", default: "#ff6600", category: "Head Tip"},
        {name: "headTipGradient", type: "bool", default: false, category: "Head Tip"},

        // Rear Body
        {name: "rearRatio", type: "real", min: 0, max: 1, default: 0.0, category: "Rear Body"},
        {name: "rearShape", type: "enum", options: ["tapered", "straight"], default: "tapered", category: "Rear Body"},
        {name: "rearPivotWidth", type: "real", min: 2, max: 30, default: 10, category: "Rear Body"},
        {name: "rearTipWidth", type: "real", min: 1, max: 20, default: 6, category: "Rear Body"},
        {name: "rearColor", type: "color", default: "#333333", category: "Rear Body"},
        {name: "rearGradient", type: "bool", default: false, category: "Rear Body"},
        {name: "rearBorderWidth", type: "real", min: 0, max: 5, default: 0, category: "Rear Body"},
        {name: "rearBorderColor", type: "color", default: "#000000", category: "Rear Body"},

        // Tail Tip
        {name: "tailTipShape", type: "enum", options: ["none", "tapered", "crescent", "counterweight", "wedge", "flat"], default: "none", category: "Tail Tip"},
        {name: "tailTipLength", type: "real", min: 0, max: 30, default: 0, category: "Tail Tip"},
        {name: "tailTipColor", type: "color", default: "#333333", category: "Tail Tip"},
        {name: "tailTipGradient", type: "bool", default: false, category: "Tail Tip"},
        {name: "tailTipCurveAmount", type: "real", min: 0, max: 1, default: 0.5, category: "Tail Tip"},

        // Shadow
        {name: "hasShadow", type: "bool", default: false, category: "Shadow"},
        {name: "shadowOffset", type: "real", min: 0, max: 10, default: 2, category: "Shadow"},

        // Animation
        {name: "animated", type: "bool", default: true, category: "Animation"},
        {name: "spring", type: "real", min: 0.5, max: 10, default: 3.5, category: "Animation"},
        {name: "damping", type: "real", min: 0.1, max: 1, default: 0.25, category: "Animation"},

        // Advanced
        {name: "antialiasing", type: "bool", default: true, category: "Advanced"},
        {name: "needleOpacity", type: "real", min: 0, max: 1, default: 1.0, category: "Advanced"}
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

            // Dark background circle to simulate gauge face
            Rectangle {
                anchors.centerIn: parent
                width: 300
                height: 300
                radius: width / 2
                color: "#1a1a1a"

                // Gauge needle centered in the circle
                GaugeNeedle {
                    id: gaugeNeedle
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height

                    // Default values for demonstration
                    frontLength: 100
                    frontPivotWidth: 10
                    frontTipWidth: 4
                    frontColor: "#ff6600"
                    headTipShape: "pointed"
                    rearRatio: 0.25
                    rearColor: "#333333"
                    tailTipShape: "crescent"
                }

                // Optional center cap for reference
                GaugeCenterCap {
                    anchors.centerIn: parent
                    diameter: 20
                    color: "#333333"
                    borderColor: "#ff6600"
                    borderWidth: 2
                }
            }

            // Angle animation slider
            Column {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 20
                spacing: 5

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Angle: " + angleSlider.value.toFixed(0) + "\u00B0"
                    color: "#888888"
                    font.pixelSize: 12
                }

                Slider {
                    id: angleSlider
                    width: 250
                    from: -180
                    to: 180
                    value: 0
                    onValueChanged: gaugeNeedle.angle = value
                }
            }
        }

        // Property panel (40% width)
        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: gaugeNeedle
            properties: root.properties
        }
    }
}
