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
import Quickshell.Wayland

Scope {
    id: bar
    property bool isTopBar: true
    property bool sidebarLocked: false
    property bool volumeLocked: false
    signal requestLock()
    property var barWindowRef

    Variants {
        model: Quickshell.screens

        PanelWindow {
            color: "transparent"
            id: barWindow
            property var modelData
            screen: modelData
            implicitHeight: 40 * Appearance.scaleFactor
            property bool notifOrSettingOpened: false
            
            property int currentLayer: WlrLayer.Top
            WlrLayershell.layer: currentLayer

            anchors {
                top: bar.isTopBar
                bottom: !bar.isTopBar
                left: true
                right: true
            }

            Component.onCompleted: {
                bar.barWindowRef = barWindow
            }

            Behavior on anchors.top {
                NumberAnimation { duration: 800; easing.type: Easing.InOutQuad }
            }
            Behavior on anchors.bottom {
                NumberAnimation { duration: 800; easing.type: Easing.InOutQuad }
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
                if (sidebar.visible && bar.sidebarLocked) {
                    bar.sidebarLocked = false
                    sidebar.hide()
                } else if (sidebar.visible) {
                    sidebar.hide()
                    volumePopup.hide()
                } else {
                    sidebar.show()
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
                        bar.sidebarLocked = false
                    }
                }

                onRequestResetNotifToggled: {
                    sidebar.notifWidget.setToggled(false)
                }
                onRequestLock: {
                    if (sidebar.visible) {
                        sidebar.hide()
                        bar.sidebarLocked = false
                    }
                    if (volumePopup.visible) {
                        volumePopup.hide()
                        bar.volumeLocked = false
                    }
                    if (notification.visible) {
                        notification.hide()
                        sidebar.notifWidget.setToggled(false)
                    }
                    if (settingPopup.visible) {
                        settingPopup.hide()
                    }

                    bar.requestLock()
                }
            }

            MouseArea {
                id: edgeTrigger
                anchors {
                    top: parent.top
                    right: parent.right
                }
                width: 40 * Appearance.scaleFactor
                height: 40 * Appearance.scaleFactor
                hoverEnabled: true
                visible: true
                z: 999

                onEntered: {
                    if (!sidebar.visible) sidebar.show()
                    if (!volumePopup.visible) volumePopup.show()
                }

                onExited: {
                    if (!bar.sidebarLocked && !sidebar.containsMouse) sidebar.hide()
                    if (!bar.volumeLocked && !volumePopup.containsMouse) volumePopup.hide()
                }

                onClicked: {
                    bar.sidebarLocked = !bar.sidebarLocked
                    bar.volumeLocked = !bar.volumeLocked

                    if (!bar.sidebarLocked) sidebar.hide()
                    if (!bar.volumeLocked) volumePopup.hide()
                }

                cursorShape: Qt.PointingHandCursor
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
                anchor.rect.y: bar.isTopBar
                    ? barWindow.height + 10
                    : barWindow.height - height - 75

                visible: false
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
                anchor.rect.y: volumePopup.visible
                    ? volumePopup.anchor.rect.y + volumePopup.height + 10
                    : bar.isTopBar
                        ? barWindow.height + 10
                        : barWindow.height - height - 75

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
                anchor.rect.y: volumePopup.visible
                    ? volumePopup.anchor.rect.y + volumePopup.height + 10
                    : bar.isTopBar
                        ? barWindow.height + 10
                        : barWindow.height - height - 75

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

                    // MediaWidget {}

                    Item { Layout.fillWidth: true }

                    IndicatorWidget {}
                    SpeedWidget {}
                    TimeWidget {}
                    SystemWidget {
                        onRequestSidebarToggle: toggleSidebar()
                    }
                }
            }
        }
    }
    GlobalShortcut {
        id: toggleLayerShortcut
        appid: "quickshell"
        name: "toggle-bar-layer"
        description: "Toggle bar layer between Top and Overlay"

        onPressed: {
            if (!bar.barWindowRef) return;

            var newLayer = (bar.barWindowRef.WlrLayershell.layer === WlrLayer.Bottom)
                        ? WlrLayer.Overlay
                        : WlrLayer.Bottom;

            bar.barWindowRef.WlrLayershell.layer = newLayer
            bar.barWindowRef.currentLayer = newLayer

            bar.barWindowRef.visible = false
            Qt.callLater(() => bar.barWindowRef.visible = true)
        }
    }
}
