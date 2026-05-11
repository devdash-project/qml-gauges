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
 *   - onSurface       — marks on the surface: ticks, labels, secondary text
 *   - warning         — warning-zone color (amber range, typically)
 *   - critical        — critical / redline zone color (red range, typically)
 *   - overlay         — glass / lens overlay tint (often transparent)
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
 * Concrete token values come from *presets* (see presets/). Presets are an
 * implementation detail of the singleton, not part of the public API surface —
 * downstream code only ever touches GaugeTheme.
 */
QtObject {
    id: theme

    /**
     * @brief Active light/dark mode — "light" or "dark".
     *
     * Independent of the active preset. The C++ host sets this from ambient
     * light readings; QML reacts via the `colors` binding.
     */
    property string mode: "light"

    /** @brief Imperative API: set the active light/dark mode. */
    function setMode(modeName) {
        if (modeName === "light" || modeName === "dark") {
            mode = modeName
        } else {
            console.warn("GaugeTheme: invalid mode:", modeName)
        }
    }
}
