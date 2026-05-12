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
 *   - bezelHighlight  — colour of the bezel's inner-edge highlight band (only
 *                       meaningful when bezelHasInnerHighlight is set)
 *   - faceHighlight   — colour of the face's outer highlight ring (only
 *                       meaningful when faceHasOuterHighlight is set)
 *
 * Non-color tokens (do not vary by mode):
 *   - typographyFontFamily        — primary text font
 *   - typographyNumeralFontFamily — numeral font (may differ; defaults to above)
 *   - typographyNumeralFontWeight — numeral font weight (Font.Bold default)
 *   - typographyScale             — multiplier applied to all text sizes
 *   - effectsGlow                 — render glow effects (modern OLED look)
 *   - effectsShadow               — render drop shadows (physical-object look)
 *   - effectsTexture              — render textured surfaces (paint grain, etc.)
 *   - effectsTextShading          — apply form shading (painted depth) to face
 *                                   text such as tick numerals — distinct from
 *                                   `effectsShadow` (which is for solid objects
 *                                   like the needle): a preset can render
 *                                   painted depth on its numerals without
 *                                   implying every glyph has a drop shadow,
 *                                   and vice versa
 *   - effectsTextShadingMode      — when effectsTextShading is on, which look:
 *                                   "shadow" (directional offset shadow —
 *                                   painted relief) | "halo" (centered coloured
 *                                   glow — the vintage white-face numeral look)
 *   - effectsTextShadingColor     — colour of that shadow/halo (a colour token
 *                                   that is deliberately mode-independent — it
 *                                   reads as paint/aura, not as a lit surface)
 *   - centerCapStyle              — preferred centre-hub form: "flat" (a plain
 *                                   disc) | "dome" (a raised cone/dome — renders
 *                                   as Quick3D's CenterCap3D when GaugeQuality
 *                                   allows 3D, else a form-shaded 2D GaugeCenterCap)
 *   - tickStyle                   — preferred tick shape: "rectangle" | "chevron"
 *                                   | "triangle" | "rounded-dot" | "block"
 *   - bezelStyle                  — preferred bezel: "flat" | "chrome" | "chrome3d"
 *   - bezelHasInnerHighlight      — render the flat bezel's inner-edge highlight
 *                                   band (curved-metal catching-light cue)
 *   - faceHasOuterHighlight       — render a bright ring on the face's outer
 *                                   edge (the bright halo just inside the bezel)
 *
 * Concrete token values come from *presets* — `industrial`, `modernOEM` and
 * `classicWhite` below. They are defined inline as nested QtObjects rather
 * than as separate preset .qml files: a QML singleton that references
 * same-module types is not reliably loadable at runtime from a compiled
 * qt_add_qml_module resource (the auto-generated qmldir's `prefer :/...` line
 * breaks the relative resolution of the referenced types). See PLAN.md
 * decisions log. Adding another preset means updating THREE places in this
 * file (kept deliberately co-located): (1) the nested QtObject token set,
 * (2) a `case` in setTheme(), (3) an entry in `presetNames` + `presetMetadata`.
 *
 * `presetNames` / `presetMetadata` expose the preset registry as plain data so
 * a selector UI can be built declaratively rather than hardcoding preset names.
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
    // Bundled fonts
    //
    // FontLoaders are kept on the singleton so the font is loaded exactly
    // once per QML engine and is available globally. The `family` of each
    // loader resolves to the OS-reported family name once the font is
    // registered — referencing `barlowCondensedLoader.font.family` is the
    // safe way to use it from a `font.family` binding.
    //
    // Currently bundled: Barlow Condensed (SIL OFL, see src/assets/fonts/OFL.txt).
    // Used by the classicWhite preset for its geometric condensed numerals.
    // ===================================================================
    property FontLoader _barlowRegularLoader: FontLoader {
        source: "qrc:/DevDash/Gauges/Theme/fonts/BarlowCondensed-Regular.ttf"
    }
    property FontLoader _barlowSemiBoldLoader: FontLoader {
        source: "qrc:/DevDash/Gauges/Theme/fonts/BarlowCondensed-SemiBold.ttf"
    }
    property FontLoader _barlowBoldLoader: FontLoader {
        source: "qrc:/DevDash/Gauges/Theme/fonts/BarlowCondensed-Bold.ttf"
    }

    /**
     * @brief Family name of the bundled Barlow Condensed font.
     *
     * Resolves once the FontLoaders register the font with Qt. Refer to this
     * (rather than the literal string "Barlow Condensed") in `font.family`
     * bindings so the lookup is driven by the actual loaded font.
     */
    readonly property string barlowCondensedFamily: _barlowRegularLoader.name

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
     * adaptation). This is the default preset; a bare RadialGauge picks up
     * these tokens unless an instance overrides them.
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
            readonly property color bezelHighlight: "#3a3530"   // unused (bezelHasInnerHighlight false)
            readonly property color faceHighlight: "#ffffff"    // unused (faceHasOuterHighlight false)
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
            readonly property color bezelHighlight: "#1f1c18"   // unused
            readonly property color faceHighlight: "#2a2620"    // unused
        }
        readonly property string typographyFontFamily: "DIN, DIN 1451, sans-serif"
        readonly property string typographyNumeralFontFamily: typographyFontFamily
        readonly property int typographyNumeralFontWeight: Font.Bold
        readonly property real typographyScale: 1.0
        readonly property bool effectsGlow: false
        readonly property bool effectsShadow: true
        readonly property bool effectsTexture: false
        readonly property bool effectsTextShading: false
        readonly property string effectsTextShadingMode: "shadow"
        readonly property color effectsTextShadingColor: "#000000"
        readonly property string centerCapStyle: "flat"
        readonly property string tickStyle: "chevron"
        readonly property string bezelStyle: "flat"
        readonly property bool bezelHasInnerHighlight: false
        readonly property bool faceHasOuterHighlight: false
    }

    /**
     * @brief Modern OEM digital-cluster aesthetic preset.
     *
     * Gradient near-black face inside a cylindrical chrome bezel, glass
     * overlay highlight, glowing ticks, gradient needle with glow + shadow,
     * bright accent. Dark mode is the night look (dimmer accent, less glare).
     * Reference: the Hyundai Palisade digital cluster. (The bezelStyle /
     * effectsGlow tokens here anticipate effect plumbing that RadialGauge does
     * not yet read; the colour tokens are wired up today.)
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
            readonly property color bezelHighlight: "#888888"   // unused (bezelHasInnerHighlight false)
            readonly property color faceHighlight: "#ffffff"    // unused (faceHasOuterHighlight false)
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
            readonly property color bezelHighlight: "#444444"   // unused
            readonly property color faceHighlight: "#202020"    // unused
        }
        readonly property string typographyFontFamily: "Roboto, Helvetica Neue, Arial, sans-serif"
        readonly property string typographyNumeralFontFamily: typographyFontFamily
        readonly property int typographyNumeralFontWeight: Font.Bold
        readonly property real typographyScale: 1.0
        readonly property bool effectsGlow: true
        readonly property bool effectsShadow: true
        readonly property bool effectsTexture: false
        readonly property bool effectsTextShading: false
        readonly property string effectsTextShadingMode: "shadow"
        readonly property color effectsTextShadingColor: "#000000"
        readonly property string centerCapStyle: "flat"
        readonly property string tickStyle: "rectangle"
        readonly property string bezelStyle: "chrome3d"
        readonly property bool bezelHasInnerHighlight: false
        readonly property bool faceHasOuterHighlight: false
    }

    /**
     * @brief Vintage white-face aesthetic, inspired by classic aftermarket gauges.
     *
     * A cool pearl-white dial in a thick matte-black bezel, bold geometric
     * near-black numerals ringed by an orange-red halo, an orange-red painted
     * needle, and a domed orange centre hub — no chrome, no glass, no glow.
     * Light mode is the canonical daylight look; dark mode dims everything and
     * shifts the accent warmer (amber) to spare night vision, with the white
     * face dropped to a warm dark grey. Pair with RadialGauge's `scriptLabel` /
     * `brandLabel` slots for the lower-dial wordmark and branding line.
     */
    readonly property QtObject classicWhite: QtObject {
        readonly property QtObject light: QtObject {
            readonly property color background: "#1c1c1c"       // dark surround behind the gauge
            readonly property color surface: "#f4f3f0"          // pearl-white dial (cool, not cream)
            readonly property color surfaceElevated: "#171717"  // thick matte-black bezel
            readonly property color primary: "#d44820"          // orange-red painted needle
            readonly property color foreground: "#1a1a1a"        // dark warm numerals & ticks (haloed orange — see effectsTextShadingColor)
            readonly property color warning: "#c9851f"          // warning zone (muted amber)
            readonly property color critical: "#8f2c14"         // redline (deep red)
            readonly property color overlay: "transparent"      // no glass / lens overlay
            readonly property color bezelHighlight: "#3a3530"   // placeholder — wired in a later commit
            readonly property color faceHighlight: "#ffffff"    // placeholder — wired in a later commit
        }
        readonly property QtObject dark: QtObject {
            readonly property color background: "#0a0a0a"
            readonly property color surface: "#2b2620"          // dim warm grey (was white)
            readonly property color surfaceElevated: "#0d0d0d"  // deeper black bezel
            readonly property color primary: "#a85518"          // dimmed amber-shifted accent
            readonly property color foreground: "#974d16"        // dim amber numerals & ticks
            readonly property color warning: "#8a5810"
            readonly property color critical: "#6e2410"
            readonly property color overlay: "transparent"
            readonly property color bezelHighlight: "#241f1a"   // placeholder — wired in a later commit
            readonly property color faceHighlight: "#3a3328"    // placeholder — wired in a later commit
        }
        // Body text falls back to a generic stack; numerals use the bundled
        // Barlow Condensed for the geometric, condensed character of the
        // reference (Classic Instruments Velocity White) — a tall, slightly
        // condensed sans with closed apertures, much more "painted on" than
        // Helvetica/Roboto. Resolved from the FontLoader so the literal family
        // name is never hard-coded.
        readonly property string typographyFontFamily: "Helvetica Neue, Roboto Condensed, Arial, sans-serif"
        readonly property string typographyNumeralFontFamily: theme.barlowCondensedFamily
        readonly property int typographyNumeralFontWeight: Font.Bold  // heavier weight wired in a later commit
        readonly property real typographyScale: 1.0
        readonly property bool effectsGlow: false
        readonly property bool effectsShadow: true
        readonly property bool effectsTexture: false
        readonly property bool effectsTextShading: true  // dark numerals with a coloured halo
        readonly property string effectsTextShadingMode: "halo"
        readonly property color effectsTextShadingColor: "#d44820"  // orange-red aura around the dark glyphs
        readonly property string centerCapStyle: "dome"  // domed orange centre hub (3D cone, or 2D form-shaded dome)
        readonly property string tickStyle: "rectangle"
        readonly property string bezelStyle: "flat"
        readonly property bool bezelHasInnerHighlight: false  // wired in a later commit
        readonly property bool faceHasOuterHighlight: false   // wired in a later commit
    }

    // ===================================================================
    // Preset registry — enumerable metadata for selector UIs
    //
    // Keep these in sync with the nested QtObject definitions above and the
    // setTheme() cases below: adding a preset touches all three. Order here is
    // the order a selector should present them in. No `swatch` field yet — a
    // preset's representative colour is its own design question (backlogged).
    // ===================================================================

    /**
     * @brief Internal names of every registered preset, in display order.
     *
     * Matches the argument values setTheme() accepts.
     */
    readonly property var presetNames: ["industrial", "modernOEM", "classicWhite"]

    /**
     * @brief Human-readable metadata for each preset, keyed by internal name.
     *
     * Each entry has `displayName` (a proper-cased label, not the camelCase
     * internal name) and `description` (a one-line summary for tooltips).
     */
    readonly property var presetMetadata: ({
        "industrial": {
            "displayName": "Industrial",
            "description": "Military/utility aesthetic with painted face and chevron ticks"
        },
        "modernOEM": {
            "displayName": "Modern OEM",
            "description": "Contemporary digital cluster with chrome bezel and glow effects"
        },
        "classicWhite": {
            "displayName": "Classic White",
            "description": "Vintage white-face with orange-red painted numerals"
        }
    })

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
    readonly property int typographyNumeralFontWeight: activeTheme.typographyNumeralFontWeight
    readonly property real typographyScale: activeTheme.typographyScale
    readonly property bool effectsGlow: activeTheme.effectsGlow
    readonly property bool effectsShadow: activeTheme.effectsShadow
    readonly property bool effectsTexture: activeTheme.effectsTexture
    readonly property bool effectsTextShading: activeTheme.effectsTextShading
    readonly property string effectsTextShadingMode: activeTheme.effectsTextShadingMode
    readonly property color effectsTextShadingColor: activeTheme.effectsTextShadingColor
    readonly property string centerCapStyle: activeTheme.centerCapStyle
    readonly property string tickStyle: activeTheme.tickStyle
    readonly property string bezelStyle: activeTheme.bezelStyle
    readonly property bool bezelHasInnerHighlight: activeTheme.bezelHasInnerHighlight
    readonly property bool faceHasOuterHighlight: activeTheme.faceHasOuterHighlight

    // ===================================================================
    // Imperative API for C++ or QML to switch themes
    // ===================================================================

    /**
     * @brief Activate a registered preset by name ("industrial" | "modernOEM" | "classicWhite").
     *
     * When adding a preset, also update the nested QtObject above and
     * `presetNames` / `presetMetadata` — see the registry note.
     */
    function setTheme(themeName) {
        switch (themeName) {
        case "industrial": activeTheme = industrial; break
        case "modernOEM": activeTheme = modernOEM; break
        case "classicWhite": activeTheme = classicWhite; break
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
