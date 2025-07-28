import QtQuick
import Quickshell
import Quickshell.Io
import QtCore
import qs.config

Item {
    id: util

    readonly property string jsonPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString().replace(/^file:\/\//, "") + "/quickshell/savedata/transparent-config.json"

    property bool useTransparent: false
    property bool defaultTransparent: false

    signal transparentLoaded(bool value)

    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: util.load()
    }

    Process {
        id: readProc
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(this.text)
                    const val = (typeof parsed.transparent === "boolean") ? parsed.transparent : defaultTransparent
                    util.useTransparent = val
                    Appearance.useTransparent = val
                    util.transparentLoaded(val)
                } catch (e) {
                    util.useTransparent = defaultTransparent
                    Appearance.useTransparent = defaultTransparent
                    util.transparentLoaded(defaultTransparent)
                }
            }
        }
    }

    Process {
        id: writeProc
        command: []
    }

    function apply(value) {
        useTransparent = value
        Appearance.useTransparent = value
        Qt.callLater(() => {
            save(value)
            transparentLoaded(value)
        })
    }

    function reset() {
        apply(defaultTransparent)
    }

    function load() {
        const fallback = JSON.stringify({ transparent: defaultTransparent }).replace(/'/g, "'\\''")
        readProc.command = ["sh", "-c", "cat '" + jsonPath + "' 2>/dev/null || echo '" + fallback + "'"]
        readProc.running = true
    }

    function save(value) {
        const json = JSON.stringify({ transparent: value }).replace(/'/g, "'\\''")
        writeProc.command = ["sh", "-c", "echo '" + json + "' > '" + jsonPath + "'"]
        writeProc.running = true
    }
}
