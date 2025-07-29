import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Item {
    id: indicatorUtil

    signal volumeUpdated(int volume, bool muted)
    signal brightnessUpdated(int brightness)

    property int volume: 0
    property bool muted: false
    property int _lastVolume: -1
    property bool _lastMuted: false

    property int brightness: -1
    property int _lastBrightness: -1
    property int _currentRawBrightness: -1

    readonly property PwNode sink: Pipewire.defaultAudioSink

    PwObjectTracker {
        objects: [sink]
    }

    Connections {
        target: sink?.audio
        onVolumeChanged: {
            maybeEmitVolume()
        }
        onMutedChanged: {
            maybeEmitVolume()
        }
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            maybeEmitVolume()
            getBrightnessProc.running = true
        }
    }

    function maybeEmitVolume() {
        if (!sink || !sink.audio) return;

        const newVol = Math.round(sink.audio.volume * 100)
        const newMuted = sink.audio.muted

        if (newVol !== _lastVolume || newMuted !== _lastMuted) {
            _lastVolume = newVol
            _lastMuted = newMuted
            volume = newVol
            muted = newMuted
            volumeUpdated(volume, muted)
        }
    }

    // === BRIGHTNESS (JANGAN DIUBAH) ===
    Process {
        id: getBrightnessProc
        command: ["brightnessctl", "g"]
        stdout: StdioCollector {
            onStreamFinished: {
                let raw = parseInt(this.text.trim())
                if (!isNaN(raw)) {
                    _currentRawBrightness = raw
                    getMaxBrightnessProc.running = true
                }
            }
        }
    }

    Process {
        id: getMaxBrightnessProc
        command: ["brightnessctl", "m"]
        stdout: StdioCollector {
            onStreamFinished: {
                let max = parseInt(this.text.trim())
                let current = _currentRawBrightness
                if (!isNaN(max) && max > 0) {
                    let percentage = Math.round((current / max) * 100)
                    if (percentage !== _lastBrightness) {
                        _lastBrightness = percentage
                        brightness = percentage
                        brightnessUpdated(percentage)
                    }
                }
            }
        }
    }
}
