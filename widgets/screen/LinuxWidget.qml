import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config
import qs.utils

Item {
    id: linuxScreen

    width: parent ? parent.width : 800
    height: parent ? parent.height : 600

    Rectangle {
        id: linuxContainer
        width: 300 * Appearance.scaleFactor
        height: 120 * Appearance.scaleFactor
        color: "transparent"

        x: 0
        y: 0

        // --------------------------------------------------
        // Set defaultX/Y terlebih dahulu, lalu load posisi
        Component.onCompleted: {
            Qt.callLater(() => {
                linuxUtil.defaultX = mainWindow.width - linuxContainer.width
                linuxUtil.defaultY = mainWindow.height - linuxContainer.height
                linuxUtil.loadPosition()
            })
        }

        // --------------------------------------------------
        // Update posisi ketika posisi dari file JSON sudah siap
        Connections {
            target: linuxUtil
            onPositionLoaded: {
                linuxContainer.x = x
                linuxContainer.y = y
            }
        }

        // --------------------------------------------------
        Column {
            anchors.centerIn: parent
            spacing: 4 * Appearance.scaleFactor

            Text {
                text: "Activate Linux"
                font.pixelSize: 24 * Appearance.scaleFactor
                font.family: Appearance.defaultFont
                color: Appearance.white
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "Go to Quickshell to activate Linux"
                font.pixelSize: 14 * Appearance.scaleFactor
                font.family: Appearance.defaultFont
                color: Appearance.white
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        // --------------------------------------------------
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
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
                linuxUtil.applyPosition(linuxContainer.x, linuxContainer.y, linuxContainer)

                const now = Date.now()
                if (now - lastClickTime < 300) {
                    linuxUtil.resetPosition(linuxContainer) // kirim container agar clamp
                }
                lastClickTime = now
            }

            onPositionChanged: function(mouse) {
                if (dragging) {
                    let newX = linuxContainer.x + mouse.x - offsetX
                    let newY = linuxContainer.y + mouse.y - offsetY

                    const maxX = mainWindow.width - linuxContainer.width
                    const maxY = mainWindow.height - linuxContainer.height
                    linuxContainer.x = Math.max(0, Math.min(newX, maxX))
                    linuxContainer.y = Math.max(0, Math.min(newY, maxY))
                }
            }
        }
    }

    // --------------------------------------------------
    LinuxUtil {
        id: linuxUtil
        defaultX: 0
        defaultY: 0
    }
}
