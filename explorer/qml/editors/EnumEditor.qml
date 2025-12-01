import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Explorer

RowLayout {
    id: root

    property string propertyName
    property var values: []  // Array of strings: ["tapered", "classic"]
    property string value

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
        currentIndex: root.values.indexOf(root.value)
        onActivated: (index) => {
            root.value = root.values[index]
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
            implicitHeight: contentItem.implicitHeight
            padding: 1

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: comboBox.popup.visible ? comboBox.delegateModel : null
                currentIndex: comboBox.highlightedIndex

                ScrollIndicator.vertical: ScrollIndicator { }
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
