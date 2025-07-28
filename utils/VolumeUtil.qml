import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: volumeUtil

    property real volume: 0.7
    property bool muted: false
    property real lastVolumeBeforeMute: 0.7

    property bool _initialized: false
    property bool _internalVolumeUpdate: false
    property bool _internalMutedUpdate: false

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: volumeGetProc.running = true
    }

    Process {
        id: volumeGetProc
        command: ["sh", "-c", `
            VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\s\\d+%' | head -1 | tr -d ' ');
            MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -oP '(yes|no)');
            echo "$VOLUME $MUTE"
        `]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                let parts = this.text.trim().split(" ")
                if (parts.length === 2) {
                    let vol = parseInt(parts[0]) / 100
                    let mute = parts[1] === "yes"

                    _initialized = false

                    _internalVolumeUpdate = true
                    volume = vol
                    _internalVolumeUpdate = false

                    lastVolumeBeforeMute = vol

                    _internalMutedUpdate = true
                    muted = mute
                    _internalMutedUpdate = false

                    _initialized = true
                }
            }
        }
    }

    Process {
        id: volumeSetProc
        onRunningChanged: if (!running) volumeGetProc.running = true
    }

    Process {
        id: muteProc
        command: ["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"]
        onRunningChanged: if (!running) volumeGetProc.running = true
    }

    onVolumeChanged: {
        if (!_initialized || _internalVolumeUpdate) return

        if (volume <= 0.0001) {
            if (!muted) {
                _internalMutedUpdate = true
                muted = true
                _internalMutedUpdate = false
            }
        } else {
            lastVolumeBeforeMute = volume
            if (!muted) {
                volumeSetProc.command = ["pactl", "set-sink-volume", "@DEFAULT_SINK@", Math.round(volume * 100) + "%"]
                volumeSetProc.running = true
            }
        }
    }

    onMutedChanged: {
        if (!_initialized || _internalMutedUpdate) return
        muteProc.running = true
    }
}
