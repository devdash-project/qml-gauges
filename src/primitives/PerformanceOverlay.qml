import QtQuick

/**
 * @brief Performance overlay displaying FPS and frame timing.
 *
 * PerformanceOverlay provides real-time performance metrics using
 * FrameAnimation for accurate frame timing. Displays FPS counter,
 * frame time, and optional frame time graph.
 *
 * @example
 * @code
 * PerformanceOverlay {
 *     anchors.top: parent.top
 *     anchors.right: parent.right
 *     anchors.margins: 10
 *     visible: showPerformanceMetrics
 * }
 * @endcode
 */
Item {
    id: root

    // === Configuration ===

    /**
     * @brief Number of frames to average for FPS calculation.
     * @default 60
     */
    property int sampleCount: 60

    /**
     * @brief Show frame time graph.
     * @default true
     */
    property bool showGraph: true

    /**
     * @brief Background color.
     * @default "#80000000" (semi-transparent black)
     */
    property color backgroundColor: "#80000000"

    /**
     * @brief Text color.
     * @default "#00ff00" (green)
     */
    property color textColor: "#00ff00"

    /**
     * @brief Warning color (fps < 45).
     * @default "#ffff00" (yellow)
     */
    property color warningColor: "#ffff00"

    /**
     * @brief Critical color (fps < 30).
     * @default "#ff0000" (red)
     */
    property color criticalColor: "#ff0000"

    /**
     * @brief Graph line color.
     * @default "#00aaff"
     */
    property color graphColor: "#00aaff"

    /**
     * @brief Target FPS for graph scaling.
     * @default 60
     */
    property int targetFps: 60

    // === Readonly Output ===

    /**
     * @brief Current FPS (averaged over sampleCount frames).
     */
    readonly property real fps: _avgFps

    /**
     * @brief Current frame time in milliseconds.
     */
    readonly property real frameTimeMs: _lastFrameTime

    // === Internal ===

    property real _lastFrameTime: 0
    property real _avgFps: 0
    property var _frameTimes: []
    property int _frameIndex: 0

    implicitWidth: 120
    implicitHeight: showGraph ? 80 : 40

    // Frame timing using FrameAnimation
    FrameAnimation {
        id: frameTimer
        running: root.visible

        onTriggered: {
            // frameTime is in seconds
            root._lastFrameTime = frameTime * 1000

            // Store frame time for averaging
            if (root._frameTimes.length < root.sampleCount) {
                root._frameTimes.push(root._lastFrameTime)
            } else {
                root._frameTimes[root._frameIndex] = root._lastFrameTime
            }
            root._frameIndex = (root._frameIndex + 1) % root.sampleCount

            // Calculate average FPS
            if (root._frameTimes.length > 0) {
                var sum = 0
                for (var i = 0; i < root._frameTimes.length; i++) {
                    sum += root._frameTimes[i]
                }
                var avgFrameTime = sum / root._frameTimes.length
                root._avgFps = avgFrameTime > 0 ? 1000 / avgFrameTime : 0
            }

            // Update graph
            if (root.showGraph) {
                graphCanvas.requestPaint()
            }
        }
    }

    // Background
    Rectangle {
        anchors.fill: parent
        color: root.backgroundColor
        radius: 4
    }

    // FPS text
    Column {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 6
        spacing: 2

        Text {
            id: fpsText
            text: root._avgFps.toFixed(1) + " FPS"
            font.family: "monospace"
            font.pixelSize: 14
            font.bold: true
            color: root._avgFps >= 45 ? root.textColor :
                   root._avgFps >= 30 ? root.warningColor : root.criticalColor
        }

        Text {
            text: root._lastFrameTime.toFixed(1) + " ms"
            font.family: "monospace"
            font.pixelSize: 10
            color: Qt.darker(root.textColor, 1.3)
        }
    }

    // Frame time graph
    Canvas {
        id: graphCanvas
        visible: root.showGraph
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 4
        height: 30

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            if (root._frameTimes.length < 2) return

            // Target frame time line (16.67ms for 60fps)
            var targetMs = 1000 / root.targetFps
            var targetY = height - (targetMs / 33.33) * height  // Scale: 0-33ms
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.3)
            ctx.lineWidth = 1
            ctx.beginPath()
            ctx.moveTo(0, targetY)
            ctx.lineTo(width, targetY)
            ctx.stroke()

            // Frame time line
            ctx.strokeStyle = root.graphColor
            ctx.lineWidth = 1.5
            ctx.beginPath()

            var samples = Math.min(root._frameTimes.length, width)
            var startIdx = root._frameTimes.length - samples

            for (var i = 0; i < samples; i++) {
                var idx = (startIdx + i + root._frameIndex) % root._frameTimes.length
                var ft = root._frameTimes[idx]
                var x = (i / samples) * width
                var y = height - Math.min((ft / 33.33) * height, height)

                if (i === 0) {
                    ctx.moveTo(x, y)
                } else {
                    ctx.lineTo(x, y)
                }
            }
            ctx.stroke()
        }
    }
}
