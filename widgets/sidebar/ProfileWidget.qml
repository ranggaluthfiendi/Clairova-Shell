import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell.Widgets
import qs.config
import qs.utils
import qs.widgets.bar.left
import qs.widgets.sidebar

Item {
    id: container
    width: parent.width
    height: 80 * Appearance.scaleFactor
    anchors.horizontalCenter: parent.horizontalCenter

    ProfileUtil { id: profileUtil }

    property alias notifWidget: notifWidget
    signal requestLock()

    RowLayout {
        anchors.fill: parent
        spacing: 20 * Appearance.scaleFactor

        RowLayout {
            spacing: 20 * Appearance.scaleFactor

            ClippingWrapperRectangle {
                width: 60 * Appearance.scaleFactor
                height: width
                radius: height / 2
                clip: true

                Image {
                    anchors.fill: parent
                    source: profileUtil.profileImage
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    sourceSize.width: parent.width
                    sourceSize.height: parent.height
                }
            }

            Item {
                id: usernameWrapper
                Layout.fillWidth: true
                height: 28 * Appearance.scaleFactor
                clip: true

                TextMetrics {
                    id: usernameMetrics
                    text: profileUtil.username
                    font.family: Appearance.bitcountFont
                    font.pixelSize: 28 * Appearance.scaleFactor
                }

                Text {
                    id: usernameText
                    visible: usernameMetrics.width <= usernameWrapper.width
                    text: profileUtil.username
                    font.family: Appearance.bitcountFont
                    font.pixelSize: 28 * Appearance.scaleFactor
                    color: Appearance.white
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                }

                Item {
                    id: usernameMarquee
                    visible: usernameMetrics.width > usernameWrapper.width
                    anchors.fill: parent
                    clip: true
                    property real offset: 0

                    Row {
                        id: usernameScrollRow
                        spacing: 40
                        anchors.verticalCenter: parent.verticalCenter
                        x: usernameMarquee.offset

                        Text {
                            text: profileUtil.username
                            font.family: Appearance.bitcountFont
                            font.pixelSize: 28 * Appearance.scaleFactor
                            color: Appearance.white
                        }
                        Text {
                            text: profileUtil.username
                            font.family: Appearance.bitcountFont
                            font.pixelSize: 28 * Appearance.scaleFactor
                            color: Appearance.white
                        }
                    }

                    NumberAnimation on offset {
                        id: usernameAnim
                        from: 0
                        to: -(usernameMetrics.width + 40)
                        duration: (usernameMetrics.width + 40) * 40
                        loops: Animation.Infinite
                        running: usernameMarquee.visible
                    }

                    Component.onCompleted: if (usernameMarquee.visible) usernameAnim.restart()
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
            }
        }

        RowLayout {
            spacing: 16

            // Item {
            //     width: 20 * Appearance.scaleFactor
            //     height: 20 * Appearance.scaleFactor

            //     property bool toggled: false

            //     Text {
            //         id: toggleText
            //         anchors.centerIn: parent
            //         text: parent.toggled ? "switch_right" : "switch_left"
            //         color: Appearance.white
            //         font.family: Appearance.materialSymbols
            //         font.pixelSize: 20 * Appearance.scaleFactor
            //         rotation: 90
            //     }

            //     MouseArea {
            //         anchors.fill: parent
            //         cursorShape: Qt.PointingHandCursor
            //         onClicked: {
            //             parent.toggled = !parent.toggled
            //             bar.isTopBar = parent.toggled
            //             barWindow.toggleBarPosition()
            //         }
            //     }
            // }

            NotifWidget {
                id: notifWidget
                onRequestNotifToggle: toggleNotif()
            }

        
            Item {
                width: 20 * Appearance.scaleFactor
                height: 20 * Appearance.scaleFactor

                Text {
                    anchors.centerIn: parent
                    text: "tune"
                    color: Appearance.white
                    font.family: Appearance.materialSymbols
                    font.pixelSize: 20 * Appearance.scaleFactor
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        barWindow.toggleSetting()
                    }
                }
            }

            Rectangle {
                id: lockButton
                width: 32 * Appearance.scaleFactor
                height: 32 * Appearance.scaleFactor
                radius: width / 2
                color: Appearance.primary
                scale: 1.0

                Behavior on scale {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: requestLock()
                    onEntered: {
                        lockButton.scale = 1.2
                        iconSwitcher.start()
                    }
                    onExited: {
                        lockButton.scale = 1.0
                        iconSwitcher.stop()
                        lockIcon.text = "lock"
                    }
                }

                Text {
                    id: lockIcon
                    anchors.centerIn: parent
                    text: "lock"
                    color: Appearance.color
                    font.family: Appearance.materialSymbols
                    font.pixelSize: 20 * Appearance.scaleFactor
                }

                Timer {
                    id: iconSwitcher
                    interval: 1000
                    repeat: true
                    running: false
                    onTriggered: {
                        lockIcon.text = (lockIcon.text === "lock") ? "lock_open" : "lock"
                    }
                }
            }

        }
    }
}
