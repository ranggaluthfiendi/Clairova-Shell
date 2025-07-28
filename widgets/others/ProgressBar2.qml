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
            color: Appearance.color

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Rectangle {
                id: head
                width: 10 * scaleFactor
                height: 20 * scaleFactor
                radius: 6 * scaleFactor
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                visible: progress > 0
                color: Appearance.primary
                border.color: Appearance.background
                border.width: 2
            }

            Canvas {
                id: waveCanvas
                anchors.fill: parent
                z: 2

                property color waveColor: Appearance.primary
                property int pointCount: 50
                property real baseAmplitude: 3 * scaleFactor
                property real currentAmplitude: 0
                property real waveLength: 25 * scaleFactor
                property real speed: 0.05
                property real time: 0
                property var phaseOffset: []
                property real targetAmplitude: 0

                Component.onCompleted: {
                    for (let i = 0; i <= pointCount; i++) {
                        phaseOffset.push(Math.random() * 2 * Math.PI)
                    }
                }

                Timer {
                    interval: 16
                    running: true
                    repeat: true
                    onTriggered: {
                        waveCanvas.targetAmplitude = root.isPlaying ? waveCanvas.baseAmplitude : 0
                        waveCanvas.currentAmplitude += (waveCanvas.targetAmplitude - waveCanvas.currentAmplitude) * 0.15
                        waveCanvas.time += waveCanvas.speed
                        waveCanvas.requestPaint()
                    }
                }

                onPaint: {
                    const ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    ctx.beginPath()
                    ctx.lineWidth = 1.5
                    ctx.strokeStyle = waveColor

                    for (let i = 0; i <= pointCount; i++) {
                        const x = i * (width / pointCount)
                        const phase = waveCanvas.time * 10 + i + phaseOffset[i]
                        const y = height / 2 + Math.sin(phase) * waveCanvas.currentAmplitude

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
