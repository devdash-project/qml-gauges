import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property bool animating: false    // Animation state
    property real animationValue: 0   // Current animation value (0-100)

    // Alias to allow pages to parent their component inside the container
    default property alias content: componentContainer.data

    color: "#1a1a1a"  // Dark background for automotive aesthetic

    // Component container - centers the component
    Item {
        id: componentContainer
        anchors.fill: parent
        anchors.bottomMargin: controlBar.height + 20
    }

    // Animation controls at bottom
    Rectangle {
        id: controlBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        color: "#2a2a2a"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 5

            Label {
                text: "Animation Controls"
                font.bold: true
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: root.animating ? "⏸ Pause" : "▶ Play"
                    Layout.preferredWidth: 100
                    onClicked: root.animating = !root.animating
                }

                Slider {
                    id: manualSlider
                    enabled: !root.animating
                    from: 0
                    to: 100
                    value: root.animationValue
                    Layout.fillWidth: true
                    onMoved: {
                        if (!root.animating) {
                            root.animationValue = manualSlider.value
                        }
                    }
                }

                Label {
                    text: root.animationValue.toFixed(0)
                    color: "#ffffff"
                    font.family: "monospace"
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }

                Button {
                    text: "⟲ Reset"
                    Layout.preferredWidth: 100
                    onClicked: {
                        root.animating = false
                        root.animationValue = 0
                    }
                }
            }
        }
    }

    // Animation loop - ping-pong between 0 and 100
    SequentialAnimation {
        id: animation
        running: root.animating
        loops: Animation.Infinite

        NumberAnimation {
            target: root
            property: "animationValue"
            from: 0
            to: 100
            duration: 2000
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: root
            property: "animationValue"
            from: 100
            to: 0
            duration: 2000
            easing.type: Easing.InOutQuad
        }
    }

}
