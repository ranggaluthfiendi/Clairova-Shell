import QtQuick
import Quickshell.Io

QtObject {
    id: button

    property string text: ""
    property string icon: ""
    property var triggeredCallback: null

    property string command: ""
    property var keybind: null

    readonly property var process: Process {
        command: ["sh", "-c", button.command]
    }

    function exec() {
        if (triggeredCallback !== null) {
            triggeredCallback()
        } 
        else if (command && command.length > 0) {
            process.startDetached()
        }
    }
}
