pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Explorer
import DevDash.Gauges.Theme 1.0

/**
 * @brief Header-bar control that drives the global GaugeQuality singleton.
 *
 * GaugeQuality is the gauges' graphics-quality state — the runtime equivalent
 * of a graphics-settings panel. Today it carries one flag, `effects3DEnabled`,
 * which selects between the Quick3D and 2D rendering paths for elements that
 * ship both (currently the centre hub: `CenterCap3D` cone vs. a form-shaded
 * 2D `GaugeCenterCap` dome). This toggle flips it live so the two variants can
 * be compared without rebuilding.
 *
 * It's a separate axis from both the explorer-UI theme and the gauge theme:
 * any preset / mode combination can be viewed at full or reduced quality.
 * The button reflects the singleton, so a page that imperatively sets quality
 * (or a future C++/QML caller) updates the visible state.
 */
RowLayout {
    id: root
    spacing: 8

    // Visual divider separating these from the gauge-theme controls.
    Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 24
        Layout.alignment: Qt.AlignVCenter
        color: Theme.divider
    }

    Label {
        text: "Quality"
        font.pixelSize: 12
        font.bold: true
        color: Theme.textSecondary
        Layout.alignment: Qt.AlignVCenter
    }

    ToolButton {
        id: threeDToggle

        Layout.preferredHeight: 30
        Layout.maximumHeight: 30
        Layout.alignment: Qt.AlignVCenter

        readonly property bool on3D: GaugeQuality.effects3DEnabled

        text: (on3D ? "◆" : "◇") + "  3D " + (on3D ? "On" : "Off")
        font.pixelSize: 13
        onClicked: GaugeQuality.setQuality(on3D ? "reduced" : "full")

        ToolTip.visible: hovered
        ToolTip.delay: 400
        ToolTip.text: on3D
            ? "Quick3D rendering paths enabled (e.g. CenterCap3D cone). Click for the 2D variants."
            : "Quick3D rendering paths disabled — 2D variants in use (e.g. form-shaded GaugeCenterCap dome). Click to re-enable 3D."

        contentItem: Text {
            leftPadding: 8
            rightPadding: 8
            text: threeDToggle.text
            font: threeDToggle.font
            color: Theme.textPrimary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            implicitHeight: 30
            color: threeDToggle.hovered ? Theme.hoverBackground : "transparent"
            border.color: Theme.inputBorder
            border.width: 1
            radius: 4
        }
    }
}
