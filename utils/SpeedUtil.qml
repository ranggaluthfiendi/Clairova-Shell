import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: speedUtil
    property real downloadSpeed: 0
    property real uploadSpeed: 0
    property string activeInterface: ""
    property int lastRx: 0
    property int lastTx: 0

    Process {
        id: detectInterface
        command: ["sh", "-c", `
            ip -o addr show up primary scope global | awk '{print $2}' | head -n1
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const iface = this.text.trim()
                if (iface) {
                    speedUtil.activeInterface = iface
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: detectInterface.running = true
    }

    Process {
        id: checkSpeed
        command: ["sh", "-c", `
            rx=$(cat /sys/class/net/${speedUtil.activeInterface}/statistics/rx_bytes)
            tx=$(cat /sys/class/net/${speedUtil.activeInterface}/statistics/tx_bytes)
            echo "$rx $tx"
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const [rxStr, txStr] = this.text.trim().split(" ")
                const rx = parseInt(rxStr)
                const tx = parseInt(txStr)

                if (!isNaN(rx) && !isNaN(tx)) {
                    speedUtil.downloadSpeed = (rx - speedUtil.lastRx) / 1024
                    speedUtil.uploadSpeed = (tx - speedUtil.lastTx) / 1024
                    speedUtil.lastRx = rx
                    speedUtil.lastTx = tx
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (speedUtil.activeInterface !== "") {
                checkSpeed.running = true
            }
        }
    }
}
