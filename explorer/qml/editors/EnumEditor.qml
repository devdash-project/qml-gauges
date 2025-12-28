import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Explorer

RowLayout {
    id: root

    property string propertyName
    property var values: []  // Array of strings: ["tapered", "classic"]
    property var valueMap: ({})  // Optional: map display labels to actual values (for enums like Font.Bold)
    property var value  // Can be string or mapped value type

    // Internal: get the display label for current value
    readonly property string displayLabel: {
        if (Object.keys(root.valueMap).length > 0) {
            // Find label by value in valueMap
            for (var label in root.valueMap) {
                if (root.valueMap[label] === root.value) {
                    return label
                }
            }
        }
        return root.value
    }

    spacing: 10

    Label {
        text: root.propertyName
        Layout.preferredWidth: 120
        horizontalAlignment: Text.AlignLeft
        color: Theme.textPrimary
    }

    ComboBox {
        id: comboBox
        Layout.fillWidth: true
        model: root.values
        currentIndex: root.values.indexOf(root.displayLabel)
        onActivated: (index) => {
            var label = root.values[index]
            // Use mapped value if available, otherwise use label directly
            if (Object.keys(root.valueMap).length > 0 && root.valueMap[label] !== undefined) {
                root.value = root.valueMap[label]
            } else {
                root.value = label
            }
        }

        contentItem: Text {
            leftPadding: 10
            text: comboBox.displayText
            font: comboBox.font
            color: Theme.textValue
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 120
            implicitHeight: 32
            color: Theme.inputBackground
            border.color: comboBox.activeFocus ? Theme.accentColor : Theme.inputBorder
            border.width: 1
            radius: 4
        }

        indicator: Canvas {
            id: canvas
            x: comboBox.width - width - comboBox.rightPadding
            y: comboBox.topPadding + (comboBox.availableHeight - height) / 2
            width: 12
            height: 8
            contextType: "2d"

            Connections {
                target: Theme
                function onDarkChanged() { canvas.requestPaint() }
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.moveTo(0, 0)
                ctx.lineTo(width, 0)
                ctx.lineTo(width / 2, height)
                ctx.closePath()
                ctx.fillStyle = Theme.textSecondary
                ctx.fill()
            }
        }

        popup: Popup {
            y: comboBox.height - 1
            width: comboBox.width
            implicitHeight: Math.min(contentItem.contentHeight + 2, 300)
            padding: 1

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: comboBox.popup.visible ? comboBox.delegateModel : null
                currentIndex: comboBox.highlightedIndex
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: ScrollBar {
                    active: true
                    policy: ScrollBar.AsNeeded
                }
            }

            background: Rectangle {
                color: Theme.inputBackground
                border.color: Theme.inputBorder
                radius: 4
            }
        }

        delegate: ItemDelegate {
            width: comboBox.width
            contentItem: Text {
                text: modelData
                color: highlighted ? "#ffffff" : Theme.textValue
                font: comboBox.font
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            highlighted: comboBox.highlightedIndex === index
            background: Rectangle {
                color: highlighted ? Theme.accentColor : "transparent"
            }
        }
    }
}
