import QtQuick
import DevDash.Gauges.Primitives 1.0
import DevDash.Gauges.Compounds 1.0

/**
 * @brief Premium 3D radial gauge showcase template.
 *
 * RadialGauge3D demonstrates photorealistic 3D effects available in the
 * gauge library. Unlike RadialGauge, this template prioritizes visual
 * fidelity over configurability.
 *
 * 3D Features enabled by default:
 * - Chrome3D bezel with ConicalGradient (cylindrical metal appearance)
 * - Domed center cap with spherical gradient
 * - Raised tick marks with bevel edges
 * - Glass overlay with curved highlight
 * - Gradient needle with glow and shadow
 * - Optional performance overlay for FPS monitoring
 *
 * @example
 * @code
 * RadialGauge3D {
 *     value: dataBroker.rpm
 *     minValue: 0
 *     maxValue: 8000
 *     label: "RPM"
 *     showPerformance: true
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
     * @brief Show performance overlay (FPS counter).
     * @default false
     */
    property bool showPerformance: false

    /**
     * @brief Show glass overlay effect.
     * @default true
     */
    property bool showGlass: true

    /**
     * @brief Glass overlay highlight intensity (0.0-1.0).
     * @default 0.2
     */
    property real glassIntensity: 0.2

    /**
     * @brief Show decorative bezel.
     * @default true
     */
    property bool showBezel: true

    /**
     * @brief Show digital numeric readout.
     * @default false
     */
    property bool showDigitalReadout: false

    // === Color Scheme ===

    /**
     * @brief Primary accent color.
     * @default "#ff6600" (orange)
     */
    property color accentColor: "#ff6600"

    /**
     * @brief Face background color.
     * @default "#0d0d0d" (near black)
     */
    property color faceColor: "#0d0d0d"

    /**
     * @brief Bezel chrome base color.
     * @default "#444444"
     */
    property color bezelColor: "#444444"

    /**
     * @brief Tick and text color.
     * @default "#cccccc"
     */
    property color tickColor: "#cccccc"

    /**
     * @brief Redline zone color.
     * @default "#cc2222"
     */
    property color redlineColor: "#cc2222"

    /**
     * @brief Warning zone color.
     * @default "#ffaa00"
     */
    property color warningColor: "#ffaa00"

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

    // === Implementation ===

    implicitWidth: 400
    implicitHeight: 400

    // Computed radius
    readonly property real _gaugeRadius: Math.min(width, height) / 2
    readonly property real _innerRadius: _gaugeRadius - 15  // Inside bezel

    // Computed needle angle based on value
    readonly property real _needleAngle: {
        const norm = (root.value - root.minValue) / (root.maxValue - root.minValue)
        const clamped = Math.max(0, Math.min(1, norm))
        return root.startAngle + (root.sweepAngle * clamped)
    }

    // Layer 1: Chrome3D Bezel (outermost visible)
    GaugeBezel {
        anchors.fill: parent
        visible: root.showBezel
        outerRadius: root._gaugeRadius
        innerRadius: root._gaugeRadius - 15
        style: "chrome3d"
        color: root.bezelColor
        chromeHighlight: Qt.lighter(root.bezelColor, 1.8)
        chromeShadow: Qt.darker(root.bezelColor, 2.0)
        chrome3dLightAngle: 45
    }

    // Layer 2: Background face (recessed)
    GaugeFace {
        anchors.centerIn: parent
        diameter: (root._gaugeRadius - 15) * 2
        color: root.faceColor
        useGradient: true
        gradientCenter: Qt.lighter(root.faceColor, 1.3)
        gradientEdge: root.faceColor
    }

    // Layer 3: Background arc track
    GaugeArc {
        anchors.fill: parent
        startAngle: root.startAngle
        sweepAngle: root.sweepAngle
        strokeColor: Qt.lighter(root.faceColor, 1.5)
        strokeWidth: 18
        arcOpacity: 0.5
        animated: false
    }

    // Layer 4: Redline zone arc
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
        strokeWidth: 18
    }

    // Layer 5: Tick ring with raised 3D effect
    GaugeTickRing {
        anchors.fill: parent

        // Values and geometry
        minValue: root.minValue
        maxValue: root.maxValue
        majorTickInterval: root.majorTickInterval
        minorTickInterval: root.minorTickInterval
        labelDivisor: root.labelDivisor
        startAngle: root.startAngle
        sweepAngle: root.sweepAngle

        // Position ticks inside bezel
        innerRadius: root._innerRadius - 5
        labelRadius: root._innerRadius - 40

        // Colors
        warningStart: root.warningThreshold
        criticalStart: root.redlineStart
        normalColor: root.tickColor
        warningColor: root.warningColor
        criticalColor: root.redlineColor

        // 3D Effects: ticks with glow
        tickGradient: true
        tickGlow: true
        tickGlowBlur: 0.3
        tickShadow: true
        tickShadowBlur: 0.2
    }

    // Layer 6: Value arc
    GaugeValueArc {
        anchors.fill: parent
        value: root.value
        minValue: root.minValue
        maxValue: root.maxValue
        startAngle: root.startAngle
        totalSweepAngle: root.sweepAngle
        warningThreshold: root.warningThreshold
        criticalThreshold: root.redlineStart
        normalColor: root.accentColor
        warningColor: root.warningColor
        criticalColor: root.redlineColor
        strokeWidth: 20
    }

    // Layer 7: Needle with full 3D effects
    GaugeNeedle {
        anchors.fill: parent

        // Angle
        angle: root._needleAngle

        // Front body geometry
        frontLength: root._innerRadius - 50
        pivotWidth: 10
        frontTipWidth: 3
        frontShape: "tapered"
        frontColor: root.accentColor
        frontGradient: true
        frontGradientStyle: "cylinder"

        // Head tip
        headTipShape: "pointed"
        headTipColor: root.accentColor
        headTipGradient: true

        // Rear body (counterweight)
        rearRatio: 0.2
        rearShape: "tapered"
        rearColor: Qt.darker(root.accentColor, 1.3)
        rearGradient: true

        // Tail tip
        tailTipShape: "tapered"
        tailTipColor: Qt.darker(root.accentColor, 1.3)
        tailTipGradient: true

        // 3D Effects - all enabled
        hasShadow: true
        hasBevel: true
        bevelWidth: 1.0
        hasPivotShadow: true
        lightAngle: -45
        hasInnerGlow: true
        innerGlowColor: Qt.lighter(root.accentColor, 1.5)
        hasOuterGlow: true
        outerGlowColor: root.accentColor
        outerGlowSpread: 0.3
    }

    // Layer 8: Domed center cap
    GaugeCenterCap {
        anchors.centerIn: parent
        diameter: 35

        // Base appearance
        color: root.bezelColor
        borderWidth: 2
        borderColor: Qt.lighter(root.bezelColor, 1.5)

        // Domed 3D effect
        domed: true
        domedHighlightX: 0.35
        domedHighlightY: 0.35
        domedHighlightColor: Qt.lighter(root.bezelColor, 2.5)
        domedMidtoneColor: root.bezelColor
        domedShadowColor: Qt.darker(root.bezelColor, 2.0)
        domedChromeReflection: true

        // Shadow for raised appearance
        hasShadow: true
        shadowBlur: 0.3
        shadowOpacity: 0.6
        shadowOffsetX: 2
        shadowOffsetY: 2
    }

    // Layer 9: Digital readout
    DigitalReadout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root._gaugeRadius * 0.35
        visible: root.showDigitalReadout
        value: root.value
        unit: root.unit
        precision: 0
        valueFontSize: 28
        warningThreshold: root.warningThreshold
        criticalThreshold: root.redlineStart
    }

    // Layer 10: Label
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 45
        text: root.label
        font.family: "Roboto"
        font.pixelSize: 16
        font.weight: Font.Bold
        color: root.tickColor
        visible: root.label !== ""
    }

    // Layer 11: Glass overlay (topmost visual layer)
    GlassOverlay {
        anchors.fill: parent
        visible: root.showGlass
        radius: root._gaugeRadius

        // Subtle glass effect
        highlightEnabled: true
        highlightIntensity: root.glassIntensity
        highlightAngle: 70

        vignetteEnabled: true
        vignetteIntensity: 0.1
        vignetteInnerRadius: 0.75

        reflectionEnabled: false
    }

    // Layer 12: Performance overlay (debug)
    PerformanceOverlay {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 8
        visible: root.showPerformance
        showGraph: true
    }
}
