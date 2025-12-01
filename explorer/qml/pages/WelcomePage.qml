import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Explorer

Item {
    Rectangle {
        anchors.fill: parent
        color: Theme.windowBackground

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width * 0.6
            spacing: 30

            Label {
                text: "Welcome to DevDash Gauges Explorer"
                font.pixelSize: 32
                font.bold: true
                color: Theme.textPrimary
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "Interactive component showcase for automotive gauge primitives and compounds"
                font.pixelSize: 16
                color: Theme.textSecondary
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: Theme.divider
                Layout.topMargin: 20
                Layout.bottomMargin: 20
            }

            ColumnLayout {
                spacing: 15
                Layout.fillWidth: true

                Label {
                    text: "What's included:"
                    font.pixelSize: 18
                    font.bold: true
                    color: Theme.textPrimary
                }

                Repeater {
                    model: [
                        {category: "8 Primitives", desc: "Core building blocks: arcs, needles, ticks, faces"},
                        {category: "5 Compounds", desc: "Ready-to-use components: tick rings, value arcs, digital readouts"},
                        {category: "1 Template", desc: "Complete RadialGauge combining all primitives"},
                        {category: "Live Preview", desc: "Interactive property controls with animation"},
                        {category: "Copy-Paste Ready", desc: "Simple metadata-driven component structure"}
                    ]

                    delegate: RowLayout {
                        id: featureDelegate

                        required property var modelData

                        spacing: 15
                        Layout.fillWidth: true

                        Rectangle {
                            Layout.preferredWidth: 8
                            Layout.preferredHeight: 8
                            radius: 4
                            color: Theme.accentColor
                        }

                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true

                            Label {
                                text: featureDelegate.modelData.category
                                font.pixelSize: 14
                                font.bold: true
                                color: Theme.textPrimary
                            }

                            Label {
                                text: featureDelegate.modelData.desc
                                font.pixelSize: 12
                                color: Theme.textSecondary
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: Theme.divider
                Layout.topMargin: 20
                Layout.bottomMargin: 10
            }

            Label {
                text: "Select a component from the sidebar to begin exploring \u2192"
                font.pixelSize: 14
                color: Theme.accentColor
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
