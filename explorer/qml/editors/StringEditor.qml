import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Explorer

RowLayout {
    id: root

    property string propertyName
    property alias value: textField.text

    spacing: 10

    Label {
        text: root.propertyName
        Layout.preferredWidth: 120
        horizontalAlignment: Text.AlignLeft
        color: Theme.textPrimary
    }

    TextField {
        id: textField
        Layout.fillWidth: true
        placeholderText: "Enter " + root.propertyName.toLowerCase() + "..."
        color: Theme.textValue
        placeholderTextColor: Theme.textMuted

        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 32
            color: Theme.inputBackground
            border.color: textField.activeFocus ? Theme.accentColor : Theme.inputBorder
            border.width: 1
            radius: 4
        }
    }
}
