import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Explorer

Rectangle {
    id: root

    property bool animating: false    // Animation state
    property real animationValue: 0   // Current animation value (0-100)
    property var properties: []       // Property metadata for documentation panel

    // Alias to allow pages to parent their component inside the container
    default property alias content: componentContainer.data

    color: Theme.previewBackground

    // Component container - centers the component
    Item {
        id: componentContainer
        anchors.fill: parent
        anchors.bottomMargin: controlBar.height + docPanel.height + 20
    }

    // Documentation panel (collapsible, above animation controls)
    DocumentationPanel {
        id: docPanel
        anchors.bottom: controlBar.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: collapsed ? 36 : 220
        properties: root.properties
        visible: root.properties.length > 0
    }

    // Animation controls at bottom
    Rectangle {
        id: controlBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        color: Theme.headerBackground

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 5

            Label {
                text: "Animation Controls"
                font.bold: true
                color: Theme.textPrimary
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    id: playButton
                    text: root.animating ? "Pause" : "Play"
                    Layout.preferredWidth: 100
                    onClicked: root.animating = !root.animating

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: Theme.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: playButton.pressed ? Theme.accentColor : (playButton.hovered ? Theme.hoverBackground : Theme.inputBackground)
                        border.color: Theme.inputBorder
                        radius: 4
                    }
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

                    background: Rectangle {
                        x: manualSlider.leftPadding
                        y: manualSlider.topPadding + manualSlider.availableHeight / 2 - height / 2
                        width: manualSlider.availableWidth
                        height: 4
                        radius: 2
                        color: Theme.sliderTrack

                        Rectangle {
                            width: manualSlider.visualPosition * parent.width
                            height: parent.height
                            color: Theme.accentColor
                            radius: 2
                        }
                    }

                    handle: Rectangle {
                        x: manualSlider.leftPadding + manualSlider.visualPosition * (manualSlider.availableWidth - width)
                        y: manualSlider.topPadding + manualSlider.availableHeight / 2 - height / 2
                        width: 16
                        height: 16
                        radius: 8
                        color: manualSlider.pressed ? Theme.accentHover : Theme.sliderHandle
                        border.color: Theme.border
                    }
                }

                Label {
                    text: root.animationValue.toFixed(0)
                    color: Theme.textValue
                    font.family: "monospace"
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }

                Button {
                    id: resetButton
                    text: "Reset"
                    Layout.preferredWidth: 100
                    onClicked: {
                        root.animating = false
                        root.animationValue = 0
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: Theme.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: resetButton.pressed ? Theme.accentColor : (resetButton.hovered ? Theme.hoverBackground : Theme.inputBackground)
                        border.color: Theme.inputBorder
                        radius: 4
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
