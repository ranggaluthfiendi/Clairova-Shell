import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: wifiUtils

    property bool debug: false
    property int signalStrength: -2
    property string networkName: ""
    property bool enabled: false

    function toggle() {
        toggleProc.command = ["sh", "-c", enabled ? "nmcli radio wifi off" : "nmcli radio wifi on"]
        toggleProc.running = true
        if (debug) console.log("[WifiUtils] Toggle WiFi:", toggleProc.command.join(" "))
    }

    Process {
        id: signalProc
        command: ["sh", "-c", "nmcli -t -f ACTIVE,SIGNAL dev wifi | grep '^yes' | cut -d: -f2"]
        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseInt(this.text.trim())
                wifiUtils.signalStrength = isNaN(val) ? -2 : val
                wifiUtils.enabled = !isNaN(val) && val >= 0

                if (wifiUtils.debug) {
                    console.log("[WifiUtils] Strength:", wifiUtils.signalStrength)
                }
            }
        }
    }

    Process {
        id: nameProc
        command: ["sh", "-c", "nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2"]
        stdout: StdioCollector {
            onStreamFinished: {
                wifiUtils.networkName = this.text.trim()
                if (wifiUtils.debug) {
                    console.log("[WifiUtils] Name:", wifiUtils.networkName)
                }
            }
        }
    }

    Process {
        id: toggleProc
        command: []
        onRunningChanged: {
            if (!running) {
                if (debug) console.log("[WifiUtils] Toggle done, refreshing...")
                signalProc.running = true
                nameProc.running = true
            }
        }
    }

    Timer {
        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!signalProc.running) signalProc.running = true
            if (!nameProc.running) nameProc.running = true
        }
    }
}
