pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Explorer
import DevDash.Gauges.Theme 1.0

/**
 * @brief Header-bar controls that drive the global GaugeTheme singleton.
 *
 * These change how the *gauges* render — the active preset and (added in a
 * later commit) the light/dark mode — and are deliberately distinct from the
 * explorer's own UI theme toggle (the `Theme` singleton, which restyles the
 * explorer chrome). The two are orthogonal: a user can pair a light explorer
 * UI with dark-mode gauges (night-driving simulation) or vice versa.
 *
 * The preset selector is populated declaratively from `GaugeTheme.presetNames`
 * / `GaugeTheme.presetMetadata`, so adding a preset to GaugeTheme makes it
 * appear here with no change to this file. It also reflects the *active*
 * preset: navigating to a page whose `Component.onCompleted` imperatively sets
 * a preset updates the selection.
 */
RowLayout {
    id: root
    spacing: 8

    // Visual divider separating these gauge-theme controls from the
    // explorer-UI controls to their left.
    Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 24
        Layout.alignment: Qt.AlignVCenter
        color: Theme.divider
    }

    Label {
        text: "Gauge"
        font.pixelSize: 12
        font.bold: true
        color: Theme.textSecondary
        Layout.alignment: Qt.AlignVCenter
    }

    // --- Preset selector ---------------------------------------------------
    ComboBox {
        id: presetSelector

        Layout.preferredWidth: 150
        Layout.preferredHeight: 30
        Layout.maximumHeight: 30
        Layout.alignment: Qt.AlignVCenter

        model: GaugeTheme.presetNames

        /**
         * Registry name of the preset currently in effect. `activeTheme` is
         * the nested QtObject, so map it back to its registry name to drive
         * the visible selection.
         */
        readonly property string activePresetName: {
            for (var i = 0; i < GaugeTheme.presetNames.length; ++i) {
                if (GaugeTheme[GaugeTheme.presetNames[i]] === GaugeTheme.activeTheme)
                    return GaugeTheme.presetNames[i]
            }
            return GaugeTheme.presetNames[0]
        }

        // Keep the visible selection in sync with the singleton — including
        // when a page imperatively switches presets. currentIndex can't be a
        // plain binding because the ComboBox writes to it on user activation
        // (which would break the binding), so push updates instead.
        function syncToActive() {
            var idx = GaugeTheme.presetNames.indexOf(activePresetName)
            if (idx >= 0 && idx !== currentIndex)
                currentIndex = idx
        }
        onActivePresetNameChanged: syncToActive()
        Component.onCompleted: syncToActive()

        displayText: currentIndex >= 0
            ? GaugeTheme.presetMetadata[GaugeTheme.presetNames[currentIndex]].displayName
            : ""

        onActivated: (index) => GaugeTheme.setTheme(GaugeTheme.presetNames[index])

        // Hovering the (closed) selector shows the active preset's description.
        ToolTip.visible: hovered && currentIndex >= 0
        ToolTip.delay: 400
        ToolTip.text: currentIndex >= 0
            ? GaugeTheme.presetMetadata[GaugeTheme.presetNames[currentIndex]].description
            : ""

        contentItem: Text {
            leftPadding: 10
            text: presetSelector.displayText
            font: presetSelector.font
            color: Theme.textValue
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 150
            implicitHeight: 30
            color: Theme.inputBackground
            border.color: presetSelector.activeFocus ? Theme.accentColor : Theme.inputBorder
            border.width: 1
            radius: 4
        }

        indicator: Canvas {
            id: presetIndicatorCanvas
            x: presetSelector.width - width - presetSelector.rightPadding
            y: presetSelector.topPadding + (presetSelector.availableHeight - height) / 2
            width: 12
            height: 8
            contextType: "2d"

            Connections {
                target: Theme
                function onDarkChanged() { presetIndicatorCanvas.requestPaint() }
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.moveTo(0, 0)
                ctx.lineTo(width, 0)
                ctx.lineTo(width / 2, height)
                ctx.closePath()
                ctx.fillStyle = Theme.textSecondary
                ctx.fill()
            }
        }

        popup: Popup {
            y: presetSelector.height - 1
            width: presetSelector.width
            implicitHeight: Math.min(presetPopupList.contentHeight + 2, 320)
            padding: 1

            contentItem: ListView {
                id: presetPopupList
                clip: true
                implicitHeight: contentHeight
                model: presetSelector.popup.visible ? presetSelector.delegateModel : null
                currentIndex: presetSelector.highlightedIndex
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: ScrollBar {
                    active: true
                    policy: ScrollBar.AsNeeded
                }
            }

            background: Rectangle {
                color: Theme.inputBackground
                border.color: Theme.inputBorder
                radius: 4
            }
        }

        delegate: ItemDelegate {
            id: presetDelegate

            required property int index
            required property string modelData

            width: presetSelector.width
            highlighted: presetSelector.highlightedIndex === presetDelegate.index

            readonly property var metadata: GaugeTheme.presetMetadata[presetDelegate.modelData]

            contentItem: Text {
                leftPadding: 10
                text: presetDelegate.metadata && presetDelegate.metadata.displayName
                    ? presetDelegate.metadata.displayName
                    : presetDelegate.modelData
                color: presetDelegate.highlighted ? "#ffffff" : Theme.textValue
                font: presetSelector.font
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: presetDelegate.highlighted ? Theme.accentColor : "transparent"
            }

            // Each option's description shows as a tooltip on hover.
            ToolTip.visible: hovered
            ToolTip.delay: 400
            ToolTip.text: presetDelegate.metadata && presetDelegate.metadata.description
                ? presetDelegate.metadata.description
                : ""
        }
    }
}
