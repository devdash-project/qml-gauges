import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Explorer

RowLayout {
    id: root

    property string propertyName
    property alias value: spinBox.value
    property int min: 0
    property int max: 100

    spacing: 10

    Label {
        text: root.propertyName
        Layout.preferredWidth: 120
        horizontalAlignment: Text.AlignLeft
        color: Theme.textPrimary
    }

    SpinBox {
        id: spinBox
        from: root.min
        to: root.max
        Layout.fillWidth: true
        editable: true

        contentItem: TextInput {
            text: spinBox.textFromValue(spinBox.value, spinBox.locale)
            font: spinBox.font
            color: Theme.textValue
            selectionColor: Theme.accentColor
            selectedTextColor: "#ffffff"
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            readOnly: !spinBox.editable
            validator: spinBox.validator
            inputMethodHints: Qt.ImhFormattedNumbersOnly
        }

        background: Rectangle {
            implicitWidth: 140
            implicitHeight: 32
            color: Theme.inputBackground
            border.color: spinBox.activeFocus ? Theme.accentColor : Theme.inputBorder
            border.width: 1
            radius: 4
        }

        up.indicator: Rectangle {
            x: spinBox.mirrored ? 0 : parent.width - width
            height: parent.height
            implicitWidth: 28
            implicitHeight: 28
            color: spinBox.up.pressed ? Theme.accentColor : Theme.hoverBackground
            border.color: Theme.inputBorder
            radius: 4

            Text {
                text: "+"
                font.pixelSize: 14
                color: Theme.textPrimary
                anchors.centerIn: parent
            }
        }

        down.indicator: Rectangle {
            x: spinBox.mirrored ? parent.width - width : 0
            height: parent.height
            implicitWidth: 28
            implicitHeight: 28
            color: spinBox.down.pressed ? Theme.accentColor : Theme.hoverBackground
            border.color: Theme.inputBorder
            radius: 4

            Text {
                text: "-"
                font.pixelSize: 14
                color: Theme.textPrimary
                anchors.centerIn: parent
            }
        }
    }
}
