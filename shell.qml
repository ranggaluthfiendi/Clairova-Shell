//@ pragma UseQApplication
import qs.modules
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland 

ShellRoot {
    Bar {
        id: topBar
        onRequestLock: lock.locked = true
    }
    Screens {}

    LockContext {
        id: lockContext
        onUnlocked: lock.locked = false
    }

    WlSessionLock {
        id: lock
        locked: true

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }

    GlobalShortcut {
        id: toggleLockShortcut
        appid: "quickshell"
        name: "toggle-lock"
        description: "Toggle lockscreen"
        onPressed: lock.locked = !lock.locked
    }
}
