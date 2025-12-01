import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Explorer
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
        interactive: false  // Disable swipe gestures - use hamburger button instead
        closePolicy: Popup.NoAutoClose  // Don't close on clicks outside

        Component.onCompleted: drawer.open()

        background: Rectangle {
            color: Theme.sidebarBackground
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Header
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: Theme.headerBackground

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2

                    Label {
                        text: "DevDash Gauges"
                        font.pixelSize: 18
                        font.bold: true
                        color: Theme.textPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "Component Explorer"
                        font.pixelSize: 12
                        color: Theme.textSecondary
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
            color: Theme.headerBackground

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                ToolButton {
                    text: "\u2630"  // Hamburger menu
                    font.pixelSize: 20
                    onClicked: drawer.visible ? drawer.close() : drawer.open()

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: Theme.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.hovered ? Theme.hoverBackground : "transparent"
                        radius: 4
                    }
                }

                Label {
                    id: currentPageTitle
                    text: "Welcome"
                    font.pixelSize: 16
                    font.bold: true
                    color: Theme.textPrimary
                    Layout.fillWidth: true
                }

                // Theme toggle button
                ToolButton {
                    id: themeToggle
                    text: Theme.dark ? "\u2600" : "\u263E"  // Sun (to switch to light) or Moon (to switch to dark)
                    font.pixelSize: 18
                    onClicked: Theme.toggle()
                    ToolTip.visible: hovered
                    ToolTip.text: Theme.dark ? "Switch to Light Mode" : "Switch to Dark Mode"

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: Theme.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.hovered ? Theme.hoverBackground : "transparent"
                        radius: 4
                    }
                }

                Label {
                    text: "v1.0.0"
                    font.pixelSize: 12
                    color: Theme.textMuted
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
                color: Theme.windowBackground
            }
        }
    }
}
