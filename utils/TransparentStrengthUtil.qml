import QtQuick
import Quickshell
import Quickshell.Io
import QtCore
import qs.config

Item {
    id: util

    readonly property string jsonPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString().replace(/^file:\/\//, "") + "/quickshell/savedata/transparent-strength.json"

    property real currentStrength: 0.5
    property real defaultStrength: 0.5

    signal strengthLoaded(real strength)

    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: util.loadStrength()
    }

    Process {
        id: readProc
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(this.text)
                    const raw = (typeof parsed.strength === "number") ? parsed.strength : defaultStrength
                    const clamped = Math.max(0, Math.min(1, raw))
                    util.currentStrength = clamped
                    applyToAppearance(clamped)
                    util.strengthLoaded(clamped)
                } catch (e) {
                    const fallback = defaultStrength
                    util.currentStrength = fallback
                    applyToAppearance(fallback)
                    util.strengthLoaded(fallback)
                }
            }
        }
    }

    Process {
        id: writeProc
        command: []
    }

    function applyStrength(value) {
        const clamped = Math.max(0, Math.min(1, value))
        currentStrength = clamped
        applyToAppearance(clamped)
        Qt.callLater(() => {
            saveStrength(clamped)
            strengthLoaded(clamped)
        })
    }

    function resetStrength() {
        applyStrength(defaultStrength)
    }

    function loadStrength() {
        const fallback = JSON.stringify({ strength: defaultStrength }).replace(/'/g, "'\\''")
        readProc.command = ["sh", "-c", "cat '" + jsonPath + "' 2>/dev/null || echo '" + fallback + "'"]
        readProc.running = true
    }

    function saveStrength(value) {
        const clamped = Math.max(0, Math.min(1, value))
        const json = JSON.stringify({ strength: clamped }).replace(/'/g, "'\\''")
        writeProc.command = ["sh", "-c", "echo '" + json + "' > '" + jsonPath + "'"]
        writeProc.running = true
    }

    function applyToAppearance(strength) {
        Appearance.color2 = Qt.rgba(
            Appearance.color.r,
            Appearance.color.g,
            Appearance.color.b,
            strength
        )
    }
}
