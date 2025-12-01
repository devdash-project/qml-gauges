import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root

    property string propertyName
    property alias value: toggle.checked

    spacing: 10

    Label {
        text: root.propertyName
        Layout.preferredWidth: 120
        horizontalAlignment: Text.AlignLeft
    }

    Switch {
        id: toggle
        Layout.fillWidth: true
    }

    Label {
        text: toggle.checked ? "true" : "false"
        Layout.preferredWidth: 60
        horizontalAlignment: Text.AlignRight
        color: toggle.checked ? "#4CAF50" : "#F44336"
        font.family: "monospace"
    }
}
