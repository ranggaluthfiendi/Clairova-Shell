import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import qs.utils
import qs.config
import Quickshell.Services.Mpris

Item {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 6 * scaleFactor
    implicitWidth: 150 * scaleFactor
    implicitHeight: 6 * scaleFactor

    property MprisPlayer currentPlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

    property string playbackState: currentPlayer ? currentPlayer.playbackState : ""
    property bool isPlaying: currentPlayer ? currentPlayer.playbackState === MprisPlaybackState.Playing : false


    property real scaleFactor: Appearance.scaleFactor
    property color backgroundColor: Appearance.background

    signal onSeek(real value)

    MediaUtil {
        id: mediaUtil
    }

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: backgroundColor

        Rectangle {
            id: fillWrapper
            width: currentPlayer && currentPlayer.length > 0 ? (currentPlayer.position / currentPlayer.length) * track.width : 0

            height: track.height
            color: "transparent"
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 0
                radius: 12 * scaleFactor
                samples: 30
                color: "white"
            }

            Rectangle {
                id: fill
                anchors.fill: parent
                radius: height / 2
                color: "white"

                Behavior on width {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        MouseArea {
            id: touch
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            property bool isDragging: false

            onPressed: (mouse) => {
                isDragging = true
                update(mouse.x)
            }

            onPositionChanged: (mouse) => {
                if (isDragging)
                    update(mouse.x)
            }

            onReleased: (mouse) => {
                isDragging = false
                let value = Math.max(0, Math.min(1, mouse.x / width))
                mediaUtil.setPosition(value)
                root.onSeek(value)
            }

            function update(x) {
                let ratio = Math.max(0, Math.min(1, x / width))
                mediaUtil.progress = ratio
            }
        }
    }
}
