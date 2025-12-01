pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Explorer

ListView {
    id: root

    // Signal emitted when a component is selected
    signal componentSelected(string pagePath, string title)

    model: ListModel {
        // Welcome
        ListElement {
            category: "Getting Started"
            title: "Welcome"
            description: "Introduction to DevDash Gauges"
            pagePath: "pages/WelcomePage.qml"
            isHeader: false
        }

        // Primitives category header
        ListElement {
            category: "Primitives"
            title: "Primitives"
            description: ""
            pagePath: ""
            isHeader: true
        }

        // Primitives
        ListElement {
            category: "Primitives"
            title: "GaugeArc"
            description: "Arc primitive for drawing gauge value arcs"
            pagePath: "pages/GaugeArcPage.qml"
            isHeader: false
        }
        ListElement {
            category: "Primitives"
            title: "GaugeBezel"
            description: "Decorative bezel/rim for gauges"
            pagePath: "pages/GaugeBezelPage.qml"
            isHeader: false
        }
        ListElement {
            category: "Primitives"
            title: "GaugeCenterCap"
            description: "Center cap that covers gauge pivot"
            pagePath: "pages/GaugeCenterCapPage.qml"
            isHeader: false
        }
        ListElement {
            category: "Primitives"
            title: "GaugeFace"
            description: "Background face/dial for gauges"
            pagePath: "pages/GaugeFacePage.qml"
            isHeader: false
        }
        ListElement {
            category: "Primitives"
            title: "GaugeTick"
            description: "Individual tick mark"
            pagePath: "pages/GaugeTickPage.qml"
            isHeader: false
        }
        ListElement {
            category: "Primitives"
            title: "GaugeTickLabel"
            description: "Text label for tick marks"
            pagePath: "pages/GaugeTickLabelPage.qml"
            isHeader: false
        }

        // Compounds category header
        ListElement {
            category: "Compounds"
            title: "Compounds"
            description: ""
            pagePath: ""
            isHeader: true
        }

        // Compounds
        ListElement {
            category: "Compounds"
            title: "DigitalReadout"
            description: "Digital numeric display"
            pagePath: "pages/DigitalReadoutPage.qml"
            isHeader: false
        }
        ListElement {
            category: "Compounds"
            title: "GaugeNeedle"
            description: "Unified 4-part needle with multiple shapes"
            pagePath: "pages/GaugeNeedlePage.qml"
            isHeader: false
        }
        ListElement {
            category: "Compounds"
            title: "GaugeTickRing"
            description: "Complete ring of tick marks"
            pagePath: "pages/GaugeTickRingPage.qml"
            isHeader: false
        }
        ListElement {
            category: "Compounds"
            title: "GaugeValueArc"
            description: "Arc that follows current value"
            pagePath: "pages/GaugeValueArcPage.qml"
            isHeader: false
        }
        ListElement {
            category: "Compounds"
            title: "GaugeZoneArc"
            description: "Colored zone arc (warning/danger)"
            pagePath: "pages/GaugeZoneArcPage.qml"
            isHeader: false
        }
        ListElement {
            category: "Compounds"
            title: "RollingDigitReadout"
            description: "Animated rolling digit display"
            pagePath: "pages/RollingDigitReadoutPage.qml"
            isHeader: false
        }

        // Templates category header
        ListElement {
            category: "Templates"
            title: "Templates"
            description: ""
            pagePath: ""
            isHeader: true
        }

        // Templates
        ListElement {
            category: "Templates"
            title: "RadialGauge"
            description: "Complete radial gauge template"
            pagePath: "pages/RadialGaugePage.qml"
            isHeader: false
        }
    }

    delegate: Item {
        id: delegateRoot

        required property int index
        required property string title
        required property string description
        required property string pagePath
        required property bool isHeader

        width: root.width
        height: delegateRoot.isHeader ? 40 : 60

        // Category header
        Rectangle {
            visible: delegateRoot.isHeader
            anchors.fill: parent
            color: Theme.categoryBackground

            Label {
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                text: delegateRoot.title
                font.bold: true
                font.pixelSize: 14
                color: Theme.textPrimary
            }
        }

        // Component item
        ItemDelegate {
            id: delegateItem
            visible: !delegateRoot.isHeader
            anchors.fill: parent
            highlighted: root.currentIndex === delegateRoot.index

            background: Rectangle {
                color: delegateItem.highlighted ? Theme.selectedBackground : (delegateItem.hovered ? Theme.hoverBackground : "transparent")
            }

            contentItem: ColumnLayout {
                spacing: 2
                anchors.leftMargin: 20

                Label {
                    text: delegateRoot.title
                    font.pixelSize: 13
                    font.bold: true
                    color: delegateItem.highlighted ? "#ffffff" : Theme.textPrimary
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Label {
                    text: delegateRoot.description || ""
                    font.pixelSize: 11
                    color: delegateItem.highlighted ? "#e0e0e0" : Theme.textSecondary
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            onClicked: {
                root.currentIndex = delegateRoot.index
                if (delegateRoot.pagePath && delegateRoot.pagePath !== "") {
                    root.componentSelected(delegateRoot.pagePath, delegateRoot.title)
                }
            }
        }
    }

    // Styling
    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AsNeeded
    }

    clip: true
}
