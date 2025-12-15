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

    // State server for MCP integration (passed to PropertyPanel)
    property var stateServer: null

    // Expose property panel for external access
    property alias propertyPanel: propertyPanel

    // Property definitions for the editor (with descriptions for documentation panel)
    property var properties: [
        // Rotation
        {name: "angle", type: "real", min: -180, max: 180, default: 0, category: "Rotation",
         description: "Needle rotation angle in degrees. 0° = 3 o'clock, typically -135° to +135° for gauges."},

        // Front Body
        {name: "frontShape", type: "enum", options: ["tapered", "straight"], default: "tapered", category: "Front Body",
         description: "Shape of the front (pointing) needle body. Tapered = narrowing toward tip, straight = constant width."},
        {name: "frontLength", type: "real", min: 20, max: 200, default: 100, category: "Front Body",
         description: "Length of front needle body from pivot to tip in pixels."},
        {name: "pivotWidth", type: "real", min: 2, max: 30, default: 10, category: "Front Body",
         description: "Width of needle at the pivot/center point in pixels."},
        {name: "frontTipWidth", type: "real", min: 1, max: 20, default: 4, category: "Front Body",
         description: "Width of front needle at the tip end in pixels. Smaller = sharper point."},
        {name: "frontColor", type: "color", default: "#ff6600", category: "Front Body",
         description: "Fill color for the front needle body. Classic orange/red for visibility."},
        {name: "frontGradient", type: "bool", default: false, category: "Front Body",
         description: "Enable gradient shading on front body for 3D appearance."},
        {name: "frontGradientStyle", type: "enum", options: ["cylinder", "ridge"], default: "cylinder", category: "Front Body",
         description: "Gradient style: 'cylinder' = round 3D shading, 'ridge' = raised center highlight (embossed spine)."},
        {name: "frontBorderWidth", type: "real", min: 0, max: 5, default: 0, category: "Front Body",
         description: "Border stroke width around front body. 0 = no border."},
        {name: "frontBorderColor", type: "color", default: "#000000", category: "Front Body",
         description: "Color of the front body border stroke."},

        // Head Tip
        {name: "headTipShape", type: "enum", options: ["none", "pointed", "arrow", "rounded", "flat", "diamond"], default: "pointed", category: "Head Tip",
         description: "Shape of the needle head tip. Pointed = sharp triangle, arrow = arrowhead, diamond = rhombus."},
        {name: "headTipAutoAlign", type: "bool", default: false, category: "Head Tip",
         description: "Automatically calculate headTipLength based on frontTipWidth for seamless connection."},
        {name: "headTipLength", type: "real", min: 0, max: 30, default: 0, category: "Head Tip",
         description: "Length of the head tip extension beyond front body. 0 when using auto-align."},
        {name: "headTipColor", type: "color", default: "#ff6600", category: "Head Tip",
         description: "Fill color for the head tip. Often matches frontColor for unified look."},
        {name: "headTipGradient", type: "bool", default: false, category: "Head Tip",
         description: "Enable gradient shading on head tip."},
        {name: "headTipBorderWidth", type: "real", min: 0, max: 5, default: 0, category: "Head Tip",
         description: "Border stroke width around head tip. 0 = no border."},
        {name: "headTipBorderColor", type: "color", default: "#000000", category: "Head Tip",
         description: "Color of the head tip border stroke."},

        // Rear Body
        {name: "rearRatio", type: "real", min: 0, max: 1, default: 0.3, category: "Rear Body",
         description: "Rear body length as ratio of frontLength. 0.3 = rear is 30% of front length."},
        {name: "rearShape", type: "enum", options: ["tapered", "straight"], default: "tapered", category: "Rear Body",
         description: "Shape of the rear (counterweight) needle body."},
        {name: "rearTipWidth", type: "real", min: 1, max: 30, default: 4, category: "Rear Body",
         description: "Width of rear needle at the tip end in pixels."},
        {name: "rearColor", type: "color", default: "#333333", category: "Rear Body",
         description: "Fill color for the rear body. Typically darker/subdued than front."},
        {name: "rearGradient", type: "bool", default: false, category: "Rear Body",
         description: "Enable gradient shading on rear body."},
        {name: "rearBorderWidth", type: "real", min: 0, max: 5, default: 0, category: "Rear Body",
         description: "Border stroke width around rear body. 0 = no border."},
        {name: "rearBorderColor", type: "color", default: "#000000", category: "Rear Body",
         description: "Color of the rear body border stroke."},

        // Tail Tip
        {name: "tailTipShape", type: "enum", options: ["none", "tapered", "crescent", "counterweight", "wedge", "flat"], default: "none", category: "Tail Tip",
         description: "Shape of the tail tip. Crescent = curved, counterweight = circular blob, wedge = diamond-like."},
        {name: "tailTipAutoAlign", type: "bool", default: false, category: "Tail Tip",
         description: "Automatically calculate tailTipLength based on rearTipWidth for seamless connection."},
        {name: "tailTipLength", type: "real", min: 0, max: 30, default: 0, category: "Tail Tip",
         description: "Length of the tail tip extension beyond rear body. 0 when using auto-align."},
        {name: "tailTipColor", type: "color", default: "#333333", category: "Tail Tip",
         description: "Fill color for the tail tip. Often matches rearColor."},
        {name: "tailTipGradient", type: "bool", default: false, category: "Tail Tip",
         description: "Enable gradient shading on tail tip."},
        {name: "tailTipCurveAmount", type: "real", min: 0, max: 1, default: 0.5, category: "Tail Tip",
         description: "Curvature intensity for crescent tail tip. 0 = flat, 1 = deep curve."},
        {name: "tailTipBorderWidth", type: "real", min: 0, max: 5, default: 0, category: "Tail Tip",
         description: "Border stroke width around tail tip. 0 = no border."},
        {name: "tailTipBorderColor", type: "color", default: "#000000", category: "Tail Tip",
         description: "Color of the tail tip border stroke."},

        // Shadow
        {name: "hasShadow", type: "bool", default: false, category: "Shadow",
         description: "Add drop shadow effect beneath needle for 3D depth appearance."},
        {name: "shadowOffset", type: "real", min: 0, max: 10, default: 2, category: "Shadow",
         description: "Distance of shadow from needle in pixels. Larger = needle appears higher off face."},

        // Animation
        {name: "animated", type: "bool", default: true, category: "Animation",
         description: "Enable spring physics animation when angle changes. Creates natural needle movement."},
        {name: "spring", type: "real", min: 0.5, max: 10, default: 3.5, category: "Animation",
         description: "Spring stiffness for animation. Higher = faster/snappier response."},
        {name: "damping", type: "real", min: 0.1, max: 1, default: 0.25, category: "Animation",
         description: "Damping factor for animation. Lower = more oscillation/bounce, higher = less overshoot."},

        // Lighting (shared)
        {name: "lightAngle", type: "real", min: -180, max: 180, default: -45, category: "Lighting",
         description: "Virtual light source angle in degrees. Affects pivot shadow direction and dynamic highlight. -45° = upper-left lighting."},

        // Pivot Shadow
        {name: "hasPivotShadow", type: "bool", default: false, category: "Pivot Shadow",
         description: "Enable angle-aware shadow that changes direction based on needle rotation and light angle."},
        {name: "pivotShadowDistance", type: "real", min: 1, max: 20, default: 5, category: "Pivot Shadow",
         description: "Maximum shadow offset distance in pixels. Larger = needle appears higher above face."},
        {name: "pivotShadowBlur", type: "real", min: 0, max: 1, default: 0.3, category: "Pivot Shadow",
         description: "Shadow blur/softness amount. 0 = sharp edge, 1 = very soft/diffuse."},
        {name: "pivotShadowColor", type: "color", default: "#000000", category: "Pivot Shadow",
         description: "Shadow color. Usually black or dark gray."},

        // Inner Glow (self-illumination)
        {name: "hasInnerGlow", type: "bool", default: false, category: "Inner Glow",
         description: "Enable inner glow effect making needle appear self-illuminated. Good for night mode."},
        {name: "innerGlowColor", type: "color", default: "#ff6600", category: "Inner Glow",
         description: "Color of the inner glow. Usually matches or complements needle color."},
        {name: "innerGlowIntensity", type: "real", min: 0, max: 1, default: 0.5, category: "Inner Glow",
         description: "Intensity of the inner glow brightness boost. 0 = off, 1 = very bright."},

        // Outer Glow (neon halo)
        {name: "hasOuterGlow", type: "bool", default: false, category: "Outer Glow",
         description: "Enable neon/LED-style glow halo around needle. Creates a luminescent effect."},
        {name: "outerGlowColor", type: "color", default: "#ff6600", category: "Outer Glow",
         description: "Color of the outer glow halo. Often matches needle color."},
        {name: "outerGlowSpread", type: "real", min: 0, max: 1, default: 0.4, category: "Outer Glow",
         description: "Spread/blur amount of outer glow. 0 = tight glow, 1 = wide diffuse halo."},

        // 3D Bevel
        {name: "hasBevel", type: "bool", default: false, category: "3D Bevel",
         description: "Enable 3D bevel effect with light/dark edges creating depth illusion."},
        {name: "bevelWidth", type: "real", min: 0.5, max: 4, default: 1.0, category: "3D Bevel",
         description: "Width of the bevel edge strokes in pixels."},
        {name: "bevelHighlight", type: "color", default: "#ff9944", category: "3D Bevel",
         description: "Highlight color for the left/top bevel edge. Lighter than needle color."},
        {name: "bevelShadow", type: "color", default: "#993300", category: "3D Bevel",
         description: "Shadow color for the right/bottom bevel edge. Darker than needle color."},

        // Advanced
        {name: "antialiasing", type: "bool", default: true, category: "Advanced",
         description: "Enable smooth edge rendering. Disable for pixel-perfect but jagged edges."},
        {name: "needleOpacity", type: "real", min: 0, max: 1, default: 1.0, category: "Advanced",
         description: "Overall opacity of the entire needle assembly. 0 = invisible, 1 = fully opaque."}
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
                    pivotWidth: 10
                    frontTipWidth: 4
                    frontColor: "#ff6600"
                    headTipShape: "pointed"
                    rearRatio: 0.25
                    rearColor: "#333333"
                    tailTipShape: "crescent"
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
            stateServer: root.stateServer
        }
    }
}
