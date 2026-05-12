import QtQuick
import DevDash.Gauges.Primitives 1.0
import DevDash.Gauges.Compounds 1.0
import DevDash.Gauges.Theme 1.0

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

    /**
     * @brief Tick mark shape for major and minor ticks.
     *
     * Supported: "rectangle", "chevron", "triangle", "rounded-dot", "block".
     * Mirrors the theme's `tickStyle` token; per-instance assignment overrides.
     *
     * @default GaugeTheme.tickStyle
     */
    property string tickShape: GaugeTheme.tickStyle

    // === Color Scheme ===
    //
    // Defaults are derived from the active theme (see GaugeTheme). Assigning
    // any of these explicitly on an instance overrides the theme for that
    // gauge — the theme only supplies the default expression.

    /** @brief Gauge face plate fill. @default GaugeTheme.colors.surface */
    property color faceColor: GaugeTheme.colors.surface

    /** @brief Decorative bezel ring fill. @default GaugeTheme.colors.surfaceElevated */
    property color bezelColor: GaugeTheme.colors.surfaceElevated

    /** @brief Background arc track color. @default surface, lightened */
    property color backgroundArcColor: Qt.lighter(GaugeTheme.colors.surface, 1.3)

    /** @brief Value arc fill (normal range). @default GaugeTheme.colors.primary */
    property color valueArcColor: GaugeTheme.colors.primary

    /** @brief Needle body color. @default GaugeTheme.colors.primary */
    property color needleColor: GaugeTheme.colors.primary

    /** @brief Tick mark / numeral / label color. @default GaugeTheme.colors.foreground */
    property color tickColor: GaugeTheme.colors.foreground

    /** @brief Redline zone arc color. @default GaugeTheme.colors.critical */
    property color redlineColor: GaugeTheme.colors.critical

    /** @brief Warning-range tick / arc color. @default GaugeTheme.colors.warning */
    property color warningColor: GaugeTheme.colors.warning

    /** @brief Critical-range tick / arc color. @default GaugeTheme.colors.critical */
    property color criticalColor: GaugeTheme.colors.critical

    // === Bezel & Face Styling ===
    //
    // These mirror the theme's structural tokens (`bezelStyle`, `effectsTexture`)
    // so a preset can change a gauge's *structure*, not just its colours.
    // Per-instance assignment overrides the theme as usual.

    /**
     * @brief Decorative bezel rendering style.
     *
     * Supported: "flat" (solid colour), "chrome" (vertical metallic gradient),
     * "chrome3d" (cylindrical chrome via ConicalGradient).
     * Mirrors the theme's `bezelStyle` token.
     *
     * @default GaugeTheme.bezelStyle
     */
    property string bezelStyle: GaugeTheme.bezelStyle

    /**
     * @brief Width of the decorative bezel ring (pixels).
     *
     * The bezel is an annulus running from the gauge's outer edge inward by
     * this amount (it sets `GaugeBezel.innerRadius = outerRadius - bezelWidth`).
     * Defaults to a fraction of the gauge size so it scales with the gauge;
     * assign explicitly to override.
     *
     * @default 8% of min(width, height)
     */
    property real bezelWidth: Math.min(root.width, root.height) * 0.08

    /**
     * @brief Whether the gauge face renders a texture overlay.
     *
     * Mirrors the theme's `effectsTexture` token. When false the face is a
     * flat fill regardless of `faceTextureSource` — this is how a preset opts
     * out of texturing entirely.
     *
     * @default GaugeTheme.effectsTexture
     */
    property bool faceTexture: GaugeTheme.effectsTexture

    /**
     * @brief Texture image source for the gauge face (paint grain, carbon, …).
     *
     * Only applied when `faceTexture` is true. The library ships no texture
     * asset; this is a slot for downstream use.
     *
     * @default "" (no texture)
     */
    property string faceTextureSource: ""

    /**
     * @brief Render the flat bezel's inner-edge highlight band.
     *
     * A thin highlight along the bezel ring's inner edge that makes a flat
     * (uniform-colour) bezel read as gently curved metal catching light from
     * above — the matte painted-metal bezel look. Only affects the "flat"
     * bezel style. Mirrors the theme's `bezelHasInnerHighlight` token.
     *
     * @default GaugeTheme.bezelHasInnerHighlight
     */
    property bool bezelInnerHighlight: GaugeTheme.bezelHasInnerHighlight

    /**
     * @brief Colour the bezel inner-edge highlight peaks at.
     * @default GaugeTheme.colors.bezelHighlight
     */
    property color bezelInnerHighlightColor: GaugeTheme.colors.bezelHighlight

    /**
     * @brief Pixel width of the bezel inner-edge highlight band.
     *
     * Defaults to a fraction of the bezel width so it scales with the gauge —
     * roughly the curved "upper face" of a torus-shaped bezel rim.
     *
     * @default 45% of bezelWidth
     */
    property real bezelInnerHighlightWidth: root.bezelWidth * 0.45

    /**
     * @brief Render a bright highlight ring on the gauge face's outer edge.
     *
     * The bright halo just inside the bezel on classic white-face gauges,
     * where the dial's curved edge catches light. Mirrors the theme's
     * `faceHasOuterHighlight` token.
     *
     * @default GaugeTheme.faceHasOuterHighlight
     */
    property bool faceOuterHighlight: GaugeTheme.faceHasOuterHighlight

    /**
     * @brief Colour of the face outer highlight ring.
     * @default GaugeTheme.colors.faceHighlight
     */
    property color faceOuterHighlightColor: GaugeTheme.colors.faceHighlight

    /**
     * @brief Pixel width of the face outer highlight ring.
     * @default 4.5% of min(width, height)
     */
    property real faceOuterHighlightWidth: Math.min(root.width, root.height) * 0.045

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
     *
     * Mirrors the theme's `effectsShadow` token (the painted-object look).
     *
     * @default GaugeTheme.effectsShadow
     */
    property bool needleShadow: GaugeTheme.effectsShadow

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
     *
     * Mirrors the theme's `effectsGlow` token (the modern OLED-cluster look).
     *
     * @default GaugeTheme.effectsGlow
     */
    property bool needleOuterGlow: GaugeTheme.effectsGlow

    /**
     * @brief Outer glow color.
     * @default needleColor
     */
    property color needleOuterGlowColor: needleColor

    // === Center Cap Customization ===

    /**
     * @brief Centre-hub form: "flat" (plain disc) | "dome" (raised cone/dome).
     *
     * Mirrors the theme's `centerCapStyle` token. When "dome", the gauge picks
     * the rendering path from GaugeQuality: a Quick3D CenterCap3D cone when
     * `GaugeQuality.effects3DEnabled` is true, otherwise a form-shaded 2D
     * GaugeCenterCap that approximates the dome with an off-centre radial
     * gradient. Both are deliberate variants — the 2D one is not a degraded
     * fallback.
     *
     * @default GaugeTheme.centerCapStyle
     */
    property string centerCapStyle: GaugeTheme.centerCapStyle

    /**
     * @brief Diameter of center cap (pixels).
     * @default 30
     */
    property real centerCapDiameter: 30

    /**
     * @brief Center cap fill color.
     *
     * Defaults to the face colour for a flat hub, but to the theme's `primary`
     * accent for a domed hub (a domed centre is a styled feature, not part of
     * the dial surface).
     * @default centerCapStyle === "dome" ? GaugeTheme.colors.primary : faceColor
     */
    property color centerCapColor: centerCapStyle === "dome" ? GaugeTheme.colors.primary : faceColor

    /**
     * @brief Strength of the 2D dome's form shading, in [0, 1].
     *
     * Only used when `centerCapStyle` is "dome" and the 2D path is active
     * (`GaugeQuality.effects3DEnabled` is false).
     * @default 0.6
     */
    property real centerCapFormShadingIntensity: 0.6

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
     * @default GaugeTheme.typographyNumeralFontFamily
     */
    property string tickLabelFontFamily: GaugeTheme.typographyNumeralFontFamily

    /**
     * @brief Font size for tick labels (pixels).
     *
     * Base size 18, scaled by the theme's `typographyScale` token.
     *
     * @default 18 × GaugeTheme.typographyScale
     */
    property int tickLabelFontSize: Math.round(18 * GaugeTheme.typographyScale)

    /**
     * @brief Font weight for tick labels.
     *
     * Mirrors the theme's `typographyNumeralFontWeight` token.
     *
     * @default GaugeTheme.typographyNumeralFontWeight
     */
    property int tickLabelFontWeight: GaugeTheme.typographyNumeralFontWeight

    /**
     * @brief Font family for gauge label.
     * @default GaugeTheme.typographyFontFamily
     */
    property string gaugeLabelFontFamily: GaugeTheme.typographyFontFamily

    /**
     * @brief Font size for gauge label (pixels).
     *
     * Base size 18, scaled by the theme's `typographyScale` token.
     *
     * @default 18 × GaugeTheme.typographyScale
     */
    property int gaugeLabelFontSize: Math.round(18 * GaugeTheme.typographyScale)

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

    // === Face Text ===
    //
    // Two optional decorative text slots on the dial face. Both default to the
    // empty string (hidden). The library ships no wordmark of its own — these
    // exist so downstream users can place their own script word / branding
    // line in the spots a vintage gauge traditionally uses them.

    /**
     * @brief Decorative script word rendered just below the dial centre.
     *
     * Positioned so a needle resting near the bottom of the scale partially
     * overlays it — the place an aftermarket-gauge wordmark traditionally
     * goes. Rendered under the needle. Empty by default (hidden).
     *
     * @default "" (hidden)
     */
    property string scriptLabel: ""

    /**
     * @brief Small branding line rendered low on the dial face.
     *
     * Occupies the spot a manufacturer name would sit near 6 o'clock, inside
     * the dial (distinct from `label`, which is placed below the gauge).
     * Rendered under the needle. Empty by default (hidden).
     *
     * @default "" (hidden)
     */
    property string brandLabel: ""

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
     *
     * Mirrors the theme's `effectsGlow` token (the modern OLED-cluster look).
     *
     * @default GaugeTheme.effectsGlow
     */
    property bool tickGlow: GaugeTheme.effectsGlow

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

    /**
     * @brief Apply form-shading (painted-depth shadow) to tick numerals.
     *
     * Distinct from `tickShadow` (which applies a drop shadow to the tick
     * *marks*); this controls the labels' painted-depth appearance. Driven
     * by its own theme token `effectsTextShading` rather than the broader
     * `effectsShadow` so a preset can have a needle shadow without dragging
     * every numeral into a painted-relief look (the Industrial / ModernOEM
     * vocabulary is flat stencil/sans, not painted).
     *
     * @default GaugeTheme.effectsTextShading
     */
    property bool tickLabelFormShading: GaugeTheme.effectsTextShading

    /**
     * @brief Strength of tick-label form-shading in [0, 1].
     * @default 0.4
     */
    property real tickLabelFormShadingIntensity: 0.4

    /**
     * @brief Tick-label form-shading mode: "shadow" | "halo".
     *
     * "shadow" = directional painted-relief offset shadow; "halo" = centered
     * saturated glow (the vintage white-face numeral look). Mirrors the theme's
     * `effectsTextShadingMode` token.
     * @default GaugeTheme.effectsTextShadingMode
     */
    property string tickLabelFormShadingMode: GaugeTheme.effectsTextShadingMode

    /**
     * @brief Colour of the tick-label form-shading shadow / halo.
     *
     * Mirrors the theme's `effectsTextShadingColor` token. For "halo" mode this
     * should be a saturated accent distinct from the (dark) glyph colour.
     * @default GaugeTheme.effectsTextShadingColor
     */
    property color tickLabelFormShadingColor: GaugeTheme.effectsTextShadingColor

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
        textureSource: root.faceTexture ? root.faceTextureSource : ""
        hasOuterHighlight: root.faceOuterHighlight
        outerHighlightColor: root.faceOuterHighlightColor
        outerHighlightWidth: root.faceOuterHighlightWidth
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
        tickShape: root.tickShape

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
        labelFormShading: root.tickLabelFormShading
        labelFormShadingIntensity: root.tickLabelFormShadingIntensity
        labelFormShadingMode: root.tickLabelFormShadingMode
        labelFormShadingColor: root.tickLabelFormShadingColor
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

    // Layer 5b: Decorative script word on the face (sits under the needle)
    Text {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: Math.min(root.width, root.height) * 0.14
        text: root.scriptLabel
        visible: root.scriptLabel !== ""
        font.family: root.gaugeLabelFontFamily
        font.pixelSize: Math.round(Math.min(root.width, root.height) * 0.075)
        font.italic: true
        font.weight: Font.DemiBold
        font.letterSpacing: 1
        color: root.tickColor
    }

    // Layer 5c: Small branding line low on the face (sits under the needle)
    Text {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: Math.min(root.width, root.height) * 0.32
        text: root.brandLabel
        visible: root.brandLabel !== ""
        font.family: root.gaugeLabelFontFamily
        font.pixelSize: Math.round(Math.min(root.width, root.height) * 0.032)
        font.letterSpacing: 1
        color: root.tickColor
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
    //
    // Three rendering paths, picked by the theme's centerCapStyle token and the
    // global GaugeQuality flag:
    //   flat                       → capFlatComponent       (plain disc)
    //   dome + effects3DEnabled    → cap3DComponent         (Quick3D cone)
    //   dome + !effects3DEnabled   → capFlatDomeComponent   (form-shaded 2D dome)
    // The switch is dynamic: toggling GaugeQuality.effects3DEnabled at runtime
    // swaps the 3D cone and the 2D dome live. Either dome path shows a domed hub.
    Loader {
        id: centerCapLoader
        anchors.centerIn: parent
        visible: root.showCenterCap
        active: root.showCenterCap
        sourceComponent: root.centerCapStyle === "dome"
            ? (GaugeQuality.effects3DEnabled ? cap3DComponent : capFlatDomeComponent)
            : capFlatComponent
    }

    Component {
        id: capFlatComponent
        GaugeCenterCap {
            diameter: root.centerCapDiameter
            borderWidth: root.centerCapBorderWidth
            color: root.centerCapColor
            borderColor: root.centerCapBorderColor
            hasGradient: root.centerCapGradient
            gradientTop: root.centerCapGradientTop
            gradientBottom: root.centerCapGradientBottom
            hasShadow: root.centerCapShadow
            hasHighlight: root.centerCapHighlight
        }
    }

    Component {
        id: capFlatDomeComponent
        GaugeCenterCap {
            diameter: root.centerCapDiameter
            borderWidth: root.centerCapBorderWidth
            color: root.centerCapColor
            borderColor: root.centerCapBorderColor
            hasFormShading: true
            formShadingIntensity: root.centerCapFormShadingIntensity
            lightAngle: root.needleLightAngle
            hasShadow: root.centerCapShadow
        }
    }

    Component {
        id: cap3DComponent
        CenterCap3D {
            diameter: root.centerCapDiameter
            color: root.centerCapColor
            // Painted hub, not chrome: low metalness, matte-ish roughness.
            metalness: 0.0
            roughness: 0.5
            // Light from the upper-left to match the reference's apparent lighting.
            lightAngle: -45
        }
    }

    // Layer 8: Digital readout (center)
    DigitalReadout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: Math.min(root.width, root.height) / 4
        visible: root.showDigitalReadout
        value: root.value
        unit: root.unit
        precision: 0
        valueFontSize: Math.round(32 * GaugeTheme.typographyScale)
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

    // Layer 10: Bezel (outermost) — an annulus of width `bezelWidth` hugging
    // the gauge's outer edge. No inner flat-border ring: the bezel ring (flat
    // or chrome) is the whole visual element.
    GaugeBezel {
        anchors.fill: parent
        visible: root.showBezel
        outerRadius: Math.min(root.width, root.height) / 2
        innerRadius: outerRadius - root.bezelWidth
        borderColor: root.bezelColor
        color: root.bezelColor
        style: root.bezelStyle
        flatHasInnerHighlight: root.bezelInnerHighlight
        flatInnerHighlightColor: root.bezelInnerHighlightColor
        flatInnerHighlightWidth: root.bezelInnerHighlightWidth
    }
}
