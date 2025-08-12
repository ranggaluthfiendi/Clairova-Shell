//@ pragma UseQApplication
import qs.config
import qs.widgets.bar.right
import qs.widgets.bar.left
import qs.widgets.sidebar
import qs.modules
import qs.utils

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Scope {
    id: bar
    property bool isTopBar: true

    Variants {
        model: Quickshell.screens

        PanelWindow {
            color: "transparent"
            id: barWindow
            property var modelData
            screen: modelData
            implicitHeight: 40 * Appearance.scaleFactor
            property bool notifOrSettingOpened: false

            anchors {
                top: bar.isTopBar
                bottom: !bar.isTopBar
                left: true
                right: true
            }

            function toggleBarPosition() {
                if (sidebar.visible)
                    sidebar.hide()
                if (notification.visible)
                    notification.hide()

                Qt.callLater(() => {
                    bar.isTopBar = !bar.isTopBar
                })
            }

            function toggleSidebar() {
                if (sidebar.visible) {
                    sidebar.hide()
                    notification.hide()
                    volumePopup.hide()
                } else {
                    sidebar.show()
                    notification.show()
                    volumePopup.show()
                }
            }

            function toggleNotif() {
                if (notification.visible) {
                    notification.hide()
                    sidebar.notifWidget.setToggled(false)
                } else {
                    if (settingPopup.visible) {
                        settingPopup.hide()
                    }
                    notification.show()
                    sidebar.notifWidget.setToggled(true)
                }
            }

            function toggleSetting() {
                if (settingPopup.visible) {
                    settingPopup.hide()
                } else {
                    if (notification.visible) {
                        notification.hide()
                    }
                    settingPopup.show()
                }
            }

            function toggleVolume() {
                if (volumePopup.visible) {
                    volumePopup.hide()
                } else {
                    volumePopup.show()
                }
            }

            Behavior on anchors.top {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on anchors.bottom {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.InOutQuad
                }
            }

            Sidebar {
                id: sidebar
                anchor.window: barWindow

                implicitWidth: Math.min(
                    barWindow.screen.width / 3,
                    400 * Appearance.scaleFactor
                )

                anchor.rect.x: (barWindow.screen.width - width) - 10
                anchor.rect.y: bar.isTopBar ? barWindow.height + 10 : barWindow.height - height - 75

                visible: false

                onVisibleChanged: {
                    if (!visible) {
                        if (notification.visible) notification.hide()
                        if (volumePopup.visible) volumePopup.hide()
                        sidebar.notifWidget.setToggled(false)
                    }
                }

                onRequestResetNotifToggled: {
                    sidebar.notifWidget.setToggled(false)
                }
            }

            MouseArea {
                id: edgeTrigger
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                }
                width: 4 
                hoverEnabled: true
                visible: true
                z: 999 

                onEntered: {
                    if (!sidebar.visible) {
                        sidebar.show()
                    }
                }

                onExited: {
                    if (!sidebar.containsMouse) {
                        sidebar.hide()
                    }
                }
            }


            Notification {
                id: notification
                isTopBar: barWindow.anchors.top
                anchor.window: barWindow

                implicitWidth: Math.min(
                    barWindow.screen.width / 3,
                    400 * Appearance.scaleFactor
                )

                anchor.rect.x: sidebar.anchor.rect.x - width - 10
                anchor.rect.y: bar.isTopBar ? barWindow.height + 10 : barWindow.height - height - 75

                visible: false
            }

            Setting {
                id: settingPopup
                isTopBar: barWindow.anchors.top
                anchor.window: barWindow

                implicitWidth: Math.min(
                    barWindow.screen.width / 3,
                    400 * Appearance.scaleFactor
                )

                anchor.rect.x: sidebar.anchor.rect.x - width - 10
                anchor.rect.y: bar.isTopBar ? barWindow.height + 10 : barWindow.height - height - 75

                visible: false
            }

            VolumeControl {
                id: volumePopup
                isTopBar: barWindow.anchors.top
                anchor.window: barWindow

                implicitWidth: Math.min(
                    barWindow.screen.width / 3,
                    400 * Appearance.scaleFactor
                )

                anchor.rect.x: sidebar.anchor.rect.x - width - 10
                anchor.rect.y: {
                    const padding = 10
                    if (bar.isTopBar) {
                        if (settingPopup.visible)
                            return settingPopup.anchor.rect.y + settingPopup.height + padding
                        else if (notification.visible)
                            return notification.anchor.rect.y + notification.height + padding
                        else
                            return barWindow.height + padding
                    } else {
                        if (settingPopup.visible)
                            return settingPopup.anchor.rect.y - volumePopup.height - padding
                        else if (notification.visible)
                            return notification.anchor.rect.y - volumePopup.height - padding
                        else
                            return barWindow.height - volumePopup.height - 75
                    }
                }

                visible: false
            }

            Rectangle {
                id: barColor
                anchors.fill: parent
                color: Appearance.currentBackground

                RowLayout {
                    id: barContent
                    anchors.fill: parent

                    WorkspaceWidget {}

                    SysTrayWidget {}

                    MediaWidget {}

                    Item { Layout.fillWidth: true }

                    IndicatorWidget {}
                    SpeedWidget {}

                    SystemWidget {
                        onRequestSidebarToggle: toggleSidebar()
                    }
                }
            }
        }
    }
}
