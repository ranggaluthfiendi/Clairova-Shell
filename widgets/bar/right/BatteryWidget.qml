import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.utils
import qs.config
import Quickshell

Item {
    id: batteryWrapper
    signal requestSidebarToggle()

    width: 80 * Appearance.scaleFactor
    height: 20 * Appearance.scaleFactor

    BatteryUtils { id: batteryUtils }

    property int batteryLevel: batteryUtils.batteryPercent
    property bool isCharging: batteryUtils.isCharging
    property bool toggled: false
    property bool isFull: batteryLevel >= 100

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            batteryWrapper.toggled = !batteryWrapper.toggled
            batteryWrapper.requestSidebarToggle()
        }
    }

    Rectangle {
        id: batteryBackground
        anchors.fill: parent
        radius: height / 2
        color: Appearance.background
    }

    Canvas {
        id: batteryCanvas
        anchors.fill: parent
        property real level: batteryLevel
        property real r: height / 2
        property int pointCount: 20
        property real time: 0
        property real amplitude: batteryLevel < 99 ? 3 : 0
        property real speed: batteryLevel < 99 ? 0.05 : 0
        property var phaseOffset: []
        property real blinkingOpacity: 1
        opacity: isFull ? blinkingOpacity : 1

        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            const w = width * level / 100
            const h = height
            const r = batteryCanvas.r
            const a = amplitude
            const p = pointCount

            ctx.beginPath()
            ctx.moveTo(r, 0)
            ctx.quadraticCurveTo(0, 0, 0, r)
            ctx.lineTo(0, h - r)
            ctx.quadraticCurveTo(0, h, r, h)
            ctx.lineTo(w - (level < 99 ? 0 : r), h)

            if (level >= 99) {
                ctx.quadraticCurveTo(w, h, w, h - r)
                ctx.lineTo(w, r)
                ctx.quadraticCurveTo(w, 0, w - r, 0)
                ctx.lineTo(r, 0)
            } else {
                const yStep = h / p
                let prevX = w
                let prevY = h

                for (let i = 1; i <= p; i++) {
                    const y = h - i * yStep
                    const phase = time * 2 + i * 0.3 + (phaseOffset[i] || 0)
                    const x = w + Math.sin(phase) * a
                    const midY = (prevY + y) / 2
                    const midX = (prevX + x) / 2
                    ctx.quadraticCurveTo(prevX, prevY, midX, midY)
                    prevX = x
                    prevY = y
                }

                ctx.lineTo(w, 0)
                ctx.lineTo(r, 0)
            }

            ctx.closePath()
            ctx.fillStyle =  Qt.rgba(Appearance.primary.r, Appearance.primary.g, Appearance.primary.b, 0.5)
            ctx.fill()
        }


        Timer {
            interval: 16
            running: batteryLevel <= 99
            repeat: true
            onTriggered: {
                batteryCanvas.time += batteryCanvas.speed
                batteryCanvas.requestPaint()
            }
        }

        Component.onCompleted: {
            for (let i = 0; i <= pointCount; i++)
                phaseOffset.push(Math.random() * Math.PI * 2)
        }

        SequentialAnimation on blinkingOpacity {
            running: isFull
            loops: Animation.Infinite
            NumberAnimation { to: 0.4; duration: 1000; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
        }
    }

    Text {
        id: batteryText
        anchors.centerIn: parent
        text: isFull ? "Full" : batteryLevel + "%"
        color: Appearance.white
        font.family: Appearance.bitcountFont
        font.pixelSize: 14 * Appearance.scaleFactor
        opacity: isFull ? blinkingOpacity : 1
    }

    Text {
        visible: isCharging
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 4
        }
        text: "electric_bolt"
        font.family: Appearance.materialSymbols
        color:  Appearance.white
        font.pixelSize: 10 * Appearance.scaleFactor
        z: 2
    }

    Connections {
        target: batteryUtils
        function onBatteryPercentChanged() {
            batteryLevel = batteryUtils.batteryPercent;
        }
        function onIsChargingChanged() {
            isCharging = batteryUtils.isCharging;
        }
    }
    
}
