import QtQuick
import DevDash.Gauges.Primitives 1.0
import DevDash.Gauges.Compounds 1.0

/**
 * @brief Complete analog radial gauge template.
 *
 * AnalogGauge is a fully-featured radial gauge that composes primitives
 * and compounds into a professional analog gauge display.
 *
 * Includes (all toggleable):
 * - Background face
 * - Background arc track
 * - Zone arcs (redline, warning)
 * - Tick marks and labels
 * - Value arc (fills to current value)
 * - Animated needle
 * - Center cap
 * - Digital readout
 * - Decorative bezel
 *
 * @example
 * @code
 * AnalogGauge {
 *     value: dataBroker.rpm
 *     minValue: 0
 *     maxValue: 8000
 *     label: "RPM"
 *     redlineStart: 6500
 *     warningThreshold: 6000
 * }
 * @endcode
 */
Item {
    id: root

    // === Value Properties ===

    /**
     * @brief Current value to display.
     */
    property real value: 0

    /**
     * @brief Minimum value of the range.
     */
    property real minValue: 0

    /**
     * @brief Maximum value of the range.
     */
    property real maxValue: 100

    /**
     * @brief Gauge label (e.g., "RPM", "Speed").
     */
    property string label: ""

    /**
     * @brief Unit for digital readout (e.g., "RPM", "mph").
     */
    property string unit: ""

    // === Threshold Properties ===

    /**
     * @brief Value where warning zone starts.
     */
    property real warningThreshold: maxValue

    /**
     * @brief Value where critical/redline zone starts.
     */
    property real redlineStart: maxValue

    // === Geometry Properties ===

    /**
     * @brief Starting angle in degrees.
     * @default -225 (7:30 position)
     */
    property real startAngle: -225

    /**
     * @brief Total sweep angle in degrees.
     * @default 270 (three-quarter circle)
     */
    property real sweepAngle: 270

    // === Feature Toggles ===

    /**
     * @brief Show background face plate.
     */
    property bool showFace: true

    /**
     * @brief Show background arc track.
     */
    property bool showBackgroundArc: true

    /**
     * @brief Show value-filled arc.
     */
    property bool showValueArc: true

    /**
     * @brief Show redline zone arc.
     */
    property bool showRedline: true

    /**
     * @brief Show tick marks and labels.
     */
    property bool showTicks: true

    /**
     * @brief Show animated needle.
     */
    property bool showNeedle: true

    /**
     * @brief Show center pivot cap.
     */
    property bool showCenterCap: true

    /**
     * @brief Show digital numeric readout.
     */
    property bool showDigitalReadout: false

    /**
     * @brief Show decorative bezel frame.
     */
    property bool showBezel: false

    // === Tick Configuration ===

    /**
     * @brief Interval between major ticks.
     */
    property real majorTickInterval: (maxValue - minValue) / 10

    /**
     * @brief Interval between minor ticks (0 = disabled).
     */
    property real minorTickInterval: majorTickInterval / 5

    /**
     * @brief Divisor for tick labels (e.g., 1000 shows "8" for 8000).
     */
    property real labelDivisor: 1

    // === Color Scheme ===

    property color faceColor: "#1a1a1a"
    property color bezelColor: "#2a2a2a"
    property color backgroundArcColor: "#333333"
    property color valueArcColor: "#00aaff"
    property color needleColor: "#ffffff"
    property color tickColor: "#888888"
    property color redlineColor: "#aa2222"
    property color warningColor: "#ffaa00"
    property color criticalColor: "#ff4444"

    // === Needle Customization ===

    /**
     * @brief Width of needle at pivot (pixels).
     * @default 10
     */
    property real needlePivotWidth: 10

    /**
     * @brief Width of needle at tip (pixels).
     * @default 4 (tapered)
     */
    property real needleTipWidth: 4

    /**
     * @brief Border width around needle edge (pixels).
     * @default 0 (no border)
     */
    property real needleBorderWidth: 0

    /**
     * @brief Border color around needle.
     * @default "transparent"
     */
    property color needleBorderColor: "transparent"

    /**
     * @brief Front body shape style.
     * Supported: "tapered", "straight", "convex", "concave"
     * @default "tapered"
     */
    property string needleShape: "tapered"

    /**
     * @brief Head tip shape style.
     * Supported: "none", "pointed", "arrow", "rounded", "flat", "diamond"
     * @default "pointed"
     */
    property string needleHeadTipShape: "pointed"

    /**
     * @brief Rear body length as ratio of front length (0.0-1.0).
     * Set to 0 for no rear section.
     * @default 0.0
     */
    property real needleRearRatio: 0.0

    /**
     * @brief Rear body color (can differ from front).
     * @default needleColor
     */
    property color needleRearColor: needleColor

    /**
     * @brief Tail tip shape style.
     * Supported: "none", "tapered", "crescent", "counterweight", "wedge", "flat"
     * @default "none"
     */
    property string needleTailTipShape: "none"

    /**
     * @brief Enable gradient shading on needle.
     * @default false
     */
    property bool needleGradient: false

    /**
     * @brief Enable shadow effect on needle.
     * @default false
     */
    property bool needleShadow: false

    /**
     * @brief Gradient style for 3D needle effect.
     * Supported: "cylinder" (round 3D), "ridge" (raised center highlight)
     * @default "cylinder"
     */
    property string needleGradientStyle: "cylinder"

    /**
     * @brief Enable 3D bevel effect on needle edges.
     * Creates depth illusion with light/dark edge highlighting.
     * @default false
     */
    property bool needleBevel: false

    /**
     * @brief Bevel stroke width in pixels.
     * @default 1.0
     */
    property real needleBevelWidth: 1.0

    /**
     * @brief Enable realistic pivot shadow that follows light angle.
     * Shadow direction changes based on needle rotation relative to light.
     * @default false
     */
    property bool needlePivotShadow: false

    /**
     * @brief Virtual light source angle in degrees.
     * Controls highlight position and pivot shadow direction.
     * 0 = light from top, 90 = from right, -45 = upper-left (default).
     * @default -45
     */
    property real needleLightAngle: -45

    /**
     * @brief Enable inner glow effect (self-illumination).
     * Makes the needle appear to emit light from within.
     * @default false
     */
    property bool needleInnerGlow: false

    /**
     * @brief Inner glow color.
     * @default needleColor
     */
    property color needleInnerGlowColor: needleColor

    /**
     * @brief Enable outer glow effect (neon halo).
     * Creates a glowing halo extending outward from needle edges.
     * @default false
     */
    property bool needleOuterGlow: false

    /**
     * @brief Outer glow color.
     * @default needleColor
     */
    property color needleOuterGlowColor: needleColor

    // === Center Cap Customization ===

    /**
     * @brief Diameter of center cap (pixels).
     * @default 30
     */
    property real centerCapDiameter: 30

    /**
     * @brief Center cap fill color.
     * @default faceColor
     */
    property color centerCapColor: faceColor

    /**
     * @brief Center cap border color.
     * @default needleColor
     */
    property color centerCapBorderColor: needleColor

    /**
     * @brief Center cap border width (pixels).
     * @default 2
     */
    property real centerCapBorderWidth: 2

    /**
     * @brief Enable metallic gradient on center cap.
     * @default false
     */
    property bool centerCapGradient: false

    /**
     * @brief Gradient highlight color (top).
     * @default "#888888"
     */
    property color centerCapGradientTop: "#888888"

    /**
     * @brief Gradient shadow color (bottom).
     * @default "#444444"
     */
    property color centerCapGradientBottom: "#444444"

    /**
     * @brief Enable drop shadow on center cap.
     * Creates raised appearance.
     * @default false
     */
    property bool centerCapShadow: false

    /**
     * @brief Enable highlight ring on center cap.
     * Creates domed/beveled 3D appearance.
     * @default false
     */
    property bool centerCapHighlight: false

    // === Typography Customization ===

    /**
     * @brief Font family for tick labels.
     * @default "Roboto"
     */
    property string tickLabelFontFamily: "Roboto"

    /**
     * @brief Font size for tick labels (pixels).
     * @default 18
     */
    property int tickLabelFontSize: 18

    /**
     * @brief Font weight for tick labels.
     * @default Font.Bold
     */
    property int tickLabelFontWeight: Font.Bold

    /**
     * @brief Font family for gauge label.
     * @default "Roboto"
     */
    property string gaugeLabelFontFamily: "Roboto"

    /**
     * @brief Font size for gauge label (pixels).
     * @default 18
     */
    property int gaugeLabelFontSize: 18

    /**
     * @brief Font weight for gauge label.
     * @default Font.Bold
     */
    property int gaugeLabelFontWeight: Font.Bold

    /**
     * @brief Show outline on tick label text.
     *
     * Creates black border around numbers for classic gauge aesthetic.
     *
     * @default false
     */
    property bool showTickLabelOutline: false

    /**
     * @brief Color of tick label outline.
     * @default "#000000"
     */
    property color tickLabelOutlineColor: "#000000"

    // === Tick Mark Customization ===

    /**
     * @brief Show decorative circles at inner end of ticks.
     *
     * Creates classic vintage gauge aesthetic.
     *
     * @default false
     */
    property bool showTickInnerCircles: false

    /**
     * @brief Diameter of tick inner circles (if enabled).
     * @default 6
     */
    property real tickInnerCircleDiameter: 6

    // === Tick 3D Effects ===

    /**
     * @brief Enable gradient fill on tick marks.
     * @default false
     */
    property bool tickGradient: false

    /**
     * @brief Enable glow effect on tick marks.
     * Creates luminous paint appearance.
     * @default false
     */
    property bool tickGlow: false

    /**
     * @brief Tick glow blur amount (0.0-1.0).
     * @default 0.4
     */
    property real tickGlowBlur: 0.4

    /**
     * @brief Enable drop shadow on tick marks.
     * Creates raised/3D appearance.
     * @default false
     */
    property bool tickShadow: false

    /**
     * @brief Tick shadow blur amount (0.0-1.0).
     * @default 0.25
     */
    property real tickShadowBlur: 0.25

    // === Implementation ===

    implicitWidth: 400
    implicitHeight: 400

    // Computed: needle angle based on value
    readonly property real _needleAngle: {
        const norm = (root.value - root.minValue) / (root.maxValue - root.minValue)
        const clamped = Math.max(0, Math.min(1, norm))
        return root.startAngle + (root.sweepAngle * clamped)
    }

    // Layer 1: Background face
    GaugeFace {
        anchors.centerIn: parent
        visible: root.showFace
        diameter: Math.min(root.width, root.height)
        color: root.faceColor
    }

    // Layer 2: Background arc track
    GaugeArc {
        anchors.fill: parent
        visible: root.showBackgroundArc
        startAngle: root.startAngle
        sweepAngle: root.sweepAngle
        strokeColor: root.backgroundArcColor
        strokeWidth: 20
        animated: false
    }

    // Layer 3: Redline zone arc
    GaugeZoneArc {
        anchors.fill: parent
        visible: root.showRedline && root.redlineStart < root.maxValue
        minValue: root.minValue
        maxValue: root.maxValue
        startValue: root.redlineStart
        endValue: root.maxValue
        gaugeStartAngle: root.startAngle
        gaugeTotalSweep: root.sweepAngle
        zoneColor: root.redlineColor
        zoneOpacity: 0.3
        strokeWidth: 20
    }

    // Layer 4: Tick ring
    GaugeTickRing {
        anchors.fill: parent
        visible: root.showTicks

        // Values and geometry
        minValue: root.minValue
        maxValue: root.maxValue
        majorTickInterval: root.majorTickInterval
        minorTickInterval: root.minorTickInterval
        labelDivisor: root.labelDivisor
        startAngle: root.startAngle
        sweepAngle: root.sweepAngle

        // Colors
        warningStart: root.warningThreshold
        criticalStart: root.redlineStart
        normalColor: root.tickColor
        warningColor: root.warningColor
        criticalColor: root.criticalColor

        // Typography
        fontSize: root.tickLabelFontSize
        fontFamily: root.tickLabelFontFamily
        fontWeight: root.tickLabelFontWeight
        showLabelOutline: root.showTickLabelOutline
        labelOutlineColor: root.tickLabelOutlineColor

        // Decorations
        showInnerCircles: root.showTickInnerCircles
        innerCircleDiameter: root.tickInnerCircleDiameter

        // 3D Effects
        tickGradient: root.tickGradient
        tickGlow: root.tickGlow
        tickGlowBlur: root.tickGlowBlur
        tickShadow: root.tickShadow
        tickShadowBlur: root.tickShadowBlur
    }

    // Layer 5: Value arc
    GaugeValueArc {
        anchors.fill: parent
        visible: root.showValueArc
        value: root.value
        minValue: root.minValue
        maxValue: root.maxValue
        startAngle: root.startAngle
        totalSweepAngle: root.sweepAngle
        warningThreshold: root.warningThreshold
        criticalThreshold: root.redlineStart
        normalColor: root.valueArcColor
        warningColor: root.warningColor
        criticalColor: root.criticalColor
        strokeWidth: 22
    }

    // Layer 6: Needle
    GaugeNeedle {
        anchors.fill: parent
        visible: root.showNeedle

        // Angle
        angle: root._needleAngle

        // Front body geometry
        frontLength: Math.min(root.width, root.height) / 2 - 60
        pivotWidth: root.needlePivotWidth
        frontTipWidth: root.needleTipWidth
        frontShape: root.needleShape
        frontColor: root.needleColor
        frontGradient: root.needleGradient
        frontBorderWidth: root.needleBorderWidth
        frontBorderColor: root.needleBorderColor

        // Head tip
        headTipShape: root.needleHeadTipShape
        headTipColor: root.needleColor
        headTipGradient: root.needleGradient

        // Rear body
        rearRatio: root.needleRearRatio
        rearShape: root.needleShape
        rearColor: root.needleRearColor
        rearGradient: root.needleGradient
        rearBorderWidth: root.needleBorderWidth
        rearBorderColor: root.needleBorderColor

        // Tail tip
        tailTipShape: root.needleTailTipShape
        tailTipColor: root.needleRearColor
        tailTipGradient: root.needleGradient

        // 3D Effects
        frontGradientStyle: root.needleGradientStyle
        hasShadow: root.needleShadow
        hasBevel: root.needleBevel
        bevelWidth: root.needleBevelWidth
        hasPivotShadow: root.needlePivotShadow
        lightAngle: root.needleLightAngle
        hasInnerGlow: root.needleInnerGlow
        innerGlowColor: root.needleInnerGlowColor
        hasOuterGlow: root.needleOuterGlow
        outerGlowColor: root.needleOuterGlowColor
    }

    // Layer 7: Center cap
    GaugeCenterCap {
        anchors.centerIn: parent
        visible: root.showCenterCap

        // Geometry
        diameter: root.centerCapDiameter
        borderWidth: root.centerCapBorderWidth

        // Appearance
        color: root.centerCapColor
        borderColor: root.centerCapBorderColor

        // Gradient effect (for metallic look)
        hasGradient: root.centerCapGradient
        gradientTop: root.centerCapGradientTop
        gradientBottom: root.centerCapGradientBottom

        // 3D Effects
        hasShadow: root.centerCapShadow
        hasHighlight: root.centerCapHighlight
    }

    // Layer 8: Digital readout (center)
    DigitalReadout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: Math.min(root.width, root.height) / 4
        visible: root.showDigitalReadout
        value: root.value
        unit: root.unit
        precision: 0
        valueFontSize: 32
        warningThreshold: root.warningThreshold
        criticalThreshold: root.redlineStart
    }

    // Layer 9: Label (bottom)
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        text: root.label
        font.family: root.gaugeLabelFontFamily
        font.pixelSize: root.gaugeLabelFontSize
        font.weight: root.gaugeLabelFontWeight
        color: root.tickColor
        visible: root.label !== ""
    }

    // Layer 10: Bezel (outermost)
    GaugeBezel {
        anchors.fill: parent
        visible: root.showBezel
        outerRadius: Math.min(root.width, root.height) / 2
        borderWidth: 20
        borderColor: root.bezelColor
    }
}
