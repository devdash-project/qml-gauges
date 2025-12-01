import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import Explorer

RowLayout {
    id: root

    property string propertyName
    property color value: "white"

    spacing: 10

    Label {
        text: root.propertyName
        Layout.preferredWidth: 120
        horizontalAlignment: Text.AlignLeft
        color: Theme.textPrimary
    }

    Rectangle {
        Layout.preferredWidth: 80
        Layout.preferredHeight: 32
        color: root.value
        border.color: Theme.border
        border.width: 1
        radius: 4

        Layout.fillWidth: true

        MouseArea {
            anchors.fill: parent
            onClicked: colorDialog.open()
            cursorShape: Qt.PointingHandCursor
        }

        Label {
            anchors.centerIn: parent
            text: root.value.toString().toUpperCase()
            color: {
                // Calculate luminance for contrast
                var r = root.value.r * 255
                var g = root.value.g * 255
                var b = root.value.b * 255
                var luminance = (0.299 * r + 0.587 * g + 0.114 * b)
                return luminance > 128 ? "#000000" : "#FFFFFF"
            }
            font.pixelSize: 10
            font.family: "monospace"
        }
    }

    ColorDialog {
        id: colorDialog
        selectedColor: root.value
        onAccepted: root.value = colorDialog.selectedColor
    }
}
