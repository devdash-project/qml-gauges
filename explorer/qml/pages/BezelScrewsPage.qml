import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Primitives 1.0
import "../components"

Item {
    id: root

    property string title: "BezelScrews"
    property string description: "Fastener-ring primitive that renders N screws/rivets/bolts evenly distributed around a bezel. Supports configurable count, angle offset, head style, and recess shadow."

    property var stateServer: null
    property alias propertyPanel: propertyPanel

    property var properties: [
        // Layout
        {name: "count", type: "int", min: 0, max: 16, default: 4, category: "Layout",
         description: "Number of fasteners distributed around the ring. Typical values 4, 6, 8. Zero disables the primitive."},
        {name: "angleOffset", type: "real", min: -180, max: 180, default: 0, category: "Layout",
         description: "Rotation offset for the first fastener in degrees. 0 = 12 o'clock; 45 with count=4 produces intercardinal placement (1:30, 4:30, 7:30, 10:30)."},
        {name: "radius", type: "real", min: 20, max: 200, default: 150, category: "Layout",
         description: "Radial distance from center where fasteners are placed (pixels). Typically just inside the bezel inner edge."},

        // Appearance
        {name: "screwDiameter", type: "real", min: 2, max: 30, default: 10, category: "Appearance",
         description: "Diameter of each individual fastener head (pixels)."},
        {name: "screwColor", type: "color", default: "#1a1815", category: "Appearance",
         description: "Fill color of the fastener head. Default matches the IndustrialGauge bezel."},
        {name: "headStyle", type: "enum", options: ["plain", "slot", "cross", "hex", "dot"], default: "slot", category: "Appearance",
         description: "Detail drawn on top of each head. plain = smooth; slot = slotted screw; cross = Phillips; hex = Allen/bolt; dot = rivet."},
        {name: "headDetailColor", type: "color", default: "#000000", category: "Appearance",
         description: "Color of the slot/cross/hex/dot detail. Defaults to a darker variant of the screw color."},
        {name: "headDetailWidth", type: "real", min: 0.5, max: 4, default: 1.5, category: "Appearance",
         description: "Stroke width of the slot, cross, or hex detail (pixels)."},

        // Form shading
        {name: "hasFormShading", type: "bool", default: true, category: "Form Shading",
         description: "Render the head with a radial gradient simulating directional light, so it reads as a 3D protrusion rather than a flat disc."},
        {name: "lightAngle", type: "real", min: -180, max: 180, default: -45, category: "Form Shading",
         description: "Direction of the simulated light source (degrees). 0 = highlight at top; -45 = upper-left (the instrument-lighting convention)."},
        {name: "formShadingIntensity", type: "real", min: 0, max: 1, default: 0.4, category: "Form Shading",
         description: "Strength of the form shading. 0 = flat color; 1 = maximum highlight/shadow contrast; 0.4 = noticeable but restrained."},

        // Shadow
        {name: "hasShadow", type: "bool", default: true, category: "Shadow",
         description: "Whether each screw casts a drop shadow. Sells the look of a fastener sitting in a recess."},
        {name: "shadowColor", type: "color", default: "#000000", category: "Shadow",
         description: "Drop shadow color."},
        {name: "shadowOpacity", type: "real", min: 0, max: 1, default: 0.4, category: "Shadow",
         description: "Drop shadow opacity."},
        {name: "shadowOffsetX", type: "real", min: -5, max: 5, default: 0, category: "Shadow",
         description: "Horizontal shadow offset (pixels)."},
        {name: "shadowOffsetY", type: "real", min: -5, max: 5, default: 1, category: "Shadow",
         description: "Vertical shadow offset (pixels). Positive = downward."}
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

            Item {
                anchors.centerIn: parent
                width: 360
                height: 360

                // Reference ring so the screws have visual context
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "#0a0905"
                    border.color: "#1a1815"
                    border.width: 14
                    antialiasing: true
                }

                BezelScrews {
                    id: bezelScrews
                    anchors.fill: parent
                    radius: 150
                    screwDiameter: 10
                    count: 4
                    angleOffset: 0
                    headStyle: "slot"
                }
            }
        }

        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: bezelScrews
            properties: root.properties
            stateServer: root.stateServer
        }
    }
}
