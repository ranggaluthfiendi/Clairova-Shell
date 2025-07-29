import QtQuick
import Quickshell
import QtQml
import Quickshell.Io

Item {
    id: timeLogic
    property string time: "--:--"

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const now = new Date()
            const hours = now.getHours().toString().padStart(2, "0")
            const minutes = now.getMinutes().toString().padStart(2, "0")
            const day = now.getDate().toString().padStart(2, "0")
            const dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            const weekday = dayNames[now.getDay()]

            const offset = now.getTimezoneOffset()
            const zone = offset === -420 ? "WIB"
                       : offset === -480 ? "WITA"
                       : offset === -540 ? "WIT"
                       : ""

            timeLogic.time = `${weekday} ${day} • ${hours}:${minutes} ${zone}`
        }
    }
}
