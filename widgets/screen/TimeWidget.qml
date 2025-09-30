import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config
import qs.utils

Item {
    id: timeScreen
    Rectangle {
        id: timeContainer
        width: 350 * Appearance.scaleFactor
        height: 140 * Appearance.scaleFactor
        color: "transparent"

        x: 0
        y: 0

        Component.onCompleted: {
            timeUtil.loadPosition()
            timeContainer.x = timeUtil.currentX
            timeContainer.y = timeUtil.currentY
        }

        Connections {
            target: timeUtil
            onPositionLoaded: {
                timeContainer.x = x
                timeContainer.y = y
            }
        }

        Column {
            anchors.centerIn: parent

            Text {
                id: timeLabel
                text: Qt.formatTime(new Date(), "hh:mm")
                font.pixelSize: 86 * Appearance.scaleFactor
                font.family: Appearance.bitcountFont
                color: Appearance.white
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                id: dateLabel
                text: Qt.formatDate(new Date(), "ddd dd • MMMM • yyyy").toUpperCase()
                font.pixelSize: 24 * Appearance.scaleFactor
                font.family: Appearance.bitcountFont
                color: Appearance.white
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.OpenHandCursor
            acceptedButtons: Qt.LeftButton

            property real offsetX: 0
            property real offsetY: 0
            property bool dragging: false
            property double lastClickTime: 0

            onPressed: function(mouse) {
                offsetX = mouse.x
                offsetY = mouse.y
                dragging = true
            }

            onReleased: function(mouse) {
                dragging = false
                timeUtil.applyPosition(timeContainer.x, timeContainer.y)

                const now = Date.now()
                if (now - lastClickTime < 300) {
                    timeUtil.resetPosition()
                }
                lastClickTime = now
            }

            onPositionChanged: function(mouse) {
                if (dragging) {
                    let newX = timeContainer.x + mouse.x - offsetX
                    let newY = timeContainer.y + mouse.y - offsetY

                    const maxX = mainWindow.width - timeContainer.width
                    const maxY = mainWindow.height - timeContainer.height
                    timeContainer.x = Math.max(0, Math.min(newX, maxX))
                    timeContainer.y = Math.max(0, Math.min(newY, maxY))
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            timeLabel.text = Qt.formatTime(new Date(), "hh:mm")
            dateLabel.text = Qt.formatDate(new Date(), "ddd dd • MMMM • yyyy").toUpperCase()
        }
    }
    TimePositionUtil { id: timeUtil; defaultX: 0; defaultY: 0 }
}