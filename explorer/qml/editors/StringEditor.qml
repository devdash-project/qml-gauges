import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root

    property string propertyName
    property alias value: textField.text

    spacing: 10

    Label {
        text: root.propertyName
        Layout.preferredWidth: 120
        horizontalAlignment: Text.AlignLeft
    }

    TextField {
        id: textField
        Layout.fillWidth: true
        placeholderText: "Enter " + root.propertyName.toLowerCase() + "..."
    }
}
