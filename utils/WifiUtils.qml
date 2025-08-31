import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: wifiUtils

    property bool debug: false
    property int signalStrength: -2
    property string networkName: ""
    property bool enabled: false
    property bool userToggled: false

    function toggle() {
        userToggled = true
        if (enabled) {
            // Kalau lagi nyala → matikan
            toggleProc.command = ["sh", "-c", "nmcli radio wifi off"]
        } else {
            // Kalau mati → nyalakan dan coba reconnect ke last-known network
            toggleProc.command = ["sh", "-c", "nmcli radio wifi on && nmcli connection up id '" + networkName + "' || nmcli device wifi connect '" + networkName + "'"]
        }
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
                if (!wifiUtils.userToggled) {
                    if (val >= 0) {
                        if (!wifiUtils.enabled) {
                            wifiUtils.enabled = true
                            if (debug) console.log("[WifiUtils] Auto enabling WiFi due to signal")
                            toggleProc.command = ["sh", "-c", "nmcli radio wifi on"]
                            toggleProc.running = true
                        }
                    } else {
                        if (wifiUtils.enabled) {
                            wifiUtils.enabled = false
                            if (debug) console.log("[WifiUtils] Auto disabling WiFi due to no signal")
                            toggleProc.command = ["sh", "-c", "nmcli radio wifi off"]
                            toggleProc.running = true
                        }
                    }
                }
                if (val < 10 && wifiUtils.enabled && !wifiUtils.userToggled) {
                    if (debug) console.log("[WifiUtils] Signal weak but WiFi still enabled")
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
                if (debug) {
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
                if (wifiUtils.userToggled) {
                    Qt.callLater(() => wifiUtils.userToggled = false)
                }
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
