import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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
    }

    ComboBox {
        id: comboBox
        Layout.fillWidth: true
        model: root.values
        currentIndex: root.values.indexOf(root.value)
        onActivated: (index) => {
            root.value = root.values[index]
        }
    }
}
