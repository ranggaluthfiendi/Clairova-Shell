import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.utils
import qs.config

Item {
    id: root
    width: 200 * scaleFactor
    height: 24 * scaleFactor

    property real scaleFactor: 1.0
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
        radius: height / 2
        color: Appearance.background

        Rectangle {
            id: fill
            width: progress * track.width
            height: track.height
            radius: track.radius
            color: backgroundColor

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Rectangle {
                id: head
                width: 10 * scaleFactor
                height: 36 * scaleFactor
                radius: 6 * scaleFactor
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                visible: progress > 0
                color: Appearance.primary
                border.color: Appearance.primary
                border.width: 2
            }

            Canvas {
                id: waveCanvas
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right

                property color waveColor: Appearance.primary
                property int pointCount: 100
                property real baseAmplitude: 8 * scaleFactor
                property real currentAmplitude: 0
                property real waveLength: 30 * scaleFactor
                property real speed: 0.015
                property real time: 0
                property real targetAmplitude: 0

                Component.onCompleted: waveCanvas.requestPaint()

                Timer {
                    interval: 16
                    running: true
                    repeat: true
                    onTriggered: {
                        waveCanvas.targetAmplitude = root.isPlaying ? waveCanvas.baseAmplitude : 0
                        waveCanvas.currentAmplitude += (waveCanvas.targetAmplitude - waveCanvas.currentAmplitude) * 0.08
                        waveCanvas.time += waveCanvas.speed
                        waveCanvas.requestPaint()
                    }
                }

                onPaint: {
                    const ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    ctx.beginPath()
                    ctx.lineWidth = 12 * scaleFactor
                    ctx.lineCap = "round"
                    ctx.strokeStyle = waveColor

                    ctx.lineWidth = 4 * scaleFactor
                    ctx.lineCap = "round"
                    
                    const maxX = fill.width - root.progress
                    for (let i = 0; i <= pointCount; i++) {
                        const x = i * (width / pointCount)
                        if (x > maxX) break
                        const wavePhase = waveCanvas.time * 3 + i * 0.3
                        const y = height / 2 + Math.sin(wavePhase) * waveCanvas.currentAmplitude

                        if (i === 0)
                            ctx.moveTo(x, y)
                        else
                            ctx.lineTo(x, y)
                    }

                    ctx.stroke()
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
