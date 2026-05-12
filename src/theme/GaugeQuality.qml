pragma Singleton
import QtQuick

/**
 * @brief Globally-active graphics-quality state shared by every gauge.
 *
 * GaugeQuality is the lever for quality-sensitive rendering choices — the
 * runtime equivalent of a "graphics settings" panel. It is a singleton
 * (exactly one instance per QML engine) and, like GaugeTheme, can be switched
 * at runtime by the C++ host or by QML (e.g. drop to a reduced profile when
 * the cluster is under thermal/GPU pressure, or when driving extra camera
 * feeds).
 *
 * It is deliberately minimal right now: the single flag below selects between
 * the 2D and 3D rendering paths for visual elements that ship *both* (today:
 * the center hub — CenterCap3D vs. a form-shaded GaugeCenterCap). As more
 * effects gain a "best with / best without" pair, add flags here rather than
 * threading ad-hoc booleans through templates.
 *
 * Future expansion (documented, not yet implemented):
 *   - effectsTexturesEnabled       — once textured surfaces exist
 *   - effectsMultiEffectsEnabled   — gate richer MultiEffect chains
 *   - typographyScale override     — force low-fidelity text rendering
 *
 * @example
 * @code
 * import DevDash.Gauges.Theme
 *
 * // From C++ / QML, parallel to GaugeTheme switching:
 * GaugeQuality.setQuality(gpuBudgetLow ? "reduced" : "full")
 * @endcode
 */
QtObject {
    id: quality

    /**
     * @brief Whether Quick3D rendering paths are used where a 2D alternative
     * also exists.
     *
     * true  → use the 3D primitive (e.g. CenterCap3D) — "best with 3D".
     * false → use the 2D approximation (e.g. form-shaded GaugeCenterCap) —
     *         "best without 3D"; not a degraded fallback, a deliberate variant.
     *
     * @default true
     */
    property bool effects3DEnabled: true

    /**
     * @brief Set the quality profile by name ("full" | "reduced").
     *
     * Unknown names are ignored with a warning, leaving state unchanged.
     */
    function setQuality(level) {
        switch (level) {
        case "full": effects3DEnabled = true; break
        case "reduced": effects3DEnabled = false; break
        default: console.warn("GaugeQuality: unknown quality level:", level); break
        }
    }
}
