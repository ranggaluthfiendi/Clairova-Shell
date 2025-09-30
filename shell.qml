//@ pragma UseQApplication
import qs.modules
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland 
import qs.config
import qs.utils

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

    Logout {
        id: logoutPanel

        buttons: [
            LogoutButton { 
                text: "Lock"; 
                icon: "lock"; 
                triggeredCallback: function() { 
                    lock.locked = true
                    if (logoutPanel.panelWindowRef) logoutPanel.panelWindowRef.visible = false
                    if (topBar.barWindowRef && topBar.barWindowRef.sidebar.visible) {
                        topBar.barWindowRef.sidebar.hide()
                    }
                }  
            },

            LogoutButton {
                text: "Shutdown"
                icon: "power_settings_new"
                command: "systemctl poweroff"
            },

            LogoutButton {
                text: "Reboot"
                icon: "restart_alt"
                command: "systemctl reboot"
            }
        ]
    }
}
