# DevDash QML Gauges - Design & Architecture

This document captures the design decisions, architecture rationale, and future vision for the qml-gauges library. It's intended to preserve context that informed the initial extraction and guide future development.

## Project Context

This library was extracted from [devdash](https://github.com/devdash-project/devdash), a custom automotive dashboard application built for a rock crawling buggy. The goal was to make the gauge components reusable for anyone building automotive or industrial instrument displays with Qt/QML.

### The DevDash Ecosystem

All projects live under the `devdash-project` GitHub organization to show they're part of a cohesive system while being independently useful:

- **devdash** - Main dashboard application (C++/QML on Jetson Orin Nano)
- **haltech-mock** - Python library for simulating Haltech ECU CAN bus data
- **qml-gauges** - This library, standalone gauge components

## Architecture

### Component Hierarchy

The library follows a three-tier hierarchy:

```
Templates (RadialGauge, future BarGauge, etc.)
    ↓ composed from
Compounds (GaugeTickRing, DigitalReadout, GaugeValueArc, etc.)
    ↓ composed from
Primitives (GaugeArc, GaugeFace, GaugeNeedle, GaugeTick, etc.)
```

**Primitives** are atomic visual elements—a single arc, a single tick mark, a needle shape. They have no knowledge of gauge semantics like "value" or "range."

**Compounds** combine primitives into functional units—a ring of tick marks with labels, a value arc that sweeps based on input, a digital readout display.

**Templates** are complete, ready-to-use gauges that compose compounds and primitives with a high-level API (`value`, `minValue`, `maxValue`, `warningThreshold`, etc.).

### Why Sub-namespaces?

The library exposes three QML modules:

```qml
import DevDash.Gauges 1.0            // Templates only (RadialGauge)
import DevDash.Gauges.Primitives 1.0 // Atomic building blocks
import DevDash.Gauges.Compounds 1.0  // Functional sub-assemblies
```

**Rationale:**

1. **Flat namespace gets crowded** - With 14 components now and more planned, a single import would be overwhelming for autocomplete and documentation.

2. **Signals intent** - Most users only need `DevDash.Gauges`. Power users building custom gauges can import the lower-level modules. The hierarchy communicates "these are building blocks, use at your own discretion."

3. **Mirrors source structure** - The folder layout matches the import paths, making the mental model consistent.

4. **Future-proof** - When BarGauge, DrumOdometer, and MarqueeCountdown are added, they'll have their own primitives/compounds. Sub-namespaces keep this organized.

**Alternative considered:** Internal-only primitives (not exposed). Rejected because primitives have standalone value—the `PrimitivesTest.qml` harness in devdash proved that developers want to work with building blocks directly.

## Component Explorer

The explorer serves two purposes:

1. **Development tool** - Iterate on components in isolation with live property editing, without running the full devdash application
2. **Demo/showcase** - Help users evaluate the library and understand the API

### Design Inspiration

The explorer follows patterns from:

- **Storybook** (React ecosystem) - Component isolation, property controls, but we can't use it directly for QML
- **Qt Quick Controls Gallery** - ApplicationWindow + Drawer + StackView pattern
- No existing QML "storybook" was mature enough to adopt, so we built a custom solution

### Key Features

- Sidebar with categorized component list (Templates, Primitives, Compounds)
- Property panel with type-appropriate editors (sliders for reals, color pickers for colors, etc.)
- "Simulate" toggle that animates values to show gauges in motion
- Dark theme appropriate for automotive context
- Per-component demo pages with usage examples

## Performance Considerations

The primary deployment target is a Jetson Orin Nano driving dual displays with four live camera feeds. Performance matters.

### Testing Approach

```bash
# Frame timing output
QSG_RENDER_TIMING=1 ./gauge-explorer

# Overdraw visualization (key for blur/glow effects)
QSG_VISUALIZE=overdraw ./gauge-explorer

# Scene graph batching analysis
QSG_VISUALIZE=batches ./gauge-explorer
```

### Guidelines

- **Blur/glow effects** are the main performance concern. Use sparingly, cache with `layer.enabled: true` when possible.
- **Smooth animations at 60fps** across multiple gauges is the target. Keep needle animations lightweight.
- **No external dependencies** beyond QtQuick and QtQuick.Shapes—everything is programmatic rendering.

### Shader Effects Note

Qt GraphicalEffects is deprecated in Qt 6. Any glow or blur effects should use custom shaders or be designed to work without them. Consider pre-rendered glow textures for expensive effects.

## Future Components

These are planned but not yet implemented:

### BarGauge
Linear horizontal or vertical gauge. Simpler than RadialGauge but shares many primitives (tick marks, value visualization, thresholds).

### DrumOdometer (Tumbler Counter)
Mechanical-style rolling digit display, like vintage car odometers. Key details:

- Also called "Veeder-Root counters" or "tumbler odometers"
- The magic is in the animation: digits don't snap discretely. As you approach 100, the tens drum starts rotating slightly before the ones drum hits zero (mechanical gear linkage feel)
- Properties: `value` (real), `digits` (count), `decimals` (for tenths), `rolloverValue` (optional wrap)
- Primary use case in devdash: engine hours display

### MarqueeCountdown
Vintage theatre/carnival style illuminated digit display. Inspired by a countdown clock seen at a Zac Brown Band concert.

Key visual elements:
- Large incandescent bulb glow behind digit cutouts
- Warm bloom effect (shader-based or pre-rendered)
- Optional chaser light border (sequenced bulb animations)
- Animation: bulb intensity ramps on digit changes, slight flicker for authenticity

This is the most visually complex planned component and may require custom shaders for the glow effect.

## API Design Principles

### Purely Declarative

Components should work with zero configuration:

```qml
RadialGauge {
    value: 3500  // Just works with sensible defaults
}
```

All properties have defaults. No required C++ backend or data models.

### Bindable Everything

Users connect their data sources via property bindings:

```qml
RadialGauge {
    value: ecuData.rpm
    maxValue: ecuData.rpmLimit
    warningThreshold: ecuData.rpmLimit * 0.85
}
```

The library has no opinion about where data comes from.

### Standard Property Names

Consistent across all gauge types:

- `value` - Current value (real)
- `minValue` / `maxValue` - Range (real)
- `unit` - Unit label string
- `label` - Gauge label string  
- `warningThreshold` / `criticalThreshold` - Alert levels (real)
- `animated` - Enable/disable animations (bool)
- `animationDuration` - Animation timing in ms (int)

### Theming

Not yet implemented, but the direction is:

- Individual color properties (`primaryColor`, `warningColor`, `criticalColor`, `backgroundColor`)
- Possibly a `theme` property for presets (Racing, Vintage, Modern)
- Dark theme is the default and primary use case

## Python Compatibility

The library works with PySide6/PyQt6:

```python
from PySide6.QtQml import QQmlApplicationEngine

engine = QQmlApplicationEngine()
engine.addImportPath("/path/to/qml/modules")
engine.load("dashboard.qml")
```

The Python example in `examples/python/` demonstrates this integration.

## Build System

Uses modern CMake with `qt_add_qml_module()`:

- Three separate modules (Gauges, Primitives, Compounds) linked appropriately
- Explorer is a separate executable target
- Examples are optional (`-DBUILD_EXAMPLES=ON`)
- Install rules for system-wide QML module installation

Target: Qt 6.5+

## Contributing

The explorer makes it easy to develop new components:

1. Create the component in the appropriate directory (primitives/, compounds/, or a new template type)
2. Add it to the relevant qmldir and CMakeLists.txt
3. Create a demo page in `explorer/qml/pages/`
4. Use the explorer to iterate on properties and behavior

## References

- devdash project: https://github.com/devdash-project/devdash
- haltech-mock: https://github.com/devdash-project/haltech-mock
- Qt QML Module documentation: https://doc.qt.io/qt-6/qt-add-qml-module.html
- Qt Quick Shapes: https://doc.qt.io/qt-6/qtquick-shapes-qmlmodule.html