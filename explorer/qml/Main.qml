import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

ApplicationWindow {
    id: window

    width: 1280
    height: 800
    visible: true
    title: "DevDash Gauges Explorer"

    // Sidebar drawer
    Drawer {
        id: drawer
        width: 280
        height: window.height
        modal: false
        interactive: true

        Component.onCompleted: drawer.open()

        background: Rectangle {
            color: "#1e1e1e"
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Header
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "#2a2a2a"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2

                    Label {
                        text: "DevDash Gauges"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#ffffff"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "Component Explorer"
                        font.pixelSize: 12
                        color: "#999999"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // Component sidebar
            ComponentSidebar {
                id: sidebar
                Layout.fillWidth: true
                Layout.fillHeight: true

                onComponentSelected: (pagePath, pageTitle) => {
                    console.log("Loading page:", pagePath)
                    stackView.replace(Qt.resolvedUrl(pagePath))
                    currentPageTitle.text = pageTitle
                }
            }
        }
    }

    // Main content area
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: drawer.position * drawer.width
        spacing: 0

        // Header bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#2a2a2a"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                ToolButton {
                    text: "☰"
                    font.pixelSize: 20
                    onClicked: drawer.visible ? drawer.close() : drawer.open()
                }

                Label {
                    id: currentPageTitle
                    text: "Welcome"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#ffffff"
                    Layout.fillWidth: true
                }

                Label {
                    text: "v1.0.0"
                    font.pixelSize: 12
                    color: "#999999"
                }
            }
        }

        // Page container
        StackView {
            id: stackView
            Layout.fillWidth: true
            Layout.fillHeight: true

            initialItem: "pages/WelcomePage.qml"

            background: Rectangle {
                color: "#1a1a1a"
            }
        }
    }
}
