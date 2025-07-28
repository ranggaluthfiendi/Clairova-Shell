import QtQuick
import qs.config
Item {
    id: root
    property var mediaUtil
    property real cornerRadius: 16

    Canvas {
        id: waveCanvas
        anchors.fill: parent
        z: -1

        property int pointCount: 60
        property real waveHeight: height * 0.80
        property real time: 0
        property color waveColor: Appearance.primary

        property real targetAmplitude: 0
        property real targetSpeed: 0
        property real currentAmplitude: 0
        property real currentSpeed: 0

        property var phaseOffset: []

        Component.onCompleted: {
            for (let i = 0; i <= pointCount; i++) {
                waveCanvas.phaseOffset.push(Math.random() * 2 * Math.PI)
            }
        }

        Timer {
            interval: 16
            running: true
            repeat: true
            onTriggered: {
                if (mediaUtil) {
                    if (mediaUtil.isPlaying) {
                        waveCanvas.targetAmplitude = 3
                        waveCanvas.targetSpeed = 0.05
                    } else if (mediaUtil.position > 0) {
                        waveCanvas.targetAmplitude = 2
                        waveCanvas.targetSpeed = 0.01
                    } else {
                        waveCanvas.targetAmplitude = 0
                        waveCanvas.targetSpeed = 0
                    }

                    waveCanvas.currentAmplitude += (waveCanvas.targetAmplitude - waveCanvas.currentAmplitude) * 0.08
                    waveCanvas.currentSpeed += (waveCanvas.targetSpeed - waveCanvas.currentSpeed) * 0.08

                    waveCanvas.time += waveCanvas.currentSpeed
                    waveCanvas.requestPaint()
                }
            }
        }

        onPaint: {
            const ctx = getContext("2d")
            const w = width
            const h = height
            const r = root.cornerRadius

            ctx.clearRect(0, 0, w, h)

            ctx.beginPath()
            ctx.moveTo(0, 0)
            ctx.lineTo(0, h - r)
            ctx.quadraticCurveTo(0, h, r, h)
            ctx.lineTo(w - r, h)
            ctx.quadraticCurveTo(w, h, w, h - r)
            ctx.lineTo(w, 0)
            ctx.closePath()
            ctx.clip()

            ctx.beginPath()
            ctx.moveTo(0, h)

            for (let i = 0; i <= pointCount; i++) {
                const x = i * (w / pointCount)
                const phase = time * 2 + i * 0.4 + (phaseOffset[i] || 0)
                const y = h - (Math.sin(phase) * currentAmplitude + waveHeight)
                ctx.lineTo(x, y)
            }

            ctx.lineTo(w, h)
            ctx.closePath()

            ctx.fillStyle = waveColor
            ctx.shadowBlur = 10
            ctx.fill()
        }
    }
}
