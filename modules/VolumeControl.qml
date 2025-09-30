import qs.config
import qs.utils
import qs.widgets.volume
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

PopupWindow {
    id: volumePopup
    color: "transparent"
    implicitHeight: wrapper.height

    property real contentY: -wrapper.height
    property bool isAnimating: false
    property bool animatingToHide: false
    property bool isTopBar: true

    function show() {
        if (volumePopup.visible || isAnimating) return
        volumePopup.visible = true

        contentY = isTopBar ? -wrapper.height : wrapper.height
        anim.from = contentY
        anim.to = 0
        animatingToHide = false
        anim.start()
    }

    function hide() {
        if (!volumePopup.visible || isAnimating) return
        animatingToHide = true
        anim.from = wrapper.y
        anim.to = isTopBar ? -wrapper.height : wrapper.height
        anim.start()
    }

    PwNodeLinkTracker {
        id: outputTracker
        node: Pipewire.defaultAudioSink
    }

    PwNodeLinkTracker {
        id: inputTracker
        node: Pipewire.defaultAudioSource
    }

    Item {
        id: wrapper
        width: parent.width
        height: 320 * Appearance.scaleFactor
        y: volumePopup.contentY

        Rectangle {
            id: volume
            anchors.fill: parent
            color: Appearance.currentBackground
            radius: 16 * Appearance.scaleFactor

            Flickable {
                id: flick
                anchors.fill: parent
                contentHeight: layout.implicitHeight + 32 * Appearance.scaleFactor
                interactive: true
                clip: true

                ScrollBar.vertical: ScrollBar {
                    policy: Qt.ScrollBarAsNeeded
                }

                ColumnLayout {
                    id: layout
                    width: flick.width
                    spacing: 0
                    anchors.margins: 12 * Appearance.scaleFactor
                    anchors.left: parent.left
                    anchors.right: parent.right

                    RowLayout {
                        Layout.topMargin: 10 * Appearance.scaleFactor
                        spacing: 10 * Appearance.scaleFactor

                        Text {
                            text: "equalizer"
                            font.pixelSize: 24 * Appearance.scaleFactor
                            font.family: Appearance.materialSymbols
                            color: Appearance.white
                        }

                        Text {
                            text: "Volume Control"
                            font.pixelSize: 24 * Appearance.scaleFactor
                            font.family: Appearance.bitcountFont
                            color: Appearance.white
                        }
                    }

                    MixerOutputWidget{
                        node: Pipewire.defaultAudioSink
                    }

                    MixerInputWidget {
                        node: Pipewire.defaultAudioSource
                    }

                    Repeater {
                        model: outputTracker.linkGroups

                        MixerOutputWidget {
                            required property PwLinkGroup modelData
                            node: modelData.source
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

        onRunningChanged: volumePopup.isAnimating = running

        onStopped: {
            if (animatingToHide) {
                volumePopup.visible = false
                volumePopup.contentY = -wrapper.height
            } else {
                volumePopup.contentY = wrapper.y
            }
        }
    }
}
