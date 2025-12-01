import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width * 0.6
            spacing: 30

            Label {
                text: "Welcome to DevDash Gauges Explorer"
                font.pixelSize: 32
                font.bold: true
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "Interactive component showcase for automotive gauge primitives and compounds"
                font.pixelSize: 16
                color: "#cccccc"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: "#444444"
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
                    color: "#ffffff"
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
                            color: "#4a90e2"
                        }

                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true

                            Label {
                                text: featureDelegate.modelData.category
                                font.pixelSize: 14
                                font.bold: true
                                color: "#ffffff"
                            }

                            Label {
                                text: featureDelegate.modelData.desc
                                font.pixelSize: 12
                                color: "#999999"
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: "#444444"
                Layout.topMargin: 20
                Layout.bottomMargin: 10
            }

            Label {
                text: "Select a component from the sidebar to begin exploring →"
                font.pixelSize: 14
                color: "#4a90e2"
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
