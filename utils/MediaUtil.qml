import QtQuick
import Quickshell
import Quickshell.Io
import QtCore
import qs.config

Item {
    id: mediaUtil

    readonly property string imagePath: StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString().replace(/^file:\/\//, "") + "/quickshell/savedata/cover-art.png"
    property string artist: "Open music player app to start"
    property string title: "No Media Found"
    property string coverArtUrl: ""
    property string lastCoverUrl: ""
    property string coverSource: imagePath
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

    signal mediaLoaded(string title, string artist, string coverSource)

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
            })
        }
    }

    Process {
        id: metadataProc
        command: ["sh","-c","playerctl -p plasma-browser-integration metadata --format '{{artist}}|{{title}}|{{mpris:artUrl}}|{{xesam:url}}'"]
        stdout: StdioCollector {
            onTextChanged: {
                const parts = text.trim().split("|")
                if (parts.length === 4) {
                    const newArtist = parts[0]
                    const newTitle = parts[1]
                    const newCover = parts[2]

                    const changedTrack = (newTitle !== mediaUtil.lastTitle || newArtist !== mediaUtil.lastArtist)

                    mediaUtil.artist = newArtist
                    mediaUtil.title = newTitle
                    mediaUtil.coverArtUrl = newCover
                    mediaUtil.hasPlayer = true

                    if (changedTrack) {
                        mediaUtil.justChangedTrack = true
                        mediaUtil.position = 0
                        mediaUtil.duration = 1
                        mediaUtil.progress = 0
                        mediaUtil.formattedTime = "00:00 ・ 00:00"
                        mediaUtil.lastTitle = newTitle
                        mediaUtil.lastArtist = newArtist
                        Qt.callLater(() => mediaUtil.justChangedTrack = false)
                    }

                    if (coverArtUrl && coverArtUrl !== lastCoverUrl) {
                        lastCoverUrl = coverArtUrl
                        saveCoverArtFile(coverArtUrl, newTitle + newArtist)
                    } else if (changedTrack) {
                        coverSource = imagePath
                        mediaLoaded(title, artist, coverSource)
                    }

                } else {
                    mediaUtil.hasPlayer = false
                    mediaUtil.title = "No Media Found"
                    mediaUtil.artist = "Open music player app to start"
                    coverSource = imagePath
                    mediaLoaded(title, artist, coverSource)
                }
            }
        }
    }

    Process {
        id: statusProc
        command: ["playerctl","-p","plasma-browser-integration","status"]
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
        command: ["playerctl","-p","plasma-browser-integration","position"]
        stdout: StdioCollector {
            onTextChanged: {
                const newPos = parseFloat(text.trim()) || 0
                if (!mediaUtil.justChangedTrack) {
                    mediaUtil.position = newPos
                    updateProgress()
                }
            }
        }
    }

    Process {
        id: lengthProc
        command: ["sh","-c","playerctl -p plasma-browser-integration metadata mpris:length"]
        stdout: StdioCollector {
            onTextChanged: {
                const microseconds = parseFloat(text.trim()) || 0
                const newDuration = microseconds / 1000000
                if (!mediaUtil.justChangedTrack) {
                    mediaUtil.duration = newDuration > 0 ? newDuration : 0
                    updateProgress()
                }
            }
        }
    }

    function updateProgress() {
        progress = duration > 0 ? position / duration : 0
        formattedTime = formatSeconds(position) + " ・ " + formatSeconds(duration)
    }

    function formatSeconds(seconds) {
        let hrs = Math.floor(seconds/3600)
        let mins = Math.floor((seconds%3600)/60)
        let secs = Math.floor(seconds%60)
        const mm = mins.toString().padStart(2,"0")
        const ss = secs.toString().padStart(2,"0")
        if (hrs>0) return hrs.toString().padStart(2,"0")+":"+mm+":"+ss
        return mm+":"+ss
    }

    function setPosition(progressRatio) {
        let seconds = progressRatio * duration
        if (seconds < 1) seconds = 1
        setPositionProc.targetSeconds = seconds
        setPositionProc.command = ["sh", "-c", `playerctl -p plasma-browser-integration position ${Math.round(seconds)}`]
        setPositionProc.running = true
    }

    Process {
        id: setPositionProc
        property real targetSeconds: 0
        command: []
    }

    Process {
        id: downloadProc
        command: []
        stdout: StdioCollector {
            onTextChanged: {
                if (text.trim().endsWith("done")) {
                    coverSource = imagePath
                    mediaLoaded(title, artist, coverSource)
                }
            }
        }
    }

    function saveCoverArtFile(url, trackId) {
        if (!url) return
        const folder = imagePath.replace(/\/[^\/]+$/,"")
        coverSource = imagePath
        downloadProc.command = ["sh","-c",
            "mkdir -p '" + folder + "' && curl -s -L '" + url + "' -o '" + imagePath + "' && echo 'done'"
        ]
        downloadProc.running = true
    }

    Component.onCompleted: {
        coverSource = imagePath
        mediaLoaded(title, artist, coverSource)
    }
}
