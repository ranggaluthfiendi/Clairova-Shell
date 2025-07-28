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

        onClicked: {
            toggled = !toggled
            requestNotifToggle()
        }
    }

    Text {
        id: iconText
        anchors.centerIn: parent
        font.family: Appearance.materialSymbols
        font.pixelSize: 22 * scaleFactor
        text: "notifications"
        color: Appearance.white
    }
}
