import QtQuick
import Quickshell
import Quickshell.Io
import QtCore
import qs.config

Item {
    id: util

    readonly property string jsonPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString().replace(/^file:\/\//, "") + "/quickshell/savedata/white-color.json"

    property string currentColor: "#cacaca"  // default Appearance.white
    property string defaultColor: "#cacaca"

    signal colorLoaded(string color)

    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: util.loadColor()
    }

    Process {
        id: readProc
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(this.text)
                    const loaded = (typeof parsed.color === "string") ? parsed.color.toLowerCase() : defaultColor
                    util.currentColor = loaded
                    Appearance.white = Qt.color(loaded)
                    util.colorLoaded(loaded)
                } catch (e) {
                    util.currentColor = defaultColor
                    Appearance.white = Qt.color(defaultColor)
                    util.colorLoaded(defaultColor)
                }
            }
        }
    }

    Process {
        id: writeProc
        command: []
    }

    function applyColor(colorStr) {
        const hex = colorStr.toLowerCase()
        currentColor = hex
        Appearance.white = Qt.color(hex)
        Qt.callLater(() => {
            saveColor(hex)
            colorLoaded(hex)
        })
    }

    function resetColor() {
        applyColor(defaultColor)
    }

    function loadColor() {
        const fallback = JSON.stringify({ color: defaultColor }).replace(/'/g, "'\\''")
        readProc.command = ["sh", "-c", "cat '" + jsonPath + "' 2>/dev/null || echo '" + fallback + "'"]
        readProc.running = true
    }

    function saveColor(colorStr) {
        const json = JSON.stringify({ color: colorStr }).replace(/'/g, "'\\''")
        writeProc.command = ["sh", "-c", "echo '" + json + "' > '" + jsonPath + "'"]
        writeProc.running = true
    }

    function hueToHex(hue) {
        let c = 1
        let x = 1 - Math.abs((hue / 60) % 2 - 1)
        let r = 0, g = 0, b = 0
        if (hue < 60)      { r = c; g = x }
        else if (hue < 120){ r = x; g = c }
        else if (hue < 180){ g = c; b = x }
        else if (hue < 240){ g = x; b = c }
        else if (hue < 300){ r = x; b = c }
        else               { r = c; g = 0; b = x }

        r = Math.round(r * 255)
        g = Math.round(g * 255)
        b = Math.round(b * 255)

        return "#" + [r, g, b].map(v => v.toString(16).padStart(2, "0")).join("")
    }

    function hexToHue(hex) {
        let r = parseInt(hex.slice(1, 3), 16) / 255
        let g = parseInt(hex.slice(3, 5), 16) / 255
        let b = parseInt(hex.slice(5, 7), 16) / 255

        let max = Math.max(r, g, b)
        let min = Math.min(r, g, b)
        let h = 0

        if (max === min) h = 0
        else if (max === r) h = (60 * ((g - b) / (max - min)) + 360) % 360
        else if (max === g) h = (60 * ((b - r) / (max - min)) + 120)
        else if (max === b) h = (60 * ((r - g) / (max - min)) + 240)

        return h
    }

    function colorToHex(color) {
        const r = Math.round(color.r * 255)
        const g = Math.round(color.g * 255)
        const b = Math.round(color.b * 255)
        return "#" + [r, g, b].map(v => v.toString(16).padStart(2, "0")).join("")
    }
}
