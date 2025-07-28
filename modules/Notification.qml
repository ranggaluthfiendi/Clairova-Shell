import qs.config
import qs.widgets.notification
import qs.utils

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PopupWindow {
    id: notification
    color: "transparent"
    implicitHeight: wrapper.height

    property real contentY: -wrapper.height
    property bool isAnimating: false
    property bool animatingToHide: false
    property bool isTopBar: true 

    function show() {
        if (notification.visible || isAnimating) return
        notification.visible = true

        if (isTopBar) {
            contentY = -wrapper.height
            anim.from = -wrapper.height
        } else {
            contentY = wrapper.height
            anim.from = wrapper.height
        }

        animatingToHide = false
        anim.to = 0
        anim.start()
    }

    function hide() {
        if (!notification.visible || isAnimating) return
        animatingToHide = true
        anim.from = wrapper.y

        anim.to = isTopBar ? -wrapper.height : wrapper.height
        anim.start()
    }


    Item {
        id: wrapper
        width: parent.width
        height: layout.implicitHeight

        Rectangle {
            id: notifColor
            anchors.fill: parent
            color: Appearance.currentBackground
            radius: 16 * Appearance.scaleFactor

            Flickable {
                id: flick
                anchors.fill: parent
                contentHeight: contentItem.implicitHeight
                interactive: true
                clip: true

                ColumnLayout {
                    id: layout
                    width: flick.width
                    spacing: 0

                    NotificationWidget {
                        backgroundColor: notifColor.color
                        Layout.fillWidth: true
                        Layout.topMargin: 10 * Appearance.scaleFactor
                        Layout.bottomMargin: 20 * Appearance.scaleFactor
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: parent.width - (40 * Appearance.scaleFactor)

                        onRequestNotifToggle: (forceClose) => {
                            if (forceClose) {
                                notification.hide()
                                menuWidget.toggled = false
                            }
                        }

                    }
                    
                }
            }
        }
    }

    PropertyAnimation {
        id: anim
        target: wrapper
        property: "y"
        duration: 400
        easing.type: Easing.InOutCirc

        onRunningChanged: notification.isAnimating = running

        onStopped: {
            if (animatingToHide) {
                notification.visible = false
                notification.contentY = -wrapper.height
            } else {
                notification.contentY = wrapper.y
            }
        }
    }
}
