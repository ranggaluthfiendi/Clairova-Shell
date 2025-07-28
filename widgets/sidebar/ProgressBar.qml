import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import qs.utils
import qs.config

Item {
    id: root
    width: 150 * scaleFactor
    height: 24 * scaleFactor

    property real scaleFactor: Appearance.scaleFactor
    property alias progress: mediaUtil.progress
    property alias isPlaying: mediaUtil.isPlaying
    property color backgroundColor: Appearance.color

    signal onSeek(real value)

    MediaUtil {
        id: mediaUtil
    }

    Rectangle {
        id: track
        anchors.fill: parent
        radius: 30 * scaleFactor
        color: Appearance.background

        Rectangle {
            id: fillWrapper
            width: progress * track.width
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
                radius: 30 * scaleFactor
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
