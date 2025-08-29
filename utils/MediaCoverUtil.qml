import QtQuick
import Quickshell
import Quickshell.Io
import QtCore
import qs.config

Item {
    id: mediaCoverUtil

    readonly property string imagePath: StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString()
        .replace(/^file:\/\//, "") + "/quickshell/savedata/current-cover.png"

    property string trackArtUrl: ""        // diisi dari currentPlayer.trackArtUrl
    property string lastTrackArtUrl: ""
    property string coverSource: imagePath // ini dipakai di Image.source

    signal coverUpdated(string coverSource)

    Process {
        id: downloadProc
        command: []
        stdout: StdioCollector {
            onTextChanged: {
                if (text.trim().endsWith("done")) {
                    mediaCoverUtil.coverSource = imagePath + "?v=" + Math.random().toString(36).substr(2, 8)
                    mediaCoverUtil.coverUpdated(mediaCoverUtil.coverSource)
                }
            }
        }
    }

    function saveCoverArtFile(url) {
        if (!url) return
        const folder = imagePath.replace(/\/[^\/]+$/, "")
        coverSource = imagePath
        downloadProc.command = ["sh","-c",
            "mkdir -p '" + folder + "' && curl -s -L '" + url + "' -o '" + imagePath + "' && echo 'done'"
        ]
        downloadProc.running = true
    }

    onTrackArtUrlChanged: {
        if (trackArtUrl && trackArtUrl !== lastTrackArtUrl) {
            lastTrackArtUrl = trackArtUrl
            saveCoverArtFile(trackArtUrl)
        }
    }

    Component.onCompleted: {
        coverSource = imagePath
    }
}
