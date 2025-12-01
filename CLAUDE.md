# CLAUDE.md - Project Intelligence for qml-gauges

This file provides context and guidelines for AI assistants working on this codebase.

## Project Overview

**qml-gauges** is a standalone QML component library for automotive and industrial gauge displays. Extracted from [devdash](https://github.com/devdash-project/devdash), a custom automotive dashboard for a rock crawling buggy running on Jetson Orin Nano.

### The DevDash Ecosystem

- **devdash** - Main dashboard application (C++/QML on Jetson Orin Nano)
- **haltech-mock** - Python library for simulating Haltech ECU CAN bus data
- **qml-gauges** - This library, standalone gauge components

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

```bash
# Configure and build
cmake -B build -G Ninja
cmake --build build

# Run the explorer
./build/explorer/gauge-explorer

# Lint QML files (MUST run after any QML changes)
# Use Qt 6.10 qmllint for CurveRenderer support
~/Qt/6.10.1/gcc_arm64/bin/qmllint -I build/qml src/**/*.qml explorer/qml/**/*.qml
```

## Code Quality Requirements

**IMPORTANT**: After creating or modifying ANY QML file, you MUST:
1. Run qmllint to check for static errors
2. Check IDE diagnostics via `mcp__ide__getDiagnostics` for language server errors

### QML Linting with qmllint (MANDATORY)

**Always run qmllint before considering QML changes complete.** This catches syntax errors, type issues, and circular dependencies at development time.

```bash
# Lint specific file
/usr/lib/qt6/bin/qmllint path/to/file.qml

# Lint all QML in a directory
/usr/lib/qt6/bin/qmllint src/primitives/*.qml
/usr/lib/qt6/bin/qmllint explorer/qml/pages/*.qml
```

The build directory must exist for qmllint to resolve module imports:
```bash
/usr/lib/qt6/bin/qmllint -I build/qml path/to/file.qml
```

**Common qmllint warnings to fix:**
- `ComponentName is not a type` - Module import or registration issue
- `Cannot read property 'X' of null` - Accessing properties on non-existent parent
- `unknown grouped property scope` - Invalid property group usage

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

- **No external dependencies** beyond QtQuick and QtQuick.Shapes
- **Blur/glow effects** are expensive - use `layer.enabled: true` for caching
- **Qt GraphicalEffects is deprecated** in Qt 6 - use custom shaders or avoid

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

## MCP Server

The project includes an MCP server for screenshot capture:
- Location: `tools/mcp/qmlgauges_mcp/`
- Use `mcp__qmlgauges__qmlgauges_list_windows` to find running explorer windows
- Use `mcp__qmlgauges__qmlgauges_screenshot` to capture screenshots for verification

## Documentation

- `docs/DESIGN.md` - Architecture rationale and future vision
- `docs/EXTRACTION_PLAN.md` - Original extraction plan from devdash
- Component documentation is in Doxygen-style comments within QML files

## Future Components (Planned)

- **BarGauge** - Linear horizontal/vertical gauge
- **DrumOdometer** - Mechanical rolling digit counter (Veeder-Root style)
- **MarqueeCountdown** - Vintage theatre illuminated digits
