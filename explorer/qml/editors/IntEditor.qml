import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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
    }

    SpinBox {
        id: spinBox
        from: root.min
        to: root.max
        Layout.fillWidth: true
        editable: true
    }
}
