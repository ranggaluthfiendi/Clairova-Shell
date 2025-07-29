import qs.config
import qs.widgets.sidebar
import qs.utils

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PopupWindow {
    id: popup
    color: "transparent"
    height: wrapper.height

    property real contentX: width
    property bool isAnimating: false
    

    signal requestResetNotifToggled()

    property alias notifWidget: profile.notifWidget

    function show() {
        if (popup.visible || isAnimating) return
        popup.visible = true
        popup.contentX = width
        anim.from = width
        anim.to = 0
        anim.start()
    }

    function hide() {
        if (!popup.visible || isAnimating) return

        requestResetNotifToggled()

        if (settingPopup.visible) {
            settingPopup.hide()
        }
        anim.from = contentX
        anim.to = width
        anim.start()
    }

    MediaUtil {
        id: mediaUtil
    }

    Item {
        id: wrapper
        width: parent.width
        height: layout.implicitHeight
        x: popup.contentX

        Rectangle {
            id: sidebarColor
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

                    ProfileWidget {
                        id: profile
                        Layout.topMargin: 15 * Appearance.scaleFactor
                        Layout.preferredWidth: parent.width - (40 * Appearance.scaleFactor)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    ConnectionWidget {}

                    Item {
                        Layout.fillWidth: true
                        Layout.topMargin: 5 * Appearance.scaleFactor
                        Layout.alignment: Qt.AlignHCenter

                        BrightnessVolumeWidget {
                            anchors.fill: parent
                        }
                    }

                    Item {
                        Layout.topMargin: 90 * Appearance.scaleFactor
                        Layout.leftMargin: 14  * Appearance.scaleFactor

                        MediaCardWidget {
                            Layout.preferredWidth: parent.width - (10 * Appearance.scaleFactor)
                        }
                    }

                    CalendarWidget {
                        Layout.topMargin: 190 * Appearance.scaleFactor
                        Layout.bottomMargin: 20 * Appearance.scaleFactor
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: parent.width - (5 * Appearance.scaleFactor)
                    }
                }
            }
        }
    }

    PropertyAnimation {
        id: anim
        target: popup
        property: "contentX"
        duration: 400
        easing.type: Easing.InOutCirc

        onRunningChanged: popup.isAnimating = running
        onStopped: if (contentX >= width) popup.visible = false
    }
}
