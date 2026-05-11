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

    // Page name to sidebar index mapping for navigation
    // Index corresponds to position in ComponentSidebar ListModel (including headers)
    readonly property var pageIndexMap: {
        "Welcome": 0,
        // Primitives (header at 1)
        "BezelScrews": 2,
        "GaugeArc": 3,
        "GaugeBezel": 4,
        "GaugeCenterCap": 5,
        "GaugeFace": 6,
        "GaugeTick": 7,
        "GaugeTickLabel": 8,
        "Bezel3D": 9,
        "CenterCap3D": 10,
        // Compounds (header at 11)
        "DigitalReadout": 12,
        "GaugeNeedle": 13,
        "GaugeTickRing": 14,
        "GaugeValueArc": 15,
        "GaugeZoneArc": 16,
        "RollingDigitReadout": 17,
        // Templates (header at 18)
        "RadialGauge": 19,
        "RadialGauge3D": 20,
        "IndustrialGauge": 21
    }

    // Connect to state server for MCP integration
    Connections {
        target: stateServer

        function onNavigateRequested(page) {
            // Find the page in sidebar and navigate to it
            const index = window.pageIndexMap[page]
            if (index !== undefined) {
                sidebar.currentIndex = index
                const pagePath = "pages/" + page + "Page.qml"
                stackView.replace(Qt.resolvedUrl(pagePath))
                currentPageTitle.text = page
                stateServer.currentPage = page
                stateServer.currentPageTitle = page
            } else {
                console.warn("StateServer: unknown page:", page)
            }
        }

        // Note: setPropertyRequested is handled by PropertyPanel directly
        // for bidirectional editor updates
    }

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

                    // Update state server
                    stateServer.currentPage = pageTitle
                    stateServer.currentPageTitle = pageTitle
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

                // State server indicator
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: stateServer.listening ? "#4caf50" : "#757575"
                    ToolTip.visible: stateServerIndicatorMouse.containsMouse
                    ToolTip.text: stateServer.listening
                        ? "State server listening on port " + stateServer.port
                        : "State server not running"

                    MouseArea {
                        id: stateServerIndicatorMouse
                        anchors.fill: parent
                        hoverEnabled: true
                    }
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

            // Update state server when page changes
            onCurrentItemChanged: {
                if (currentItem) {
                    // Give the page a reference to the state server for MCP integration
                    // Check if the property exists (not undefined) and assign it
                    if (typeof currentItem.stateServer !== "undefined") {
                        currentItem.stateServer = stateServer
                    }

                    // Update property metadata when page loads
                    if (currentItem.properties) {
                        stateServer.propertyMetadata = currentItem.properties
                    }
                }
            }
        }
    }

    // Initialize state server state on startup
    Component.onCompleted: {
        stateServer.currentPage = "Welcome"
        stateServer.currentPageTitle = "Welcome"
    }
}
