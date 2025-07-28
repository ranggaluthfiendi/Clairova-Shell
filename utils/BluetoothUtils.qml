import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: bluetoothUtils

    property bool enabled: false
    property bool connected: false
    property string icon: "bluetooth_disabled"
    property string connectedDeviceName: ""
    property string statusText: "Disabled"

    property bool debug: false

    function toggleBluetooth() {
        toggleProc.running = true
    }

    function updateIcon() {
        if (!enabled) {
            icon = "bluetooth_disabled"
            statusText = "Disabled"
            connectedDeviceName = ""
        } else if (connected) {
            icon = "bluetooth_connected"
            statusText = "Connected"
        } else {
            icon = "bluetooth"
            statusText = "Enabled"
            connectedDeviceName = ""
        }

        if (debug) {
            console.log("[BluetoothUtils] enabled:", enabled,
                        "| connected:", connected,
                        "| icon:", icon,
                        "| device:", connectedDeviceName,
                        "| statusText:", statusText)
        }
    }

    Process {
        id: checkEnabledProc
        command: ["sh", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo on || echo off"]
        stdout: StdioCollector {
            onStreamFinished: {
                bluetoothUtils.enabled = this.text.trim() === "on"
                bluetoothUtils.updateIcon()
            }
        }
    }

    Process {
        id: checkConnectedProc
        command: ["sh", "-c", `
            for addr in $(bluetoothctl devices | awk '{print $2}'); do
                info=$(bluetoothctl info "$addr")
                echo "$info" | grep -q "Connected: yes" && \
                    echo "$(echo "$info" | grep "Name:" | sed 's/.*Name: //')" && exit 0
            done
            echo "__DISCONNECTED__"
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                let output = this.text.trim()
                if (output !== "" && output !== "__DISCONNECTED__") {
                    bluetoothUtils.connected = true
                    bluetoothUtils.connectedDeviceName = output
                } else {
                    bluetoothUtils.connected = false
                    bluetoothUtils.connectedDeviceName = ""
                }
                bluetoothUtils.updateIcon()
            }
        }
    }

    Timer {
        interval: 200
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!checkEnabledProc.running)
                checkEnabledProc.running = true
            if (!checkConnectedProc.running)
                checkConnectedProc.running = true
        }
    }

    Process {
        id: toggleProc
        command: ["sh", "-c", `
            bluetoothctl show | grep -q 'Powered: yes' &&
                bluetoothctl power off ||
                bluetoothctl power on
        `]
    }
}
