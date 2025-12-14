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

                    // One-way binding: editor → target property
                    // (Don't use Qt.binding for target→editor as it conflicts with user input)
                    item.valueChanged.connect(() => {
                        if (root.target) {
                            root.target[propData.name] = item.value

                            // Report to state server for MCP integration
                            if (root.stateServer) {
                                root.stateServer.updateProperty(propData.name, item.value)
                            }
                        }
                    })

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
