import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: batteryUtils
    property int batteryPercent: 0
    property bool isCharging: false

    Process {
        id: batteryProc
        command: ["sh", "-c", `
            upower -i $(upower -e | grep BAT)
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const text = this.text;

                const percentMatch = text.match(/percentage:\s+(\d+)%/);
                if (percentMatch) {
                    batteryUtils.batteryPercent = parseInt(percentMatch[1]);
                }

                const chargingMatch = text.match(/state:\s+(\w+)/);
                batteryUtils.isCharging = chargingMatch && chargingMatch[1] === "charging";
            }
        }
    }

    Timer {
        interval: 2000 
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: batteryProc.running = true
    }
}
