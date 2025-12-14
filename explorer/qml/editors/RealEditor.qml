import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Explorer

ColumnLayout {
    id: root

    property string propertyName
    property alias value: slider.value
    property real min: 0
    property real max: 100

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Label {
            text: root.propertyName
            Layout.preferredWidth: 120
            horizontalAlignment: Text.AlignLeft
            color: Theme.textPrimary
        }

        Slider {
            id: slider
            from: root.min
            to: root.max
            Layout.fillWidth: true
        }

        Label {
            text: root.value.toFixed(1)
            Layout.preferredWidth: 60
            horizontalAlignment: Text.AlignRight
            font.family: "monospace"
            color: Theme.textValue
        }
    }
}
