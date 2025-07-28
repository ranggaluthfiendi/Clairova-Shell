import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config
import qs.utils
import Quickshell

Item {
    id: indicator
    width: 120 * Appearance.scaleFactor
    z: 999
    visible: false
    opacity: 0

    property int hideDelay: 3000
    property string currentMode: "volume"
    property int currentValue: 0
    property bool isMuted: false
    property bool persistMuted: false

    Timer {
        id: hideTimer
        interval: hideDelay
        repeat: false
        onTriggered: fadeOut()
    }

    Timer {
        id: fallbackToMute
        interval: 1200
        repeat: false
        onTriggered: {
            if (persistMuted) {
                currentMode = "volume"
                currentValue = util.volume
                isMuted = true
                show()
            }
        }
    }

    IndicatorUtil {
        id: util

        onVolumeUpdated: (vol, mut) => {
            if (mut) {
                persistMuted = true
                currentMode = "volume"
                currentValue = vol
                isMuted = true
                show()
            } else {
                if (persistMuted) {
                    persistMuted = false
                }
                currentMode = "volume"
                currentValue = vol
                isMuted = false
                show()
            }
        }

        onBrightnessUpdated: (val) => {
            currentMode = "brightness"
            currentValue = val
            show()

            if (persistMuted) {
                fallbackToMute.restart()
            }
        }
    }

    function show() {
        updateUI()
        visible = true
        fadeIn()
        hideTimer.restart()
    }

    function updateUI() {
        if (currentMode === "volume") {
            icon.text = isMuted ? "volume_off" : (currentValue >= 50 ? "volume_up" : "volume_down")
            label.text = isMuted ? "Muted" : `${currentValue}%`
        } else if (currentMode === "brightness") {
            icon.text = "sunny"
            label.text = `${currentValue}%`
        }
    }

    function fadeIn() {
        animation.stop()
        animation.from = opacity
        animation.to = 1
        animation.start()
    }

    function fadeOut() {
        if (persistMuted) {
            return
        }
        animation.stop()
        animation.from = opacity
        animation.to = 0
        animation.start()
        hideTimer.stop()
    }

    NumberAnimation {
        id: animation
        target: indicator
        property: "opacity"
        duration: 450
        onFinished: {
            if (opacity === 0) indicator.visible = false
        }
    }


    RowLayout {
        anchors.centerIn: parent
        spacing: 8 * Appearance.scaleFactor

        Text {
            id: icon
            font.family: Appearance.materialSymbols
            font.pixelSize: 20 * Appearance.scaleFactor
            color: Appearance.white
        }

        Text {
            id: label
            font.pixelSize: 12 * Appearance.scaleFactor
            color: Appearance.white
            font.family: Appearance.bitcountFont
        }
    }

}
