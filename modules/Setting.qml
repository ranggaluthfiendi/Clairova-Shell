//@pragma UseQApplication

import qs.config
import qs.utils
import qs.widgets.setting

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PopupWindow {
    id: settingPopup
    color: "transparent"
    implicitHeight: wrapper.height

    property real contentY: -wrapper.height
    property bool isAnimating: false
    property bool animatingToHide: false
    property bool isTopBar: true

    function show() {
        if (settingPopup.visible || isAnimating) return
        settingPopup.visible = true

        contentY = isTopBar ? -wrapper.height : wrapper.height
        anim.from = contentY
        anim.to = 0
        animatingToHide = false
        anim.start()
    }

    function hide() {
        if (!settingPopup.visible || isAnimating) return
        animatingToHide = true
        anim.from = wrapper.y
        anim.to = isTopBar ? -wrapper.height : wrapper.height
        anim.start()
    }

    Item {
        id: wrapper
        width: parent.width
        height: 380 * Appearance.scaleFactor
        y: settingPopup.contentY

        Rectangle {
            id: setting
            anchors.fill: parent
            color: Appearance.currentBackground
            radius: 16 * Appearance.scaleFactor

            Flickable {
                id: flick
                anchors.fill: parent
                contentHeight: layout.implicitHeight + 32 * Appearance.scaleFactor
                interactive: true
                clip: true

                ColumnLayout {
                    id: layout
                    width: flick.width
                    spacing: 0
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 12 * Appearance.scaleFactor

                    RowLayout {
                        Layout.topMargin: 16 * Appearance.scaleFactor
                        spacing: 12 * Appearance.scaleFactor

                        Text {
                            text: "tune"
                            font.pixelSize: 24 * Appearance.scaleFactor
                            font.family: Appearance.materialSymbols
                            color: Appearance.white
                        }

                        Text {
                            text: "Settings"
                            font.pixelSize: 24 * Appearance.scaleFactor
                            font.family: Appearance.bitcountFont
                            color: Appearance.white
                        }
                    }

                    TransparentWidget {}

                    PrimaryWidget {}
                    SecondaryWidget{}
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

        onRunningChanged: settingPopup.isAnimating = running

        onStopped: {
            if (animatingToHide) {
                settingPopup.visible = false
                settingPopup.contentY = -wrapper.height
            } else {
                settingPopup.contentY = wrapper.y
            }
        }
    }
}
