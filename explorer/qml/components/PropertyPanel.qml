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

    clip: true

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
                    if (propData.values !== undefined) item.values = propData.values

                    // Set initial value from target or default
                    if (root.target && root.target[propData.name] !== undefined) {
                        item.value = root.target[propData.name]
                    } else if (propData.default !== undefined) {
                        item.value = propData.default
                        if (root.target) {
                            root.target[propData.name] = propData.default
                        }
                    }

                    // Two-way binding: target property → editor
                    if (root.target) {
                        item.value = Qt.binding(() => root.target[propData.name])
                    }

                    // Two-way binding: editor → target property
                    item.valueChanged.connect(() => {
                        if (root.target) {
                            root.target[propData.name] = item.value
                        }
                    })
                }
            }
        }

        // Spacer to push properties to top
        Item {
            Layout.fillHeight: true
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
