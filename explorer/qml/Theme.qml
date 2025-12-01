pragma Singleton
import QtQuick

QtObject {
    id: theme

    // Theme mode: true = dark, false = light
    property bool dark: true

    // Toggle function
    function toggle() {
        dark = !dark
    }

    // === Background Colors ===
    // Dark: GitHub dark inspired (#0d1117 base)
    // Light: Warm off-white with subtle gray tints
    readonly property color windowBackground: dark ? "#0d1117" : "#f6f8fa"
    readonly property color sidebarBackground: dark ? "#161b22" : "#ffffff"
    readonly property color headerBackground: dark ? "#161b22" : "#f6f8fa"
    readonly property color cardBackground: dark ? "#21262d" : "#ffffff"
    readonly property color categoryBackground: dark ? "#30363d" : "#eaeef2"

    // === Text Colors (high contrast) ===
    readonly property color textPrimary: dark ? "#f0f6fc" : "#1f2328"
    readonly property color textSecondary: dark ? "#8b949e" : "#656d76"
    readonly property color textMuted: dark ? "#6e7681" : "#8c959f"
    readonly property color textValue: dark ? "#e6edf3" : "#1f2328"

    // === Interactive Colors ===
    readonly property color accentColor: dark ? "#58a6ff" : "#0969da"
    readonly property color accentHover: dark ? "#79c0ff" : "#0550ae"
    readonly property color hoverBackground: dark ? "#21262d" : "#eaeef2"
    readonly property color selectedBackground: dark ? "#388bfd" : "#0969da"

    // === Border/Divider Colors ===
    readonly property color divider: dark ? "#30363d" : "#d0d7de"
    readonly property color border: dark ? "#30363d" : "#d0d7de"

    // === Control Colors ===
    readonly property color sliderTrack: dark ? "#30363d" : "#d0d7de"
    readonly property color sliderHandle: accentColor
    readonly property color inputBackground: dark ? "#0d1117" : "#ffffff"
    readonly property color inputBorder: dark ? "#30363d" : "#d0d7de"

    // === Special Purpose ===
    readonly property color boolTrue: dark ? "#3fb950" : "#1a7f37"
    readonly property color boolFalse: dark ? "#484f58" : "#8c959f"

    // === Preview Area ===
    readonly property color previewBackground: dark ? "#010409" : "#eaeef2"
    readonly property color previewGrid: dark ? "#161b22" : "#d0d7de"
}
