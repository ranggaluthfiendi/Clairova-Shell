import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: indicatorUtil

    signal volumeUpdated(int volume, bool muted)
    signal brightnessUpdated(int brightness)

    property int volume: 0
    property bool muted: false
    property int _lastVolume: -1
    property bool _lastMuted: false
    property int _tempVolume: -1
    property bool _tempMuted: false
    property bool _volumeReady: false
    property bool _muteReady: false

    property int brightness: -1
    property int _lastBrightness: -1
    property int _currentRawBrightness: -1

    Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            _volumeReady = false
            _muteReady = false
            getVolumeProc.running = true
            getMuteProc.running = true
            getBrightnessProc.running = true
        }
    }

    Process {
        id: getVolumeProc
        command: ["pactl", "get-sink-volume", "@DEFAULT_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const match = this.text.match(/(\d+)%/)
                if (match) {
                    _tempVolume = parseInt(match[1])
                    _volumeReady = true
                }
                maybeEmitVolume()
            }
        }
    }

    Process {
        id: getMuteProc
        command: ["pactl", "get-sink-mute", "@DEFAULT_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                _tempMuted = this.text.toLowerCase().includes("yes")
                _muteReady = true
                maybeEmitVolume()
            }
        }
    }

    function maybeEmitVolume() {
        if (_volumeReady && _muteReady) {
            if (_tempVolume !== _lastVolume || _tempMuted !== _lastMuted) {
                _lastVolume = _tempVolume
                _lastMuted = _tempMuted

                volume = _tempVolume
                muted = _tempMuted

                volumeUpdated(volume, muted)
            }
        }
    }

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
