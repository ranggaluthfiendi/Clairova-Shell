import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: activeAppLogic
    property string app: "Rang"

    Process {
        id: appProc
        command: ["hyprctl", "activewindow", "-j"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let json = JSON.parse(this.text);
                    let appName = json.initialTitle || json.initialClass || json.class || "Rang";
                    let title = json.title || "";
                    let cleanedTitle = title.replace(new RegExp("\\s*-?\\s*" + appName + "\\s*$", "i"), "").trim();
                    activeAppLogic.app = cleanedTitle ? appName + " | " + cleanedTitle : appName;
                } catch (e) {
                    activeAppLogic.app = "Rang";
                }
            }
        }
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: appProc.running = true
    }
}
