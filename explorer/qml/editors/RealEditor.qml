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

            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: slider.availableWidth
                height: 4
                radius: 2
                color: Theme.sliderTrack

                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    color: Theme.accentColor
                    radius: 2
                }
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: 16
                height: 16
                radius: 8
                color: slider.pressed ? Theme.accentHover : Theme.sliderHandle
                border.color: Theme.border
            }
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
