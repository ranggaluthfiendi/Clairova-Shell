import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: mediaUtil

    property string artist: ""
    property string title: ""
    property string coverArt: ""
    property string url: ""
    property string status: "Stopped"
    property bool isPlaying: false
    property bool hasPlayer: false

    property real position: 0
    property real duration: 1
    property real progress: 0
    property string formattedTime: "00:00 ・ 00:00"
    property bool justChangedTrack: false
    property string lastTitle: ""
    property string lastArtist: ""

    function formatSeconds(seconds) {
        let hrs = Math.floor(seconds / 3600)
        let mins = Math.floor((seconds % 3600) / 60)
        let secs = Math.floor(seconds % 60)

        let mm = mins.toString().padStart(2, "0")
        let ss = secs.toString().padStart(2, "0")

        if (hrs > 0) {
            let hh = hrs.toString().padStart(2, "0")
            return hh + ":" + mm + ":" + ss
        } else {
            return mm + ":" + ss
        }
    }

    function updateProgress() {
        if (duration > 0) {
            progress = position / duration
        } else {
            progress = 0
        }

        formattedTime = formatSeconds(position) + " ・ " + formatSeconds(duration)
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            metadataProc.running = true
            statusProc.running = true

            Qt.callLater(() => {
                if (!mediaUtil.justChangedTrack) {
                    positionProc.running = true
                    lengthProc.running = true
                }

                if (mediaUtil.isPlaying && mediaUtil.duration > 0 && mediaUtil.position >= mediaUtil.duration - 1) {
                    mediaUtil.position = mediaUtil.duration
                    mediaUtil.progress = 1
                    mediaUtil.updateProgress()
                    mediaUtil.justChangedTrack = true
                    Qt.callLater(() => mediaUtil.justChangedTrack = false)
                }
            })
        }
    }

    Process {
        id: metadataProc
        command: ["sh", "-c", "playerctl -p plasma-browser-integration metadata --format '{{artist}}|{{title}}|{{mpris:artUrl}}|{{xesam:url}}'"]
        stdout: StdioCollector {
            onTextChanged: {
                const parts = text.trim().split("|")
                if (parts.length === 4) {
                    const newArtist = parts[0]
                    const newTitle = parts[1]
                    const newCover = parts[2]
                    const newUrl = parts[3]

                    const changed = (newTitle !== mediaUtil.lastTitle || newArtist !== mediaUtil.lastArtist)
                    if (changed) {
                        mediaUtil.justChangedTrack = true
                        mediaUtil.position = 0
                        mediaUtil.duration = 1
                        mediaUtil.progress = 0
                        mediaUtil.formattedTime = "00:00 ・ 00:00"
                        mediaUtil.lastTitle = newTitle
                        mediaUtil.lastArtist = newArtist
                        Qt.callLater(() => mediaUtil.justChangedTrack = false)
                    }

                    mediaUtil.artist = newArtist
                    mediaUtil.title = newTitle
                    mediaUtil.coverArt = newCover
                    mediaUtil.url = newUrl
                    mediaUtil.hasPlayer = true
                } else {
                    mediaUtil.artist = ""
                    mediaUtil.title = ""
                    mediaUtil.coverArt = ""
                    mediaUtil.url = ""
                    mediaUtil.hasPlayer = false
                }
            }
        }
    }

    Process {
        id: statusProc
        command: ["playerctl", "-p", "plasma-browser-integration", "status"]
        stdout: StdioCollector {
            onTextChanged: {
                const state = text.trim()
                mediaUtil.status = state
                mediaUtil.isPlaying = state === "Playing"
            }
        }
    }

    Process {
        id: positionProc
        command: ["playerctl", "-p", "plasma-browser-integration", "position"]
        stdout: StdioCollector {
            onTextChanged: {
                const newPos = parseFloat(text.trim()) || 0
                if (!mediaUtil.justChangedTrack) {
                    mediaUtil.position = newPos
                    mediaUtil.updateProgress()
                }
            }
        }
    }

    Process {
        id: lengthProc
        command: ["sh", "-c", "playerctl -p plasma-browser-integration metadata mpris:length"]
        stdout: StdioCollector {
            onTextChanged: {
                const microseconds = parseFloat(text.trim()) || 0
                const newDuration = microseconds / 1000000
                if (!mediaUtil.justChangedTrack) {
                    mediaUtil.duration = newDuration > 0 ? newDuration : 0
                    mediaUtil.updateProgress()
                }
            }
        }
    }

    Process {
        id: setPositionProc
        property real targetSeconds: 0
        command: ["sh", "-c", `playerctl -p plasma-browser-integration position ${Math.round(targetSeconds)}`]
    }

    function setPosition(progressRatio) {
        let seconds = progressRatio * duration
        if (seconds < 1) seconds = 1
        setPositionProc.targetSeconds = seconds
        setPositionProc.command = ["sh", "-c", `playerctl -p plasma-browser-integration position ${Math.round(seconds)}`]
        setPositionProc.running = true
    }
}
