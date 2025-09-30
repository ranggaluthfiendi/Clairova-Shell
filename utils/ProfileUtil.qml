import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Item {
    id: profileUtil

    property string username: "Unknown"
    property string profileImage: "root:/assets/default-profile.png"

    Process {
        id: getUsernameProc
        command: ["whoami"]

        stdout: StdioCollector {
            onStreamFinished: {
                const name = this.text.trim()
                if (name.length > 0) {
                    profileUtil.username = name

                    const accIconPath = "/var/lib/AccountsService/icons/" + name
                    checkImage.command = ["sh", "-c", "test -f " + accIconPath + " && echo OK || echo NO"]
                    checkImage.running = true
                }
            }
        }
    }

    Process {
        id: checkImage
        command: []

        stdout: StdioCollector {
            onStreamFinished: {
                const iconPath = "/var/lib/AccountsService/icons/" + profileUtil.username
                if (this.text.trim() === "OK") {
                    profileUtil.profileImage = "file://" + iconPath
                } else {
                    profileUtil.profileImage = "root:/assets/default-profile.png"
                }
            }
        }
    }

    Component.onCompleted: getUsernameProc.running = true
}
