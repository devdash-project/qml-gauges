import QtQuick
import DevDash.Gauges.Primitives 1.0
import DevDash.Gauges.Compounds 1.0

/**
 * @brief Industrial / military-aesthetic radial gauge preset.
 *
 * IndustrialGauge is a thin composite over the same primitives used by
 * RadialGauge, with property defaults that produce a painted, utilitarian
 * instrument aesthetic: matte black bezel and face, cream-painted chevron
 * ticks, oxidized-red redline zone, painted needle with drop shadow, and
 * no value-arc / glow / neon treatments.
 *
 * Public property API is a subset of RadialGauge so it can be used as a
 * drop-in substitute when the industrial aesthetic is wanted. A small
 * number of aesthetic knobs (face/bezel/needle/tick colors, label) are
 * exposed for downstream tweaks; everything else is internal.
 *
 * Reference target: docs/references/gauge-needle.png (painted orange
 * needle, filled hub disc, soft drop shadow); broader aesthetic from
 * Auto Meter Antique Beige and Speedhut JDM Datsun Z (black variant).
 *
 * @example
 * @code
 * IndustrialGauge {
 *     value: dataBroker.rpm
 *     minValue: 0
 *     maxValue: 8000
 *     label: "TACH"
 *     redlineStart: 6500
 * }
 * @endcode
 */
Item {
    id: root

    // === Public value API (mirrors RadialGauge) ===

    property real value: 0
    property real minValue: 0
    property real maxValue: 100
    property string label: ""
    property string unit: ""

    property real warningThreshold: maxValue
    property real redlineStart: maxValue

    property real startAngle: -225
    property real sweepAngle: 270

    // === Tick configuration ===

    property real majorTickInterval: (maxValue - minValue) / 10
    property real minorTickInterval: majorTickInterval / 5
    property real labelDivisor: 1

    // === Aesthetic overrides (industrial defaults pre-set) ===

    /** @brief Face plate fill — very dark warm black (painted dial). */
    property color faceColor: "#0a0905"

    /** @brief Bezel fill — warm matte black (painted metal ring). */
    property color bezelColor: "#1a1815"

    /** @brief Tick / numeral color — warm cream simulating aged paint. */
    property color tickColor: "#e8e4d8"

    /** @brief Needle body color — painted aluminum tone by default. */
    property color needleColor: "#d4cfc0"

    /** @brief Redline zone color — matte oxidized red, not glossy. */
    property color redlineColor: "#7a1f15"

    /**
     * @brief Optional paint-grain texture for the dial face.
     *
     * Not exposed via the explorer property panel UI; settable from QML.
     * If empty (default) the face is rendered as flat paint. textureSource
     * is rectangular-clipped (see audit), so leave at a paint-style texture
     * intended to be approximately square. A backlog item tracks sourcing
     * an actual paint-grain texture asset.
     */
    property string faceTextureSource: ""

    /**
     * @brief Font family for tick numerals and label.
     *
     * Font choice for IndustrialGauge is a deferred decision (see PLAN.md
     * open questions — candidates: DIN 1451, Allied Stencil, Eurostile,
     * Letter Gothic). The fallback chain below lets a FontLoader-installed
     * font take effect later without template changes.
     */
    property string fontFamily: "DIN, DIN 1451, sans-serif"

    // === Implementation ===

    implicitWidth: 400
    implicitHeight: 400

    readonly property real _needleAngle: {
        const norm = (root.value - root.minValue) / (root.maxValue - root.minValue)
        const clamped = Math.max(0, Math.min(1, norm))
        return root.startAngle + (root.sweepAngle * clamped)
    }

    readonly property real _gaugeSize: Math.min(root.width, root.height)

    // Layer 1: Painted face plate
    GaugeFace {
        anchors.centerIn: parent
        diameter: root._gaugeSize
        color: root.faceColor
        textureSource: root.faceTextureSource
    }

    // Layer 2: Redline zone arc — understated oxidized-red, no glow
    GaugeZoneArc {
        anchors.fill: parent
        visible: root.redlineStart < root.maxValue
        minValue: root.minValue
        maxValue: root.maxValue
        startValue: root.redlineStart
        endValue: root.maxValue
        gaugeStartAngle: root.startAngle
        gaugeTotalSweep: root.sweepAngle
        zoneColor: root.redlineColor
        zoneOpacity: 0.4
        strokeWidth: 14
    }

    // Layer 3: Tick ring — chevron ticks, cream paint, no effects
    GaugeTickRing {
        anchors.fill: parent
        minValue: root.minValue
        maxValue: root.maxValue
        majorTickInterval: root.majorTickInterval
        minorTickInterval: root.minorTickInterval
        labelDivisor: root.labelDivisor
        startAngle: root.startAngle
        sweepAngle: root.sweepAngle

        warningStart: root.warningThreshold
        criticalStart: root.redlineStart
        normalColor: root.tickColor
        warningColor: root.tickColor      // No software-UI amber state
        criticalColor: root.tickColor     // Redline zone arc is the cue

        tickShape: "chevron"
        majorTickLength: 18
        majorTickWidth: 3
        minorTickLength: 9
        minorTickWidth: 2

        fontSize: 18
        fontFamily: root.fontFamily
        fontWeight: Font.Bold

        showInnerCircles: false
        tickGradient: false
        tickGlow: false
        tickShadow: false
    }

    // Layer 4: Painted needle — drop shadow, cylinder gradient, no glow
    GaugeNeedle {
        anchors.fill: parent

        angle: root._needleAngle

        frontLength: root._gaugeSize / 2 - 50
        pivotWidth: 12
        frontTipWidth: 3
        frontShape: "tapered"
        frontColor: root.needleColor
        frontGradient: true
        frontGradientStyle: "cylinder"

        headTipShape: "pointed"
        headTipColor: root.needleColor

        rearRatio: 0.0
        tailTipShape: "none"

        hasShadow: true
        shadowOffset: 4
        hasBevel: false
        hasInnerGlow: false
        hasOuterGlow: false
        hasPivotShadow: false
    }

    // Layer 5: Painted hub disc covering pivot — filled, not a ring
    GaugeCenterCap {
        anchors.centerIn: parent
        diameter: 30
        color: root.bezelColor
        borderWidth: 0
        borderColor: "transparent"
        hasGradient: false
        hasShadow: false
        hasHighlight: false
        domed: false
    }

    // Layer 6: Label rendered inside the dial face (not bottom margin)
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root._gaugeSize * 0.22
        text: root.label
        font.family: root.fontFamily
        font.pixelSize: 20
        font.weight: Font.Bold
        font.letterSpacing: 2
        color: root.tickColor
        visible: root.label !== ""
    }

    // Layer 7: Bezel — flat matte black ring, outermost
    GaugeBezel {
        anchors.fill: parent
        outerRadius: root._gaugeSize / 2
        innerRadius: root._gaugeSize / 2 - 14
        style: "flat"
        color: root.bezelColor
        borderWidth: 0
    }
}
