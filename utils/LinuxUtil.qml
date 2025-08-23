import QtQuick
import Quickshell
import Quickshell.Io
import QtCore
import qs.config

Item {
    id: util

    readonly property string jsonPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation)
        .toString().replace(/^file:\/\//, "") + "/quickshell/savedata/linux-position.json"

    property real currentX: 0
    property real currentY: 0
    property real defaultX: 0
    property real defaultY: 0

    signal positionLoaded(real x, real y)

    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: util.loadPosition()
    }

    Process {
        id: readProc
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(this.text)
                    currentX = typeof parsed.x === "number" ? parsed.x : defaultX
                    currentY = typeof parsed.y === "number" ? parsed.y : defaultY
                    positionLoaded(currentX, currentY)
                } catch (e) {
                    currentX = defaultX
                    currentY = defaultY
                    positionLoaded(currentX, currentY)
                }
            }
        }
    }

    Process {
        id: writeProc
        command: []
    }

    function applyPosition(x, y, container, clampScreen = true) {
        let finalX = x
        let finalY = y

        if (clampScreen && container) {
            const maxX = container.parent.width - container.width
            const maxY = container.parent.height - container.height
            finalX = Math.max(0, Math.min(finalX, maxX))
            finalY = Math.max(0, Math.min(finalY, maxY))
        }

        currentX = finalX
        currentY = finalY

        Qt.callLater(() => {
            savePosition(finalX, finalY)
            positionLoaded(finalX, finalY)
        })
    }

    function resetPosition(container) {
        applyPosition(defaultX, defaultY, container)
    }

    function loadPosition() {
        const fallback = JSON.stringify({ x: defaultX, y: defaultY }).replace(/'/g, "'\\''")
        readProc.command = ["sh", "-c", "cat '" + jsonPath + "' 2>/dev/null || echo '" + fallback + "'"]
        readProc.running = true
    }

    function savePosition(x, y) {
        const json = JSON.stringify({ x: x, y: y }).replace(/'/g, "'\\''")
        writeProc.command = ["sh", "-c", "echo '" + json + "' > '" + jsonPath + "'"]
        writeProc.running = true
    }
}
