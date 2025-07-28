import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: timeLogic
    property string time: "--:--"

    Process {
        id: timeProc
        command: ["sh", "-c", `
            date_str=$(date '+%a %d  %H:%M')
            offset=$(date +%z)
            case "$offset" in
                +0700) zone="WIB" ;;
                +0800) zone="WITA" ;;
                +0900) zone="WIT" ;;
                *) zone="" ;;
            esac
            echo "$date_str $zone"
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.length > 0) {
                    timeLogic.time = this.text.trim()
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: timeProc.running = true
    }
}
