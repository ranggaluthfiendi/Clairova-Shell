import QtQuick
import QtQuick.Controls
import Quickshell
import qs.config
import qs.utils
import qs.widgets.screen

Scope {
    id: screenScope

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: mainWindow
            screen: modelData
            color: "transparent"
            visible: true
            aboveWindows: false

            anchors {
                top: true
                right: true
                left: true
                bottom: true
            }

            TimeWidget {}
            LinuxWidget {}

        }
    }
}
