# QML Gauges Library Extraction Plan

## Overview

Extract the QML gauge components from devdash into a standalone, reusable library (`qml-gauges`) with a component explorer application.

## User Preferences

- **GitHub Organization**: `devdash-project` (https://github.com/devdash-project)
- **License**: MIT
- **Project Location**: `~/Projects/personal/devdash/qml-gauges`
- **Module URI**: `DevDash.Gauges`

## Analysis Summary

**Components to Extract (14 total):**
- 8 primitives (GaugeArc, GaugeFace, GaugeBezel, GaugeCenterCap, GaugeTick, GaugeTickLabel, GaugeNeedleTapered, GaugeNeedleClassic)
- 5 compounds (GaugeValueArc, GaugeZoneArc, GaugeTickRing, DigitalReadout, RollingDigitReadout)
- 1 template (RadialGauge)

**Dependencies**: NONE - all components use only `import QtQuick` and `import QtQuick.Shapes`

**Assets Required**: None (all rendering is programmatic)

**Status**: All components are complete with full Doxygen documentation

---

## Phase 0: Cleanup (devdash)

Delete backup files before extraction:
```
rm -rf /mnt/projects/Projects/devdash/src/cluster/qml/gauges/Tachometer.qml.backup
rm -rf /mnt/projects/Projects/devdash/src/cluster/qml/gauges/primitives.backup/
```

---

## Phase 1: Directory Structure Setup

### 1.1 Create Personal Projects Directory
```bash
mkdir -p ~/Projects/personal/devdash
```

### 1.2 Move Existing Repos
```bash
# Move devdash (after we finish current work)
mv /mnt/projects/Projects/devdash ~/Projects/personal/devdash/

# Move haltech-mock (if exists locally)
# mv ~/path/to/haltech-mock ~/Projects/personal/devdash/
```

### 1.3 Create qml-gauges Project Structure

**Design Decision:** Directory names are lowercase (Unix convention), while QML module URIs are PascalCase (Qt convention). CMake handles the mapping between physical directories and module URIs - they don't need to match.

```
~/Projects/personal/devdash/qml-gauges/
├── CMakeLists.txt                    # Root CMake (build options, subdirectories)
├── README.md                         # Project overview, build instructions
├── LICENSE                           # MIT License
├── .gitignore                        # Standard Qt/CMake ignores
├── .vscode/
│   └── settings.json                 # Language server config (clangd, qmlls, qmllint)
├── src/
│   ├── CMakeLists.txt                # Main module CMake
│   ├── qmldir                        # Main module (templates)
│   ├── radial/                       # lowercase directory
│   │   └── RadialGauge.qml          # PascalCase file
│   ├── primitives/                   # lowercase directory
│   │   ├── CMakeLists.txt           # Sub-module: DevDash.Gauges.Primitives (capitalized URI)
│   │   ├── qmldir
│   │   └── [8 primitive QML files]  # PascalCase files
│   ├── compounds/                    # lowercase directory
│   │   ├── CMakeLists.txt           # Sub-module: DevDash.Gauges.Compounds (capitalized URI)
│   │   ├── qmldir
│   │   └── [5 compound QML files]   # PascalCase files
│   └── [future: bar/, drum/, etc.]
├── explorer/
│   ├── CMakeLists.txt
│   ├── main.cpp
│   ├── qml/
│   │   ├── Main.qml                  # ApplicationWindow with Drawer
│   │   ├── components/
│   │   │   ├── ComponentSidebar.qml  # Navigation list
│   │   │   ├── PropertyPanel.qml     # Property editors
│   │   │   └── PreviewArea.qml       # Component display with controls
│   │   └── pages/
│   │       ├── WelcomePage.qml
│   │       ├── RadialGaugePage.qml
│   │       ├── GaugeArcPage.qml
│   │       └── [one page per component]
│   └── resources/
│       └── icons/                    # Play/pause icons for animation
├── examples/
│   ├── cpp/
│   │   ├── CMakeLists.txt
│   │   ├── main.cpp
│   │   └── Tachometer.qml            # Ported from devdash
│   └── python/
│       ├── requirements.txt          # PySide6
│       └── main.py
└── docs/
    ├── EXTRACTION_PLAN.md            # This document
    └── README.md                     # Links to component documentation
```

---

## Phase 2: Component Extraction

### 2.1 Copy Components
Copy from `~/Projects/personal/devdash/devdash/src/cluster/qml/gauges/radial/` to `qml-gauges/src/`

No code changes required - components are fully self-contained.

### 2.2 Module Structure (Sub-namespaces)

Users will import components with organized namespaces:
```qml
import DevDash.Gauges 1.0            // RadialGauge (main templates)
import DevDash.Gauges.Primitives 1.0 // GaugeArc, GaugeFace, etc.
import DevDash.Gauges.Compounds 1.0  // GaugeTickRing, DigitalReadout, etc.
```

**Directory structure for sub-modules (lowercase directories, capitalized URIs):**
```
src/
├── qmldir                    # Main module (templates only)
├── radial/                   # lowercase directory
│   └── RadialGauge.qml      # PascalCase file
├── primitives/               # lowercase directory
│   ├── qmldir                # URI: DevDash.Gauges.Primitives (capitalized)
│   ├── GaugeArc.qml
│   ├── GaugeBezel.qml
│   ├── GaugeCenterCap.qml
│   ├── GaugeFace.qml
│   ├── GaugeNeedleClassic.qml
│   ├── GaugeNeedleTapered.qml
│   ├── GaugeTick.qml
│   └── GaugeTickLabel.qml
└── compounds/                # lowercase directory
    ├── qmldir                # URI: DevDash.Gauges.Compounds (capitalized)
    ├── DigitalReadout.qml
    ├── GaugeTickRing.qml
    ├── GaugeValueArc.qml
    ├── GaugeZoneArc.qml
    └── RollingDigitReadout.qml
```

**qmldir files:**

```
# src/qmldir
module DevDash.Gauges
RadialGauge 1.0 radial/RadialGauge.qml
```

```
# src/primitives/qmldir
module DevDash.Gauges.Primitives
GaugeArc 1.0 GaugeArc.qml
GaugeBezel 1.0 GaugeBezel.qml
GaugeCenterCap 1.0 GaugeCenterCap.qml
GaugeFace 1.0 GaugeFace.qml
GaugeNeedleClassic 1.0 GaugeNeedleClassic.qml
GaugeNeedleTapered 1.0 GaugeNeedleTapered.qml
GaugeTick 1.0 GaugeTick.qml
GaugeTickLabel 1.0 GaugeTickLabel.qml
```

```
# src/compounds/qmldir
module DevDash.Gauges.Compounds
DigitalReadout 1.0 DigitalReadout.qml
GaugeTickRing 1.0 GaugeTickRing.qml
GaugeValueArc 1.0 GaugeValueArc.qml
GaugeZoneArc 1.0 GaugeZoneArc.qml
RollingDigitReadout 1.0 RollingDigitReadout.qml
```

### 2.3 Update Internal Imports
Components using relative paths need to be updated to use module imports:
- `GaugeValueArc.qml`: Change `"../primitives/GaugeArc.qml"` to use Loader with module path
- `GaugeZoneArc.qml`: Same
- `GaugeTickRing.qml`: Same
- `RadialGauge.qml`: Same

**Alternative**: Keep relative paths but adjust for new directory structure (`"primitives/GaugeArc.qml"` from radial/).

---

## Phase 3: CMake Configuration and Language Server Setup

### 3.1 Root CMakeLists.txt
```cmake
cmake_minimum_required(VERSION 3.21)
project(qml-gauges VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Export compile commands for clangd language server
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Find Qt6
find_package(Qt6 6.5 REQUIRED COMPONENTS Quick Qml)

# Build options
option(BUILD_EXPLORER "Build the component explorer application" ON)
option(BUILD_EXAMPLES "Build example applications" OFF)

# Add subdirectories
add_subdirectory(src)

if(BUILD_EXPLORER)
    add_subdirectory(explorer)
endif()

if(BUILD_EXAMPLES)
    add_subdirectory(examples/cpp)
endif()
```

### 3.2 Main Module CMakeLists.txt (src/CMakeLists.txt)
```cmake
# Main DevDash.Gauges module
qt_add_qml_module(devdash_gauges
    URI DevDash.Gauges
    VERSION 1.0
    QML_FILES
        radial/RadialGauge.qml
    RESOURCE_PREFIX /
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml/DevDash/Gauges
)

# Install library
install(TARGETS devdash_gauges
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Install QML module files
install(DIRECTORY ${CMAKE_BINARY_DIR}/qml/DevDash
    DESTINATION ${CMAKE_INSTALL_PREFIX}/qml
)

# Add sub-modules
add_subdirectory(primitives)
add_subdirectory(compounds)

# QML linting with qmllint
if(EXISTS /usr/lib/qt6/bin/qmllint)
    set(QMLLINT_EXECUTABLE /usr/lib/qt6/bin/qmllint)
else()
    find_program(QMLLINT_EXECUTABLE NAMES qmllint6 HINTS ${Qt6_DIR}/../../../bin)
endif()

if(QMLLINT_EXECUTABLE)
    set(QML_FILES_TO_LINT
        ${CMAKE_CURRENT_SOURCE_DIR}/radial/RadialGauge.qml
    )

    add_custom_target(qmllint-gauges
        COMMAND ${QMLLINT_EXECUTABLE} ${QML_FILES_TO_LINT}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running qmllint on DevDash.Gauges module"
        VERBATIM
    )

    message(STATUS "qmllint found: ${QMLLINT_EXECUTABLE}")
    message(STATUS "Run 'cmake --build build --target qmllint-gauges' to lint QML files")
else()
    message(WARNING "qmllint not found - QML linting disabled")
endif()
```

### 3.3 Primitives Sub-module (src/primitives/CMakeLists.txt)
```cmake
# DevDash.Gauges.Primitives sub-module
qt_add_qml_module(devdash_gauges_primitives
    URI DevDash.Gauges.Primitives
    VERSION 1.0
    QML_FILES
        GaugeArc.qml
        GaugeBezel.qml
        GaugeCenterCap.qml
        GaugeFace.qml
        GaugeNeedleClassic.qml
        GaugeNeedleTapered.qml
        GaugeTick.qml
        GaugeTickLabel.qml
    RESOURCE_PREFIX /
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml/DevDash/Gauges/Primitives
)

# Install library
install(TARGETS devdash_gauges_primitives
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# QML linting
if(QMLLINT_EXECUTABLE)
    set(PRIMITIVES_QML_FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeArc.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeBezel.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeCenterCap.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeFace.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeNeedleClassic.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeNeedleTapered.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeTick.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeTickLabel.qml
    )

    add_custom_target(qmllint-primitives
        COMMAND ${QMLLINT_EXECUTABLE} ${PRIMITIVES_QML_FILES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running qmllint on Primitives module"
        VERBATIM
    )
endif()
```

### 3.4 Compounds Sub-module (src/compounds/CMakeLists.txt)
Similar to primitives, with 5 compound QML files.

### 3.5 Language Server Configuration (.vscode/settings.json)
```json
{
    "clangd.arguments": [
        "--background-index",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--compile-commands-dir=${workspaceFolder}/build"
    ],
    "editor.formatOnSave": true,
    "[cpp]": {
        "editor.defaultFormatter": "llvm-vs-code-extensions.vscode-clangd"
    },
    "cmake.configureOnOpen": true,
    "cmake.generator": "Ninja",
    "C_Cpp.intelliSenseEngine": "disabled",
    "[qml]": {
        "editor.defaultFormatter": "theqtcompany.qt-qml",
        "editor.formatOnSave": true
    },
    "qt.qml.lintCommand": "/usr/lib/qt6/bin/qmllint",
    "qt.qml.lintOnSave": true,
    "qt.qml.languageServer": "/usr/lib/qt6/bin/qmlls",
    "qt.qml.importPaths": [
        "${workspaceFolder}/build/qml"
    ],
    "[cmake]": {
        "editor.formatOnSave": true
    },
    "errorLens.enabledDiagnosticLevels": [
        "error",
        "warning"
    ]
}
```

---

## Phase 4: Component Explorer

### Design Philosophy

Build a **simple, working explorer** - not a fully generic/dynamic system. Individual pages per component are fine for now. Structure the code so that a future refactor toward a generic "QML Storybook" project is straightforward.

**Goal**: When adding DrumOdometer in the future, add the QML file, add one entry to sidebar, and have working property controls via simple copy-paste-modify.

### Directory Structure

```
explorer/
├── CMakeLists.txt
├── main.cpp
├── qml/
│   ├── Main.qml                      # ApplicationWindow with Drawer + StackView
│   ├── components/
│   │   ├── ComponentSidebar.qml      # Navigation list (reads from pages)
│   │   ├── PropertyPanel.qml         # Renders property editors from metadata
│   │   └── PreviewArea.qml           # Component preview with dark background
│   ├── editors/                      # Reusable property editors
│   │   ├── RealEditor.qml            # Slider + value display
│   │   ├── IntEditor.qml             # SpinBox
│   │   ├── ColorEditor.qml           # Color picker button + dialog
│   │   ├── BoolEditor.qml            # Switch
│   │   ├── StringEditor.qml          # TextField
│   │   └── EnumEditor.qml            # ComboBox with values list
│   └── pages/
│       ├── WelcomePage.qml
│       ├── RadialGaugePage.qml
│       ├── GaugeArcPage.qml
│       └── [12 more component pages]
└── resources/
    └── icons/                        # Play/pause icons for animation
```

### Implementation Steps

#### 4.1 Create Directory Structure
Create the explorer directory tree:
```bash
mkdir -p explorer/qml/{components,editors,pages} explorer/resources/icons
```

#### 4.2 Create Reusable Editor Components

**editors/RealEditor.qml** - Slider for real values:
```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    property string propertyName
    property alias value: slider.value
    property real min: 0
    property real max: 100

    RowLayout {
        Label { text: propertyName; Layout.preferredWidth: 100 }
        Slider {
            id: slider
            from: min; to: max
            Layout.fillWidth: true
        }
        Label { text: value.toFixed(1); Layout.preferredWidth: 50 }
    }
}
```

**editors/IntEditor.qml**, **BoolEditor.qml**, **ColorEditor.qml**, **StringEditor.qml**, **EnumEditor.qml** follow similar patterns (see plan file for details).

#### 4.3 Create PropertyPanel Component

Dynamically loads the appropriate editor for each property:

```qml
import QtQuick
import QtQuick.Controls
import "../editors"

ScrollView {
    property var target          // The component instance to modify
    property var properties: []  // Property metadata array

    ColumnLayout {
        Repeater {
            model: properties
            Loader {
                sourceComponent: {
                    switch (modelData.type) {
                        case "real": return realEditor
                        case "int": return intEditor
                        case "color": return colorEditor
                        // ...
                    }
                }
                onLoaded: {
                    item.propertyName = modelData.name
                    if (modelData.min !== undefined) item.min = modelData.min
                    // Two-way binding
                    item.value = Qt.binding(() => target[modelData.name])
                    item.onValueChanged.connect(() => target[modelData.name] = item.value)
                }
            }
        }
    }

    Component { id: realEditor; RealEditor {} }
    Component { id: intEditor; IntEditor {} }
    // ...
}
```

#### 4.4 Create PreviewArea Component

Dark background + animation controls:

```qml
Item {
    property Item component
    property bool animating: false
    property real animationValue: 0

    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"  // Dark background for automotive aesthetic
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Button { text: animating ? "Pause" : "Play"; onClicked: animating = !animating }
        Slider { enabled: !animating; from: 0; to: 100; value: animationValue }
        Button { text: "Reset"; onClicked: { animating = false; animationValue = 0 } }
    }

    NumberAnimation on animationValue {
        running: animating
        from: 0; to: 100; duration: 3000
        loops: Animation.Infinite
    }
}
```

#### 4.5 Create Main.qml and ComponentSidebar

**Main.qml**:
```qml
import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 1280; height: 720
    visible: true
    title: "Gauge Component Explorer"

    Drawer {
        id: drawer
        width: 250
        height: parent.height

        ComponentSidebar {
            anchors.fill: parent
            onComponentSelected: stackView.push(component)
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "pages/WelcomePage.qml"
    }
}
```

**ComponentSidebar** - Navigation with categories (Templates, Primitives, Compounds).

#### 4.6 Create First Component Page (GaugeArc)

Thin page file - mostly declarative:

```qml
import QtQuick
import DevDash.Gauges.Primitives 1.0
import "../components"

Item {
    property var properties: [
        { name: "value", type: "real", min: 0, max: 100, default: 50 },
        { name: "startAngle", type: "real", min: -180, max: 180, default: -135 },
        { name: "color", type: "color", default: "#00ff00" }
    ]

    property string title: "GaugeArc"
    property string description: "Arc primitive for drawing gauge value arcs"

    GaugeArc {
        id: component
        anchors.centerIn: previewArea
        width: 250; height: 250
    }

    Row {
        anchors.fill: parent
        spacing: 20

        PreviewArea {
            id: previewArea
            width: parent.width * 0.6; height: parent.height
            component: component
        }

        PropertyPanel {
            width: parent.width * 0.4 - 20; height: parent.height
            target: component
            properties: root.properties
        }
    }
}
```

#### 4.7 Test and Iterate

Build and run the explorer with one component:
```bash
cmake --preset dev
cmake --build build/dev
./build/dev/gauge-explorer
```

Verify:
- Component renders in dark preview area
- Property editors update component in real-time
- Animation controls work

#### 4.8 Create Remaining 13 Component Pages

Copy-paste-modify pattern from GaugeArcPage.qml:
- RadialGaugePage.qml (50+ properties)
- 7 more primitive pages
- 5 compound pages
- WelcomePage.qml (landing page)

#### 4.9 Create CMakeLists.txt and main.cpp

**explorer/CMakeLists.txt**:
```cmake
qt_add_executable(gauge-explorer main.cpp)

qt_add_qml_module(gauge-explorer
    URI GaugeExplorer
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/components/ComponentSidebar.qml
        qml/components/PropertyPanel.qml
        qml/components/PreviewArea.qml
        qml/editors/RealEditor.qml
        qml/editors/IntEditor.qml
        qml/editors/ColorEditor.qml
        qml/editors/BoolEditor.qml
        qml/editors/StringEditor.qml
        qml/editors/EnumEditor.qml
        qml/pages/WelcomePage.qml
        qml/pages/RadialGaugePage.qml
        qml/pages/GaugeArcPage.qml
        # ... all 14 pages
)

target_link_libraries(gauge-explorer PRIVATE
    Qt6::Quick
    Qt6::Qml
    devdash_gauges
    devdash_gauges_primitives
    devdash_gauges_compounds
)
```

**explorer/main.cpp**:
```cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    engine.loadFromModule("GaugeExplorer", "Main");
    return app.exec();
}
```

#### 4.10 Final Integration

- Update root CMakeLists.txt to `add_subdirectory(explorer)`
- Build and test complete explorer
- Verify all 14 components work

### Future Refactor Path

This structure makes extracting a generic "QML Storybook" straightforward:
1. **PropertyPanel + editors/** → Move to standalone module
2. **Page metadata** → Extract to JSON files
3. **ComponentSidebar** → Read from registry JSON
4. **Pages** → Generate dynamically from metadata

---

## Phase 5: Examples

### 5.1 C++ Example (Tachometer)
Port `Tachometer.qml` from devdash as a usage example showing:
- How to import `DevDash.Gauges`
- Basic RadialGauge configuration
- Property bindings for live data

### 5.2 Python Example
```python
# main.py
import sys
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine

app = QApplication(sys.argv)
engine = QQmlApplicationEngine()
engine.addImportPath("path/to/qml")
engine.load("main.qml")
sys.exit(app.exec())
```

---

## Phase 6: GitHub Repository Setup

### 6.1 Transfer Existing Repos to Organization
Using GitHub web interface or CLI:
```bash
# Transfer devdash repo
gh repo transfer username/devdash devdash-project/devdash

# Transfer haltech-mock repo
gh repo transfer username/haltech-mock devdash-project/haltech-mock
```

### 6.2 Create qml-gauges Repo
```bash
cd ~/Projects/personal/devdash/qml-gauges
git init
git add .
git commit -m "Initial commit: QML gauge component library

Extracted from devdash project. Includes:
- RadialGauge template with 50+ configurable properties
- 8 atomic primitives (Arc, Bezel, CenterCap, Face, Tick, etc.)
- 5 compound components (TickRing, ValueArc, DigitalReadout, etc.)
- Component explorer application
- C++ and Python examples

Part of the devdash ecosystem:
- https://github.com/devdash-project/devdash
- https://github.com/devdash-project/haltech-mock"

gh repo create devdash-project/qml-gauges --public --source=. --push
```

### 6.3 Update git remotes in local repos
After transfer, update local remotes:
```bash
cd ~/Projects/personal/devdash/devdash
git remote set-url origin git@github.com:devdash-project/devdash.git

cd ~/Projects/personal/devdash/haltech-mock
git remote set-url origin git@github.com:devdash-project/haltech-mock.git
```

---

## Phase 7: Documentation

### 7.1 README.md Content
- Project description (part of devdash ecosystem)
- Links to sibling repos
- Status (RadialGauge complete, more gauges planned)
- Build instructions
- Usage example (QML import snippet)
- Explorer screenshot
- Contributing guidelines placeholder

### 7.2 Cross-Reference READMEs
Update devdash and haltech-mock READMEs to mention qml-gauges.

---

## Implementation Order

1. **Phase 0**: Delete backup files in devdash
2. **Phase 1.1-1.2**: Create directory structure, move repos locally
3. **Phase 2**: Extract components, create qmldir
4. **Phase 3**: Set up CMake (library first, verify it builds)
5. **Phase 4**: Build explorer (iteratively - start with navigation + one component)
6. **Phase 5**: Create examples
7. **Phase 6**: GitHub setup (transfer repos, create new repo)
8. **Phase 7**: Documentation

---

## Files to Reference During Implementation

From devdash:
- `src/cluster/qml/gauges/radial/RadialGauge.qml` - Main component, 50+ properties
- `src/cluster/qml/gauges/radial/primitives/*.qml` - All 8 primitives
- `src/cluster/qml/gauges/radial/compounds/*.qml` - All 5 compounds
- `src/cluster/qml/gauges/PrimitivesTest.qml` - Animation patterns to port
- `src/cluster/qml/gauges/Tachometer.qml` - Usage example to port
- `src/cluster/CMakeLists.txt` - Current qt_add_qml_module setup

---

## Future Enhancements (Not in Scope)

- BarGauge (linear gauge)
- DrumOdometer (mechanical tumbler counter)
- MarqueeCountdown (vintage theatre-style digits)
- Theme presets (Racing, Vintage, Modern)
- QML code generation/export from explorer
