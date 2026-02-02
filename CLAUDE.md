# CLAUDE.md - Project Intelligence for qml-gauges

This file provides context and guidelines for AI assistants working on this codebase.

## Project Overview

**qml-gauges** is a standalone QML component library for automotive and industrial gauge displays. Extracted from [devdash](https://github.com/devdash-project/devdash), a custom automotive dashboard for a rock crawling buggy running on Jetson Orin Nano.

### The DevDash Ecosystem

All projects are part of the [devdash-project](https://github.com/devdash-project) organization:

- **[devdash](https://github.com/devdash-project/devdash)** - Main dashboard application (C++/QML on Jetson Orin Nano)
- **[qml-gauges](https://github.com/devdash-project/qml-gauges)** - This library, standalone gauge components
- **[devdash-haltech-mock](https://github.com/devdash-project/haltech-mock)** - Python library for simulating Haltech ECU CAN bus data (PyPI: `devdash-haltech-mock`)
- **[devdash-mcp](https://github.com/devdash-project/devdash-mcp)** - MCP server for screenshot capture and AI tool integration

## Architecture

### Component Hierarchy (Three-Tier)

```
Templates (RadialGauge, future BarGauge, DrumOdometer)
    ↓ composed from
Compounds (GaugeTickRing, DigitalReadout, GaugeValueArc, GaugeZoneArc, RollingDigitReadout)
    ↓ composed from
Primitives (GaugeArc, GaugeFace, GaugeBezel, GaugeCenterCap, GaugeTick, GaugeTickLabel, GaugeNeedleTapered, GaugeNeedleClassic)
```

### QML Module Structure

```qml
import DevDash.Gauges 1.0            // Templates only (RadialGauge)
import DevDash.Gauges.Primitives 1.0 // Atomic building blocks
import DevDash.Gauges.Compounds 1.0  // Functional sub-assemblies
```

### Directory Layout

```
src/
├── radial/RadialGauge.qml      # Template
├── primitives/                  # 8 atomic components
└── compounds/                   # 5 compound components

explorer/
├── qml/
│   ├── Main.qml                # ApplicationWindow with Drawer + StackView
│   ├── components/             # Sidebar, PropertyPanel, PreviewArea
│   ├── editors/                # RealEditor, ColorEditor, BoolEditor, etc.
│   └── pages/                  # One page per component
```

## Build Commands

**Requires Qt 6.10+** (for QtQuick.Effects and CurveRenderer).

```bash
# Configure with Qt 6.10
cmake -B build -G Ninja -DCMAKE_PREFIX_PATH=$HOME/Qt/6.10.1/gcc_arm64

# Build (automatically runs qmllint critical error check)
cmake --build build

# Run the explorer
./build/explorer/qml-gauges-explorer

# Run full qmllint manually (shows all warnings)
cmake --build build --target qmllint

# Disable lint-on-build if needed (not recommended)
cmake -B build -DLINT_ON_BUILD=OFF
```

## Code Quality Requirements

**IMPORTANT**: The build automatically runs critical QML error checks via `qmllint`. Builds will fail if critical errors are detected.

### Automated Lint-on-Build (ENABLED BY DEFAULT)

The CMake build system automatically runs `qmllint` before compiling, filtering for **critical errors** that would break runtime:
- `Could not find property "X"` / `no property "X" exists` - Non-existent property assignments
- `Type X unavailable` - Failed component loading
- `is not a type` - Undefined types

Non-critical warnings (like QtQuick.Effects path hints) are ignored to avoid false positives.

```bash
# Build will fail on critical QML errors
cmake --build build

# Run full lint with all warnings
cmake --build build --target qmllint
```

### Manual QML Linting

For targeted linting during development:

```bash
# Lint specific file
/usr/lib/qt6/bin/qmllint -I build/qml path/to/file.qml

# Lint all QML in a directory
/usr/lib/qt6/bin/qmllint -I build/qml src/primitives/*.qml
```

**Common critical errors to fix:**
- `Could not find property "visible"` on ShapePath - Use conditional `strokeColor` instead
- `ComponentName is not a type` - Check module import and CMakeLists.txt registration
- `Type X unavailable` - Dependency component failed to load (check its errors first)

### QML Language Server / IDE Diagnostics (MANDATORY)

**IDE integration provides real-time QML error detection** with squiggly lines, just like clangd for C++.

The QML language server (qmlls at `/usr/lib/qt6/bin/qmlls`) is configured in `.vscode/settings.json` and provides:
- Import resolution errors
- Property type mismatches
- Unknown properties or components
- Binding errors
- Syntax errors

**After editing QML files, ALWAYS check for language server errors:**

```
mcp__ide__getDiagnostics
```

Or check a specific file:
```
mcp__ide__getDiagnostics with uri: "file:///path/to/file.qml"
```

**Do not consider QML work complete until both qmllint AND IDE diagnostics pass.**

### CMakeLists.txt Updates

When adding new QML files, update the corresponding CMakeLists.txt:
- `src/CMakeLists.txt` - For templates
- `src/primitives/CMakeLists.txt` - For primitives
- `src/compounds/CMakeLists.txt` - For compounds
- `explorer/CMakeLists.txt` - For explorer pages/components/editors

## Component Explorer

The explorer (`explorer/`) is both a development tool and demo application.

### Adding a New Component Page

1. Create `explorer/qml/pages/ComponentNamePage.qml` following this pattern:
   - Import the component's module
   - Define `title` and `description` properties
   - Define `properties` array with metadata for PropertyPanel
   - Use RowLayout with PreviewArea (60%) + PropertyPanel (40%)
   - Bind `previewArea.animationValue` for animated demos

2. Add entry to `explorer/qml/components/ComponentSidebar.qml`

3. Add file to `explorer/CMakeLists.txt` QML_FILES list

4. Run qmllint on the new file

### Property Metadata Format

```qml
property var properties: [
    {name: "propertyName", type: "real", min: 0, max: 100, default: 50, category: "Category"},
    {name: "colorProp", type: "color", default: "#00aaff", category: "Appearance"},
    {name: "boolProp", type: "bool", default: true, category: "Behavior"},
    {name: "intProp", type: "int", min: 0, max: 10, default: 5, category: "Geometry"}
]
```

Supported types: `real`, `int`, `bool`, `color`, `string`, `enum`

## Performance Considerations

Target: Jetson Orin Nano driving dual displays with four live camera feeds at 60fps.

- **No external dependencies** beyond QtQuick, QtQuick.Shapes, and QtQuick.Effects
- **Blur/glow effects** are expensive - use `layer.enabled: true` for caching
- **Use Qt6 MultiEffect** from `QtQuick.Effects` for glow, shadow, and blur effects (requires Qt 6.5+)

### Performance Testing

```bash
QSG_RENDER_TIMING=1 ./build/explorer/gauge-explorer    # Frame timing
QSG_VISUALIZE=overdraw ./build/explorer/gauge-explorer # Overdraw analysis
QSG_VISUALIZE=batches ./build/explorer/gauge-explorer  # Batch analysis
```

## API Design Principles

### Purely Declarative
Components work with zero configuration - all properties have sensible defaults.

### Bindable Everything
Users connect data via property bindings. The library has no opinion about data sources.

### Standard Property Names
Consistent across all gauge types:
- `value`, `minValue`, `maxValue` - Range and current value
- `unit`, `label` - Display text
- `warningThreshold`, `criticalThreshold` - Alert levels
- `animated`, `animationDuration` - Animation control

### Component Opacity Properties
Each component has its own opacity property (e.g., `arcOpacity`, `faceOpacity`, `needleOpacity`) rather than using the inherited `opacity` property, for finer control.

## MCP Server & Visual Verification

The MCP server (`devdash-mcp`) provides tools for interacting with the explorer and verifying visual output.

### CRITICAL: State vs Visual Verification

**DO NOT assume UI is working just because MCP state tools return property values.**

The explorer exposes two types of verification:
1. **State verification** (`qml_explorer_get_state`) - Reports property values. Does NOT verify rendering.
2. **Visual verification** (`screenshot_gauge_preview`) - Actually captures what's rendered on screen.

**Always use `screenshot_gauge_preview` to confirm visual changes.** Claiming "effects are working" based on state alone is incorrect.

### Explorer Screenshot Tools

```
# PRIMARY TOOL - Use this for all gauge visual verification
mcp__devdash__screenshot_gauge_preview

# This captures:
# - Left 60% of window (preview pane only, excludes property panel)
# - Center 80% of that (focuses on gauge)
# - Scaled to 50%
# - Uses ~5k tokens (not 25k like full screenshots)
```

The explorer layout is fixed:
```
+---------------------------+----------------+
|     Preview Area (60%)    | Property Panel |
|                           |     (40%)      |
|     +---------------+     |                |
|     |               |     |  [Scrollable   |
|     |    Gauge      |     |   properties]  |
|     |   (centered)  |     |                |
|     +---------------+     |                |
+---------------------------+----------------+
```

### Explorer Property Tools

```
# Navigate to a component page
mcp__devdash__qml_explorer_navigate(page="RadialGauge")

# Get current state (page, all property values)
mcp__devdash__qml_explorer_get_state

# Get/set individual properties
mcp__devdash__qml_explorer_get_property(name="needleGradient")
mcp__devdash__qml_explorer_set_property(name="needleGradient", value=true)

# List all properties with documentation
mcp__devdash__qml_explorer_list_properties
```

### Workflow for Verifying Visual Changes

1. **Make code changes** to component
2. **Build** with `cmake --build build`
3. **Restart explorer** if running (code changes require restart)
4. **Navigate** to component page with `qml_explorer_navigate`
5. **Set properties** to test the feature
6. **Capture screenshot** with `screenshot_gauge_preview` to verify visually
7. **Do not claim success** until screenshot shows expected result

### Process Management

```
# Check if explorer is running
mcp__devdash__qml_explorer_status

# Build the explorer
mcp__devdash__qml_explorer_build

# Launch explorer
mcp__devdash__qml_explorer_launch

# Kill explorer (needed to pick up code changes)
mcp__devdash__qml_explorer_kill
```

## Documentation

- `docs/DESIGN.md` - Architecture rationale and future vision
- `docs/EXTRACTION_PLAN.md` - Original extraction plan from devdash
- Component documentation is in Doxygen-style comments within QML files

## QML Best Practices

### Use Qt's Dynamic APIs Over Hardcoded Values

Prefer Qt's runtime discovery APIs over static lists:

```qml
// ❌ Brittle - hardcoded list may not match system
options: ["Arial", "Roboto", "Helvetica"]

// ✅ Robust - uses Qt's runtime discovery
options: Qt.fontFamilies()
```

Other dynamic Qt APIs to use:
- `Qt.fontFamilies()` - Available system fonts
- `Qt.platform.os` - Platform detection
- `Screen.pixelDensity` - DPI-aware sizing

### Property Type Safety

Use typed properties instead of `var` for compile-time checking:

```qml
// ❌ Loose - var accepts anything, no qmllint checks
property var angle
property var color

// ✅ Typed - errors caught by qmllint
property real angle: 0
property color fillColor: "#ffffff"
property int count: 0
property string label: ""
```

### Readonly for Computed Properties

Mark derived/computed properties as readonly to prevent accidental modification:

```qml
// ❌ Can be accidentally overwritten
property real trigAngle: (angle - 90) * Math.PI / 180

// ✅ Clear intent, compile-time protection
readonly property real trigAngle: (angle - 90) * Math.PI / 180
```

### Use pragma ComponentBehavior: Bound

For components with Repeaters or delegate contexts, use strict scoping:

```qml
pragma ComponentBehavior: Bound

Repeater {
    model: someModel
    delegate: Item {
        required property int index        // Must explicitly declare
        required property var modelData    // Must explicitly declare
    }
}
```

### Performance: CurveRenderer with Fallback

For smooth curves on Qt 6.10+, with fallback for older versions:

```qml
Shape {
    preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
        ? Shape.CurveRenderer
        : Shape.GeometryRenderer
}
```

### Performance: Layer Caching for Effects

Cache expensive items (blur, glow, complex shapes) to texture:

```qml
Item {
    layer.enabled: true  // Renders to texture once
    layer.smooth: true

    MultiEffect {
        // Effect only recalculates when layer content changes
    }
}
```

### Component Documentation

Use Doxygen-style comments for all public properties:

```qml
/**
 * @brief Rotation angle in degrees (0 = 3 o'clock).
 * @default 0
 */
property real angle: 0

/**
 * @brief Distance from gauge center to label center (pixels).
 *
 * Larger values position labels further from center.
 * Typically set slightly inside the tick ring.
 *
 * @default 80
 */
property real distanceFromCenter: 80
```

### Anti-Patterns to Avoid

**Don't mix anchors with explicit positioning:**
```qml
// ❌ Conflicting - anchors take precedence, x/y ignored
Text {
    anchors.centerIn: parent
    x: computedX  // This is ignored!
}

// ✅ Use one positioning system
Text {
    x: computedX
    y: computedY
}
```

**Don't hardcode sizes - use relative sizing:**
```qml
// ❌ Fixed pixels don't scale across displays
width: 400

// ✅ Relative to parent or use implicit size
width: parent.width * 0.8
implicitWidth: 400  // Suggestion, can be overridden
```

**Don't use Loader when direct instantiation works:**
```qml
// ❌ Unnecessary indirection, slower, no type checking
Loader { source: "GaugeTick.qml" }

// ✅ Direct instantiation (faster, type-checked by qmllint)
GaugeTick { }
```

Use Loader only when needed:
- Conditional loading (`active: someCondition`)
- Dynamic component switching at runtime
- Deferred loading for startup performance

**NEVER use relative file paths across QML module boundaries:**
```qml
// ❌ CRITICAL: Fails silently at runtime when loaded from qrc://
// Each QML module is a separate .so with its own resource file
Loader { source: "../Primitives/GaugeFace.qml" }

// ✅ Import the module and use component types directly
import DevDash.Gauges.Primitives 1.0
GaugeFace { }
```

This is a **silent failure** - qmllint won't catch it, builds succeed, but components fail to load at runtime. The build includes `verify-qml-loaders` target that catches cross-module Loader paths.

## Future Components (Planned)

- **BarGauge** - Linear horizontal/vertical gauge
- **DrumOdometer** - Mechanical rolling digit counter (Veeder-Root style)
- **MarqueeCountdown** - Vintage theatre illuminated digits
