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

    Rectangle {
        id: batteryBar
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width * (batteryLevel / 100)
        radius: height / 2
        color: Appearance.primary
        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }

    Text {
        id: batteryText
        anchors.centerIn: parent
        text: batteryLevel + "%"
        color: Appearance.color
        font.family: Appearance.bitcountFont
        font.pixelSize: 10 * Appearance.scaleFactor
    }

    Connections {
        target: batteryUtils
        function onBatteryPercentChanged() {
            batteryLevel = batteryUtils.batteryPercent;
        }
    }
}
