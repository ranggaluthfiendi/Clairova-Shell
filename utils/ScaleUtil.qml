import QtQuick
import Quickshell
import Quickshell.Io
import QtCore
import qs.config

Item {
    id: util

    readonly property string jsonPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString().replace(/^file:\/\//, "") + "/quickshell/savedata/scale-factor.json"

    property real currentScale: 1.2
    property real defaultScale: 1.2

    signal scaleLoaded(real scale)

    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: util.loadScale()
    }

    Process {
        id: readProc
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(this.text)
                    const raw = (typeof parsed.scale === "number") ? parsed.scale : defaultScale
                    const clamped = Math.max(0.7, Math.min(1.7, raw))
                    util.currentScale = clamped
                    applyToAppearance(clamped)
                    util.scaleLoaded(clamped)
                } catch (e) {
                    const fallback = defaultScale
                    util.currentScale = fallback
                    applyToAppearance(fallback)
                    util.scaleLoaded(fallback)
                }
            }
        }
    }

    Process {
        id: writeProc
        command: []
    }

    function applyScale(value) {
        const clamped = Math.max(0.7, Math.min(1.7, value))
        currentScale = clamped
        applyToAppearance(clamped)
        Qt.callLater(() => {
            saveScale(clamped)
            scaleLoaded(clamped)
        })
    }

    function resetScale() {
        applyScale(defaultScale)
    }

    function loadScale() {
        const fallback = JSON.stringify({ scale: defaultScale }).replace(/'/g, "'\\''")
        readProc.command = ["sh", "-c", "cat '" + jsonPath + "' 2>/dev/null || echo '" + fallback + "'"]
        readProc.running = true
    }

    function saveScale(value) {
        const clamped = Math.max(0.7, Math.min(1.7, value))
        const json = JSON.stringify({ scale: clamped }).replace(/'/g, "'\\''")
        writeProc.command = ["sh", "-c", "echo '" + json + "' > '" + jsonPath + "'"]
        writeProc.running = true
    }

    function applyToAppearance(scale) {
        Appearance.scaleFactor = scale
    }
}
