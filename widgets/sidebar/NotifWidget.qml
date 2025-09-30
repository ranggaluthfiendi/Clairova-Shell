import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config

Item {
    id: notifWidget
    Layout.leftMargin: 2 * Appearance.scaleFactor
    property real scaleFactor: Appearance.scaleFactor
    property bool toggled: false

    signal requestNotifToggle()

    function setToggled(val) {
        if (toggled !== val) {
            toggled = val
        }
    }

    width: 28 * scaleFactor
    height: 28 * scaleFactor

    MouseArea {
        id: clickArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: {
            toggled = !toggled
            requestNotifToggle()
        }

        onEntered: scaleLoop.start()
        onExited: {
            scaleLoop.stop()
            iconText.scale = 1.0
        }
    }

    Timer {
        id: scaleLoop
        interval: 400
        repeat: true
        running: false
        onTriggered: {
            iconText.scale = (iconText.scale > 1.0) ? 1.0 : 1.1
        }
    }

    Text {
        id: iconText
        anchors.centerIn: parent
        font.family: Appearance.materialSymbols
        font.pixelSize: 22 * scaleFactor
        text: "notifications"
        color: Appearance.white
        scale: 1.0

        transform: Scale {
            origin.x: iconText.width / 2
            origin.y: iconText.height / 2
            xScale: iconText.scale
            yScale: iconText.scale
        }

        Behavior on scale {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
    }
}
