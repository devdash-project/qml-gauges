import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Explorer

RowLayout {
    id: root

    property string propertyName
    property alias value: toggle.checked

    spacing: 10

    Label {
        text: root.propertyName
        Layout.preferredWidth: 120
        horizontalAlignment: Text.AlignLeft
        color: Theme.textPrimary
    }

    Switch {
        id: toggle
        Layout.fillWidth: true

        indicator: Rectangle {
            implicitWidth: 48
            implicitHeight: 24
            x: toggle.leftPadding
            y: parent.height / 2 - height / 2
            radius: 12
            color: toggle.checked ? Theme.boolTrue : Theme.boolFalse
            border.color: Theme.border

            Rectangle {
                x: toggle.checked ? parent.width - width - 2 : 2
                y: 2
                width: 20
                height: 20
                radius: 10
                color: "#ffffff"
                Behavior on x { NumberAnimation { duration: 100 } }
            }
        }
    }

    Label {
        text: toggle.checked ? "true" : "false"
        Layout.preferredWidth: 60
        horizontalAlignment: Text.AlignRight
        color: toggle.checked ? Theme.boolTrue : "#F44336"
        font.family: "monospace"
    }
}
