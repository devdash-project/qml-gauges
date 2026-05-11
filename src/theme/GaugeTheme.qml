pragma Singleton
import QtQuick

/**
 * @brief Globally-active aesthetic state shared by every gauge in a dashboard.
 *
 * GaugeTheme is a singleton: there is exactly one instance per QML engine and
 * all gauges read their default styling from it. The C++ host (or any QML) can
 * switch the active preset and the light/dark mode at runtime — the intended
 * use is ambient-light-driven day/night switching on Moon Patrol's instrument
 * cluster.
 *
 * The theme exposes *concept-level tokens*, not gauge-specific properties. Each
 * gauge family maps the abstract tokens onto its own elements (a radial gauge
 * maps `surface` to its face color; a future bar gauge would map `surface` to
 * its background). The theme does not need to know about specific gauge types.
 *
 * Color tokens (vary by light/dark mode; exposed via `colors`):
 *   - background      — color behind everything (dashboard backdrop)
 *   - surface         — primary gauge body surface (radial face, bar background)
 *   - surfaceElevated — raised elements such as bezel rims
 *   - primary         — main accent: needles, dominant numerals, active arc
 *   - foreground      — marks on the surface: ticks, labels, secondary text
 *                       (the Material-design "onSurface" role; named `foreground`
 *                       here because a `on…`-prefixed property name is mis-parsed
 *                       as a signal handler by qmlcachegen)
 *   - warning         — warning-zone color (amber range, typically)
 *   - critical        — critical / redline zone color (red range, typically)
 *   - overlay         — glass / lens overlay tint (often transparent, or white
 *                       at low opacity)
 *
 * Non-color tokens (do not vary by mode):
 *   - typographyFontFamily        — primary text font
 *   - typographyNumeralFontFamily — numeral font (may differ; defaults to above)
 *   - typographyScale             — multiplier applied to all text sizes
 *   - effectsGlow                 — render glow effects (modern OLED look)
 *   - effectsShadow               — render drop shadows (physical-object look)
 *   - effectsTexture              — render textured surfaces (paint grain, etc.)
 *   - tickStyle                   — preferred tick shape: "rectangle" | "chevron"
 *                                   | "triangle" | "rounded-dot" | "block"
 *   - bezelStyle                  — preferred bezel: "flat" | "chrome" | "chrome3d"
 *
 * Concrete token values come from *presets* — `industrial` and `modernOEM`
 * below. They are defined inline as nested QtObjects rather than as separate
 * preset .qml files: a QML singleton that references same-module types is not
 * reliably loadable at runtime from a compiled qt_add_qml_module resource (the
 * auto-generated qmldir's `prefer :/...` line breaks the relative resolution
 * of the referenced types). See PLAN.md decisions log. Adding a new preset
 * (e.g. ClassicWhite) means adding another nested QtObject here.
 *
 * @example
 * @code
 * import DevDash.Gauges.Theme
 *
 * RadialGauge {
 *     // faceColor defaults to GaugeTheme.colors.surface, etc.
 *     needleColor: "#ff0000"   // per-instance override still wins
 * }
 *
 * // From C++ / QML: react to ambient light
 * GaugeTheme.setMode(ambientLux < 50 ? "dark" : "light")
 * GaugeTheme.setTheme("modernOEM")
 * @endcode
 */
QtObject {
    id: theme

    // ===================================================================
    // Presets — each carries a `light` + `dark` color set plus the
    // mode-independent (typography / effects / shape) tokens.
    // ===================================================================

    /**
     * @brief Industrial / military aesthetic preset (Moon Patrol's home).
     *
     * Matte-black painted surfaces, aged-cream marks, oxidized-red redline,
     * painted needle with a drop shadow — no glow / neon. Dark mode is the
     * night-vision look (warmer, dimmer — amber marks to preserve dark
     * adaptation). Mirrors the property defaults baked into IndustrialGauge.
     */
    readonly property QtObject industrial: QtObject {
        readonly property QtObject light: QtObject {
            readonly property color background: "#1a1a1a"       // dashboard backdrop
            readonly property color surface: "#0a0905"          // gauge face (dark warm black)
            readonly property color surfaceElevated: "#1a1815"  // bezel (warm matte black)
            readonly property color primary: "#d4cfc0"          // needle (painted aluminum)
            readonly property color foreground: "#e8e4d8"        // ticks & numerals (warm cream)
            readonly property color warning: "#a86820"          // warning zone (muted amber)
            readonly property color critical: "#7a1f15"         // redline (oxidized red)
            readonly property color overlay: "transparent"      // no glass overlay
        }
        readonly property QtObject dark: QtObject {
            readonly property color background: "#000000"
            readonly property color surface: "#000000"
            readonly property color surfaceElevated: "#0a0808"
            readonly property color primary: "#8a6020"          // amber needle for night vision
            readonly property color foreground: "#6a4818"        // amber numerals
            readonly property color warning: "#6a4010"
            readonly property color critical: "#5a1010"
            readonly property color overlay: "transparent"
        }
        readonly property string typographyFontFamily: "DIN, DIN 1451, sans-serif"
        readonly property string typographyNumeralFontFamily: typographyFontFamily
        readonly property real typographyScale: 1.0
        readonly property bool effectsGlow: false
        readonly property bool effectsShadow: true
        readonly property bool effectsTexture: false
        readonly property string tickStyle: "chevron"
        readonly property string bezelStyle: "flat"
    }

    /**
     * @brief Modern OEM digital-cluster aesthetic preset.
     *
     * Gradient near-black face inside a cylindrical chrome bezel, glass
     * overlay highlight, glowing ticks, gradient needle with glow + shadow,
     * bright accent. Dark mode is the night look (dimmer accent, less glare).
     * Derived from the property defaults baked into RadialGauge3D
     * (reference: Hyundai Palisade cluster).
     */
    readonly property QtObject modernOEM: QtObject {
        readonly property QtObject light: QtObject {
            readonly property color background: "#0a0d12"       // dark navy-black dashboard backdrop
            readonly property color surface: "#0d0d0d"          // gauge face (near black, gradient-shaded)
            readonly property color surfaceElevated: "#444444"  // chrome bezel base
            readonly property color primary: "#ff6600"          // accent: needle / value arc (orange)
            readonly property color foreground: "#cccccc"        // ticks & numerals (light grey)
            readonly property color warning: "#ffaa00"          // warning zone (amber)
            readonly property color critical: "#cc2222"         // redline (bright red)
            readonly property color overlay: "#1affffff"        // glass highlight tint (white @ ~10%)
        }
        readonly property QtObject dark: QtObject {
            readonly property color background: "#05070a"
            readonly property color surface: "#060606"
            readonly property color surfaceElevated: "#262626"  // dimmer chrome
            readonly property color primary: "#b35200"          // dimmed orange accent
            readonly property color foreground: "#7a7a7a"        // dimmed grey marks
            readonly property color warning: "#b37700"
            readonly property color critical: "#8a1717"
            readonly property color overlay: "#0dffffff"        // fainter glass highlight
        }
        readonly property string typographyFontFamily: "Roboto, Helvetica Neue, Arial, sans-serif"
        readonly property string typographyNumeralFontFamily: typographyFontFamily
        readonly property real typographyScale: 1.0
        readonly property bool effectsGlow: true
        readonly property bool effectsShadow: true
        readonly property bool effectsTexture: false
        readonly property string tickStyle: "rectangle"
        readonly property string bezelStyle: "chrome3d"
    }

    // ===================================================================
    // Active state
    // ===================================================================

    /**
     * @brief The preset whose tokens are currently in effect.
     *
     * Defaults to `industrial`. Switch via setTheme() or by assigning one of
     * the preset objects directly.
     */
    property QtObject activeTheme: industrial

    /**
     * @brief Active light/dark mode — "light" or "dark".
     *
     * Independent of the active preset. The C++ host sets this from ambient
     * light readings; QML reacts via the `colors` binding.
     */
    property string mode: "light"

    // ===================================================================
    // Computed: the active color set (depends on mode)
    // ===================================================================

    /**
     * @brief The color token set for the active preset and mode.
     *
     * Read tokens off this object, e.g. `GaugeTheme.colors.surface`. Rebinds
     * automatically when `activeTheme` or `mode` changes.
     */
    readonly property QtObject colors: mode === "dark"
        ? activeTheme.dark
        : activeTheme.light

    // ===================================================================
    // Computed: convenience accessors for non-color tokens
    // (these do not depend on mode)
    // ===================================================================

    readonly property string typographyFontFamily: activeTheme.typographyFontFamily
    readonly property string typographyNumeralFontFamily: activeTheme.typographyNumeralFontFamily
    readonly property real typographyScale: activeTheme.typographyScale
    readonly property bool effectsGlow: activeTheme.effectsGlow
    readonly property bool effectsShadow: activeTheme.effectsShadow
    readonly property bool effectsTexture: activeTheme.effectsTexture
    readonly property string tickStyle: activeTheme.tickStyle
    readonly property string bezelStyle: activeTheme.bezelStyle

    // ===================================================================
    // Imperative API for C++ or QML to switch themes
    // ===================================================================

    /** @brief Activate a registered preset by name ("industrial" | "modernOEM"). */
    function setTheme(themeName) {
        switch (themeName) {
        case "industrial": activeTheme = industrial; break
        case "modernOEM": activeTheme = modernOEM; break
        default: console.warn("GaugeTheme: unknown theme:", themeName); break
        }
    }

    /** @brief Set the active light/dark mode ("light" | "dark"). */
    function setMode(modeName) {
        if (modeName === "light" || modeName === "dark") {
            mode = modeName
        } else {
            console.warn("GaugeTheme: invalid mode:", modeName)
        }
    }
}
