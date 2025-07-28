import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: brightnessUtil

    property real brightness: 0.7
    property bool _initialized: false
    property bool _internalUpdate: false

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: brightnessGetProc.running = true
    }

    Process {
        id: brightnessGetProc
        command: ["sh", "-c", `
            VALUE=$(brightnessctl get)
            MAX=$(brightnessctl max)
            if [ "$MAX" -gt 0 ]; then
                echo $((1000 * VALUE / MAX))
            else
                echo 0
            fi
        `]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const raw = parseInt(this.text.trim())
                if (!isNaN(raw)) {
                    _internalUpdate = true
                    brightness = Math.max(0, Math.min(1, raw / 1000))
                    _internalUpdate = false
                }
            }
        }
    }

    Process {
        id: brightnessSetProc
        onRunningChanged: if (!running) brightnessGetProc.running = true
    }

    onBrightnessChanged: {
        if (!_initialized || _internalUpdate) return
        brightnessSetProc.command = ["brightnessctl", "set", Math.round(brightness * 100) + "%"]
        brightnessSetProc.running = true
    }

    Component.onCompleted: {
        brightnessGetProc.running = true
        _initialized = true
    }
}
