pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Explorer

/**
 * @brief Collapsible panel displaying property documentation.
 *
 * Shows all properties grouped by category with their types, ranges,
 * and descriptions. Storybook-style documentation for the explorer.
 */
Rectangle {
    id: root

    property var properties: []  // Property metadata array from page
    property bool collapsed: false  // Start expanded to show documentation

    color: Theme.headerBackground
    clip: true

    // Group properties by category
    function groupByCategory(props) {
        const groups = {}
        const order = []

        for (let i = 0; i < props.length; i++) {
            const prop = props[i]
            const category = prop.category || "General"

            if (!groups[category]) {
                groups[category] = []
                order.push(category)
            }
            groups[category].push(prop)
        }

        return { groups: groups, order: order }
    }

    readonly property var grouped: groupByCategory(properties)

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header with collapse toggle
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            color: Theme.sidebarBackground

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 8
                spacing: 8

                Text {
                    text: root.collapsed ? "\u25B6" : "\u25BC"  // Triangle right/down
                    color: Theme.textSecondary
                    font.pixelSize: 10
                }

                Label {
                    text: "Property Documentation"
                    font.pixelSize: 13
                    font.bold: true
                    color: Theme.textPrimary
                    Layout.fillWidth: true
                }

                Label {
                    text: root.properties.length + " properties"
                    font.pixelSize: 11
                    color: Theme.textMuted
                }

                ToolButton {
                    text: root.collapsed ? "\u25BC" : "\u25B2"  // Down/Up arrow
                    font.pixelSize: 12
                    onClicked: root.collapsed = !root.collapsed

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: Theme.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.hovered ? Theme.hoverBackground : "transparent"
                        radius: 4
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.collapsed = !root.collapsed
                z: -1  // Behind the button
            }
        }

        // Content area (visible when not collapsed)
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !root.collapsed
            clip: true

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: root.width
                spacing: 0

                // Iterate through categories
                Repeater {
                    model: root.grouped.order

                    ColumnLayout {
                        id: categoryGroup

                        required property string modelData
                        readonly property var categoryProps: root.grouped.groups[modelData] || []

                        Layout.fillWidth: true
                        spacing: 0

                        // Category header
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 28
                            Layout.topMargin: 8
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8

                                Label {
                                    text: categoryGroup.modelData
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: Theme.accentColor
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 1
                                    color: Theme.divider
                                }
                            }
                        }

                        // Properties in this category
                        Repeater {
                            model: categoryGroup.categoryProps

                            Rectangle {
                                id: propItem

                                required property var modelData

                                Layout.fillWidth: true
                                Layout.preferredHeight: propContent.implicitHeight + 16
                                color: propMouse.containsMouse ? Theme.hoverBackground : "transparent"

                                MouseArea {
                                    id: propMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                }

                                ColumnLayout {
                                    id: propContent
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 12
                                    spacing: 2

                                    // Property name and type info
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6

                                        Label {
                                            text: propItem.modelData.name
                                            font.pixelSize: 12
                                            font.bold: true
                                            font.family: "monospace"
                                            color: Theme.textPrimary
                                        }

                                        Label {
                                            text: formatTypeInfo(propItem.modelData)
                                            font.pixelSize: 11
                                            color: Theme.textMuted
                                        }

                                        Item { Layout.fillWidth: true }

                                        // Default value badge
                                        Rectangle {
                                            visible: propItem.modelData.default !== undefined
                                            color: Theme.inputBackground
                                            radius: 3
                                            implicitWidth: defaultLabel.implicitWidth + 8
                                            implicitHeight: defaultLabel.implicitHeight + 4

                                            Label {
                                                id: defaultLabel
                                                anchors.centerIn: parent
                                                text: "default: " + formatDefault(propItem.modelData.default)
                                                font.pixelSize: 10
                                                font.family: "monospace"
                                                color: Theme.textSecondary
                                            }
                                        }
                                    }

                                    // Description
                                    Label {
                                        Layout.fillWidth: true
                                        text: propItem.modelData.description || "No description available."
                                        font.pixelSize: 11
                                        color: propItem.modelData.description ? Theme.textSecondary : Theme.textMuted
                                        font.italic: !propItem.modelData.description
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }
                        }
                    }
                }

                // Bottom spacer
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 12
                }
            }
        }
    }

    // Format type info string (e.g., "real, 0 to 100")
    function formatTypeInfo(prop) {
        let info = "(" + prop.type

        if (prop.min !== undefined && prop.max !== undefined) {
            info += ", " + prop.min + " to " + prop.max
        } else if (prop.values !== undefined) {
            info += ": " + prop.values.length + " options"
        } else if (prop.options !== undefined) {
            info += ": " + prop.options.length + " options"
        }

        info += ")"
        return info
    }

    // Format default value for display
    function formatDefault(val) {
        if (typeof val === "string") {
            // Truncate long strings
            return val.length > 15 ? '"' + val.substring(0, 12) + '..."' : '"' + val + '"'
        } else if (typeof val === "boolean") {
            return val ? "true" : "false"
        } else if (typeof val === "number") {
            return val.toString()
        }
        return String(val)
    }
}
