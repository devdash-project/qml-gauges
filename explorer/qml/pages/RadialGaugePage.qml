import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "RadialGauge"
    property string description: "Complete analog radial gauge template. Composes all primitives and compounds into a professional gauge display with extensive customization."

    // State server for MCP integration (passed to PropertyPanel)
    property var stateServer: null

    // Expose property panel for external access
    property alias propertyPanel: propertyPanel

    // Property definitions for the editor (with descriptions for documentation panel)
    property var properties: [
        // Value
        {name: "value", type: "real", min: 0, max: 10000, default: 0, category: "Value",
         description: "Current value displayed by the gauge. Needle and value arc track this."},
        {name: "minValue", type: "real", min: 0, max: 1000, default: 0, category: "Value",
         description: "Minimum value of the gauge range. Scale starts here."},
        {name: "maxValue", type: "real", min: 100, max: 10000, default: 100, category: "Value",
         description: "Maximum value of the gauge range. Scale ends here."},
        {name: "label", type: "string", default: "", category: "Value",
         description: "Label displayed on the gauge face. E.g., 'RPM', 'SPEED', 'BOOST'."},
        {name: "unit", type: "string", default: "", category: "Value",
         description: "Unit displayed in digital readout. E.g., 'RPM', 'MPH', 'PSI'."},

        // Thresholds
        {name: "warningThreshold", type: "real", min: 0, max: 10000, default: 100, category: "Thresholds",
         description: "Value at which warning indicators activate. Ticks/arc change to warningColor."},
        {name: "redlineStart", type: "real", min: 0, max: 10000, default: 100, category: "Thresholds",
         description: "Value where redline zone begins. Shows semi-transparent red zone arc."},

        // Geometry
        {name: "startAngle", type: "real", min: -360, max: 360, default: -225, category: "Geometry",
         description: "Starting angle in degrees. -225° = 7:30 position (typical gauge start)."},
        {name: "sweepAngle", type: "real", min: 0, max: 360, default: 270, category: "Geometry",
         description: "Total arc span in degrees. 270° is standard (7:30 to 4:30)."},

        // Feature Toggles
        {name: "showFace", type: "bool", default: true, category: "Features",
         description: "Show the circular gauge face/dial background."},
        {name: "showBackgroundArc", type: "bool", default: true, category: "Features",
         description: "Show the track arc behind the value arc."},
        {name: "showValueArc", type: "bool", default: true, category: "Features",
         description: "Show the colored arc that fills based on value."},
        {name: "showRedline", type: "bool", default: true, category: "Features",
         description: "Show the semi-transparent redline zone arc."},
        {name: "showTicks", type: "bool", default: true, category: "Features",
         description: "Show tick marks and labels around the gauge."},
        {name: "showNeedle", type: "bool", default: true, category: "Features",
         description: "Show the animated needle indicator."},
        {name: "showCenterCap", type: "bool", default: true, category: "Features",
         description: "Show the center cap that covers the needle pivot."},
        {name: "showDigitalReadout", type: "bool", default: false, category: "Features",
         description: "Show numeric digital readout below the gauge face."},
        {name: "showBezel", type: "bool", default: false, category: "Features",
         description: "Show the decorative bezel/frame around the gauge."},

        // Tick Configuration
        {name: "majorTickInterval", type: "real", min: 1, max: 2000, default: 10, category: "Ticks",
         description: "Value interval between major tick marks with labels."},
        {name: "minorTickInterval", type: "real", min: 0, max: 500, default: 2, category: "Ticks",
         description: "Value interval between minor tick marks. 0 disables minor ticks."},
        {name: "labelDivisor", type: "real", min: 1, max: 1000, default: 1, category: "Ticks",
         description: "Divides label values. E.g., 1000 shows '8' instead of '8000'."},
        {name: "showTickInnerCircles", type: "bool", default: false, category: "Ticks",
         description: "Show decorative dots at inner end of major ticks (vintage style)."},
        {name: "tickInnerCircleDiameter", type: "real", min: 2, max: 12, default: 6, category: "Ticks",
         description: "Diameter of the decorative inner circles in pixels."},
        {name: "showTickLabelOutline", type: "bool", default: false, category: "Ticks",
         description: "Add outline stroke around tick labels for visibility."},

        // Colors
        {name: "faceColor", type: "color", default: "#1a1a1a", category: "Colors",
         description: "Background color of the gauge face/dial."},
        {name: "bezelColor", type: "color", default: "#2a2a2a", category: "Colors",
         description: "Color of the decorative bezel ring."},
        {name: "backgroundArcColor", type: "color", default: "#333333", category: "Colors",
         description: "Color of the track arc behind the value arc."},
        {name: "valueArcColor", type: "color", default: "#00aaff", category: "Colors",
         description: "Color of the value arc in normal range."},
        {name: "needleColor", type: "color", default: "#ffffff", category: "Colors",
         description: "Color of the needle indicator."},
        {name: "tickColor", type: "color", default: "#888888", category: "Colors",
         description: "Color of tick marks and labels in normal range."},
        {name: "redlineColor", type: "color", default: "#aa2222", category: "Colors",
         description: "Color of the redline zone arc."},
        {name: "warningColor", type: "color", default: "#ffaa00", category: "Colors",
         description: "Color for warning zone ticks/arc. Typically amber."},
        {name: "criticalColor", type: "color", default: "#ff4444", category: "Colors",
         description: "Color for critical zone ticks/arc. Typically red."},

        // Needle
        {name: "needleWidth", type: "real", min: 2, max: 12, default: 4, category: "Needle",
         description: "Width of the needle at the pivot point in pixels."},
        {name: "needleTipWidth", type: "real", min: 0, max: 8, default: 2, category: "Needle",
         description: "Width of the needle at the tip in pixels. Smaller = sharper."},
        {name: "needleBorderWidth", type: "real", min: 0, max: 4, default: 0, category: "Needle",
         description: "Border stroke width around the needle. 0 = no border."},
        {name: "needleBorderColor", type: "color", default: "transparent", category: "Needle",
         description: "Color of the needle border stroke."},
        {name: "needlePivotOffset", type: "real", min: 0, max: 30, default: 0, category: "Needle",
         description: "Offset from center for needle pivot point in pixels."},

        // Center Cap
        {name: "centerCapDiameter", type: "real", min: 10, max: 60, default: 30, category: "Center Cap",
         description: "Diameter of the center cap in pixels."},
        {name: "centerCapColor", type: "color", default: "#1a1a1a", category: "Center Cap",
         description: "Fill color of the center cap."},
        {name: "centerCapBorderColor", type: "color", default: "#ffffff", category: "Center Cap",
         description: "Border color of the center cap."},
        {name: "centerCapBorderWidth", type: "real", min: 0, max: 6, default: 2, category: "Center Cap",
         description: "Border width of the center cap in pixels."},
        {name: "centerCapGradient", type: "bool", default: false, category: "Center Cap",
         description: "Enable gradient shading on center cap for metallic look."},

        // Typography
        {name: "tickLabelFontSize", type: "int", min: 10, max: 32, default: 18, category: "Typography",
         description: "Font size for tick labels around the gauge in pixels."},
        {name: "gaugeLabelFontSize", type: "int", min: 10, max: 32, default: 18, category: "Typography",
         description: "Font size for the gauge label on the face in pixels."},

        // === 3D EFFECTS ===

        // Needle 3D Effects
        {name: "needleGradient", type: "bool", default: false, category: "Needle 3D",
         description: "Enable gradient shading on needle for 3D cylindrical appearance."},
        {name: "needleGradientStyle", type: "enum", default: "cylinder", category: "Needle 3D",
         options: ["cylinder", "ridge"],
         description: "Gradient style: 'cylinder' for round 3D look, 'ridge' for raised center highlight."},
        {name: "needleBevel", type: "bool", default: false, category: "Needle 3D",
         description: "Enable bevel effect with light/dark edge highlighting for depth."},
        {name: "needleBevelWidth", type: "real", min: 0.5, max: 3, default: 1.0, category: "Needle 3D",
         description: "Width of bevel highlight/shadow strokes in pixels."},
        {name: "needleShadow", type: "bool", default: false, category: "Needle 3D",
         description: "Enable basic drop shadow behind needle."},
        {name: "needlePivotShadow", type: "bool", default: false, category: "Needle 3D",
         description: "Enable realistic pivot shadow that follows light angle as needle rotates."},
        {name: "needleLightAngle", type: "real", min: -180, max: 180, default: -45, category: "Needle 3D",
         description: "Virtual light source angle. Controls highlight position and shadow direction."},
        {name: "needleInnerGlow", type: "bool", default: false, category: "Needle 3D",
         description: "Enable inner glow (self-illumination) effect."},
        {name: "needleInnerGlowColor", type: "color", default: "#ffffff", category: "Needle 3D",
         description: "Color of the inner glow effect."},
        {name: "needleOuterGlow", type: "bool", default: false, category: "Needle 3D",
         description: "Enable outer glow (neon halo) effect around needle edges."},
        {name: "needleOuterGlowColor", type: "color", default: "#ffffff", category: "Needle 3D",
         description: "Color of the outer glow halo."},

        // Tick 3D Effects
        {name: "tickGradient", type: "bool", default: false, category: "Tick 3D",
         description: "Enable gradient fill on tick marks for depth."},
        {name: "tickGlow", type: "bool", default: false, category: "Tick 3D",
         description: "Enable glow effect on ticks for luminous paint appearance."},
        {name: "tickGlowBlur", type: "real", min: 0.1, max: 1.0, default: 0.4, category: "Tick 3D",
         description: "Tick glow blur amount. Higher = softer glow."},
        {name: "tickShadow", type: "bool", default: false, category: "Tick 3D",
         description: "Enable drop shadow on ticks for raised appearance."},
        {name: "tickShadowBlur", type: "real", min: 0.1, max: 1.0, default: 0.25, category: "Tick 3D",
         description: "Tick shadow blur amount."},

        // Center Cap 3D Effects
        {name: "centerCapShadow", type: "bool", default: false, category: "Cap 3D",
         description: "Enable drop shadow on center cap for raised appearance."},
        {name: "centerCapHighlight", type: "bool", default: false, category: "Cap 3D",
         description: "Enable highlight ring for domed/beveled 3D appearance."}
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

            RadialGauge {
                id: radialGauge
                anchors.centerIn: parent
                width: 400
                height: 400
                minValue: 0
                maxValue: 8000
                label: "RPM"
                unit: "RPM"
                warningThreshold: 6000
                redlineStart: 6500
                majorTickInterval: 1000
                minorTickInterval: 200
                labelDivisor: 1000
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

            target: radialGauge
            properties: root.properties
            stateServer: root.stateServer
        }
    }
}
