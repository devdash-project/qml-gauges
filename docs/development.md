# Development Guide

This guide covers development workflows, testing, and debugging for qml-gauges.

## Quick Start

```bash
# Build the project
cmake -B build -DCMAKE_PREFIX_PATH=~/Qt/6.10.1/gcc_arm64
cmake --build build

# Run the explorer
./scripts/run-explorer.sh

# Run with debug visualization
./scripts/run-explorer-debug.sh overdraw
```

## Scripts

| Script | Description |
|--------|-------------|
| `scripts/run-explorer.sh` | Run the explorer application |
| `scripts/run-explorer-debug.sh [mode]` | Run with scene graph visualization |

### Debug Visualization Modes

```bash
./scripts/run-explorer-debug.sh overdraw   # Show pixel overdraw (default)
./scripts/run-explorer-debug.sh batches    # Show draw call batching
./scripts/run-explorer-debug.sh clip       # Show clipping regions
./scripts/run-explorer-debug.sh changes    # Flash on scene graph changes
./scripts/run-explorer-debug.sh render     # Console render timing
```

## Unit Testing

qml-gauges uses Qt Quick Test for QML component testing.

### Building Tests

```bash
# Configure with tests enabled
cmake -B build -DBUILD_TESTS=ON -DCMAKE_PREFIX_PATH=~/Qt/6.10.1/gcc_arm64

# Build tests
cmake --build build --target qml-gauges-tests

# Run tests
./build/tests/qml-gauges-tests

# Or via CTest
cd build && ctest --verbose
```

### Writing Tests

Tests are QML files using `QtTest.TestCase`:

```qml
import QtQuick
import QtTest
import DevDash.Gauges

TestCase {
    name: "MyComponentTests"
    when: windowShown

    MyComponent {
        id: component
    }

    function test_property() {
        compare(component.value, 50, "Default value")
    }

    function test_behavior() {
        component.value = 100
        compare(component.value, 100, "Value updated")
    }
}
```

### Test Files

| File | Tests |
|------|-------|
| `tests/tst_GaugeArc.qml` | Arc primitive properties and animation |
| `tests/tst_GaugeNeedle.qml` | Needle types, rotation, animation |
| `tests/tst_RadialGauge.qml` | Full gauge integration tests |

## Scene Graph Debugging

Qt's scene graph visualization helps identify rendering performance issues.

### Overdraw Analysis

```bash
QSG_VISUALIZE=overdraw ./build/explorer/qml-gauges-explorer
```

**Color Legend:**
- **Blue** = 1 draw per pixel (optimal)
- **Green** = 2 draws per pixel (acceptable)
- **Yellow/Orange** = 3-4 draws (review needed)
- **Red** = 5+ draws (optimize!)

**Common Overdraw Causes:**
- Overlapping transparent items
- Unnecessary Rectangle backgrounds
- Multiple Shape elements in same area

**Optimization Tips:**
- Use `layer.enabled: true` to cache complex items
- Set `visible: false` instead of `opacity: 0`
- Combine overlapping shapes where possible

### Batch Visualization

```bash
QSG_VISUALIZE=batches ./build/explorer/qml-gauges-explorer
```

Each color represents a separate draw call batch. Fewer colors = better batching.

**Batching Tips:**
- Items with same material batch together
- Avoid mixing blending modes
- Keep similar items adjacent in scene graph

### Change Detection

```bash
QSG_VISUALIZE=changes ./build/explorer/qml-gauges-explorer
```

Flashes white when scene graph nodes update. Constant flashing indicates unnecessary redraws.

**Reducing Unnecessary Updates:**
- Avoid property bindings that change every frame
- Use `Behavior` animations judiciously
- Cache expensive calculations in properties

### Render Timing

```bash
QSG_RENDER_TIMING=1 ./build/explorer/qml-gauges-explorer
```

Outputs timing info to console:
```
render: 16ms, sync: 2ms, render: 12ms, swap: 2ms
```

## Linting

Use Qt 6.10's qmllint for static analysis:

```bash
~/Qt/6.10.1/gcc_arm64/bin/qmllint -I build/qml src/**/*.qml explorer/qml/**/*.qml
```

**Common Warnings:**
- `[unqualified]` - Use `root.property` instead of `property`
- `[unused-imports]` - Remove unused import statements
- `[missing-property]` - Property doesn't exist on type

## Environment Variables

| Variable | Description |
|----------|-------------|
| `QSG_VISUALIZE` | `overdraw`, `batches`, `clip`, `changes` |
| `QSG_RENDER_TIMING` | `1` to enable render timing |
| `QT_QUICK_BACKEND` | `software` for CPU rendering |
| `QML2_IMPORT_PATH` | Additional QML import paths |
| `QT_DEBUG_PLUGINS` | `1` to debug plugin loading |

## IDE Setup

### VS Code

Recommended extensions:
- Qt for Python (provides QML syntax)
- CMake Tools
- C/C++ Extension Pack

### Qt Creator

Open `CMakeLists.txt` directly. Qt Creator auto-detects the project structure.

## Troubleshooting

### "Module not found" Errors

```bash
# Ensure QML import path includes build directory
export QML2_IMPORT_PATH=/path/to/qml-gauges/build/qml
```

### Slow Rendering

1. Check overdraw with `QSG_VISUALIZE=overdraw`
2. Verify GPU acceleration: `QT_QUICK_BACKEND=` (empty = GPU)
3. Profile with `QSG_RENDER_TIMING=1`

### CurveRenderer Not Working

Requires Qt 6.6+. Check version:
```bash
qmake --version
# or
~/Qt/6.10.1/gcc_arm64/bin/qmake --version
```

## References

- [Qt Quick Test](https://doc.qt.io/qt-6/qtquicktest-index.html)
- [Scene Graph Debugging](https://doc.qt.io/qt-6/qtquick-visualcanvas-scenegraph.html#scene-graph-debugging)
- [QML Best Practices](https://doc.qt.io/qt-6/qtquick-bestpractices.html)
