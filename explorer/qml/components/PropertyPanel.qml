pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Explorer
import "../editors"

ScrollView {
    id: root

    property var target          // The component instance to modify
    property var properties: []  // Property metadata array
    property var stateServer: null  // Optional state server for MCP integration

    // Map of property name -> editor item for bidirectional updates
    property var editorMap: ({})

    clip: true

    // Allow horizontal drags to pass through to child controls (sliders)
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    // Handle external property changes (from MCP/WebSocket)
    Connections {
        target: root.stateServer
        enabled: root.stateServer !== null

        function onSetPropertyRequested(name, value) {
            // Update the target component
            if (root.target && root.target[name] !== undefined) {
                root.target[name] = value
            }

            // Update the editor UI (bidirectional sync)
            const editor = root.editorMap[name]
            if (editor) {
                editor.value = value
            }

            // Notify state server of the change
            if (root.stateServer) {
                root.stateServer.updateProperty(name, value)
            }
        }
    }

    ColumnLayout {
        width: root.availableWidth
        spacing: 12

        // Header
        Label {
            text: "Properties"
            font.pixelSize: 16
            font.bold: true
            color: Theme.textPrimary
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.divider
        }

        // Property editors
        Repeater {
            id: editorRepeater
            model: root.properties

            Loader {
                id: editorLoader

                required property var modelData

                Layout.fillWidth: true

                sourceComponent: {
                    switch (editorLoader.modelData.type) {
                        case "real": return realEditor
                        case "int": return intEditor
                        case "color": return colorEditor
                        case "bool": return boolEditor
                        case "string": return stringEditor
                        case "enum": return enumEditor
                        default:
                            console.warn("Unknown property type:", editorLoader.modelData.type)
                            return null
                    }
                }

                onLoaded: {
                    if (!item) return

                    const propData = editorLoader.modelData

                    // Set editor properties
                    item.propertyName = propData.name

                    // Set type-specific properties
                    if (propData.min !== undefined) item.min = propData.min
                    if (propData.max !== undefined) item.max = propData.max
                    // Support both "values" and "options" for enum types
                    if (propData.values !== undefined) item.values = propData.values
                    if (propData.options !== undefined) item.values = propData.options
                    // Support value mapping for enums (e.g., Font.Bold -> 75)
                    if (propData.valueMap !== undefined) item.valueMap = propData.valueMap

                    // Set initial value from target or default
                    if (root.target && root.target[propData.name] !== undefined) {
                        item.value = root.target[propData.name]
                    } else if (propData.default !== undefined) {
                        item.value = propData.default
                        if (root.target) {
                            root.target[propData.name] = propData.default
                        }
                    }

                    // Register editor in map for bidirectional updates
                    root.editorMap[propData.name] = item

                    // Re-entrancy guard shared by the two sync directions below.
                    // While one direction is propagating, the other must not
                    // fire back — in particular a target→editor refresh must not
                    // re-push the value onto the target, or it would clobber the
                    // very binding we're mirroring (and break it permanently).
                    let syncing = false

                    // editor → target: a user edit (or an MCP setProperty routed
                    // through the editor) pushes the value onto the target,
                    // intentionally replacing any binding it had — that *is* the
                    // per-instance override. Also reported to the state server.
                    // (Don't use Qt.binding for target→editor — it conflicts with
                    // user input — hence the explicit signal wiring just below.)
                    item.valueChanged.connect(() => {
                        if (syncing || !root.target)
                            return
                        syncing = true
                        root.target[propData.name] = item.value
                        syncing = false
                        if (root.stateServer)
                            root.stateServer.updateProperty(propData.name, item.value)
                    })

                    // target → editor: when target[name] changes for any *other*
                    // reason — most importantly a binding re-evaluating, e.g.
                    // GaugeTheme.setTheme() flowing through
                    // RadialGauge.faceColor: GaugeTheme.colors.surface — mirror it
                    // into the editor UI and the state server. Without this,
                    // qml_explorer_get_state (and the editor) would keep showing
                    // the load-time value after a theme switch. The `syncing`
                    // guard means the editor's resulting valueChanged does NOT
                    // push back onto the target, so the binding survives.
                    if (root.target) {
                        const changedSignal = root.target[propData.name + "Changed"]
                        if (changedSignal && changedSignal.connect) {
                            changedSignal.connect(() => {
                                if (syncing || !root.target)
                                    return
                                const nv = root.target[propData.name]
                                syncing = true
                                item.value = nv
                                syncing = false
                                if (root.stateServer)
                                    root.stateServer.updateProperty(propData.name, nv)
                            })
                        }
                    }

                    // Initialize state server with current value
                    if (root.stateServer && root.target) {
                        root.stateServer.updateProperty(propData.name, item.value)
                    }
                }

                Component.onDestruction: {
                    // Clean up editor map entry
                    if (modelData && modelData.name) {
                        delete root.editorMap[modelData.name]
                    }
                }
            }
        }

        // Spacer to push properties to top
        Item {
            Layout.fillHeight: true
        }
    }

    // Clear editor map when properties change
    onPropertiesChanged: {
        root.editorMap = {}
    }

    // Publish every editor's current value to the state server the moment it's
    // wired in. Main.qml sets the page's `stateServer` from
    // StackView.onCurrentItemChanged — i.e. *after* the page (and therefore
    // this panel and its Repeater editors) finish constructing — so each
    // editor's onLoaded ran while `stateServer` was still null and its
    // per-property init call was skipped. Without this handler the state
    // server's runtime-values map stays empty until a user nudges an editor,
    // which is exactly what qml_explorer_get_state surfaces as `properties: {}`.
    onStateServerChanged: {
        if (!root.stateServer || !root.target)
            return
        for (const name in root.editorMap) {
            const editor = root.editorMap[name]
            if (editor)
                root.stateServer.updateProperty(name, editor.value)
        }
    }

    // Editor component definitions
    Component {
        id: realEditor
        RealEditor {}
    }

    Component {
        id: intEditor
        IntEditor {}
    }

    Component {
        id: colorEditor
        ColorEditor {}
    }

    Component {
        id: boolEditor
        BoolEditor {}
    }

    Component {
        id: stringEditor
        StringEditor {}
    }

    Component {
        id: enumEditor
        EnumEditor {}
    }
}
