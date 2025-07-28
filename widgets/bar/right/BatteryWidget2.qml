import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.utils
import qs.config
import Quickshell

Item {
    id: batteryWrapper
    width: 32 * Appearance.scaleFactor
    height: 32 * Appearance.scaleFactor

    BatteryUtils { id: batteryUtils }

    property int batteryLevel: batteryUtils.batteryPercent
    property bool isCharging: batteryUtils.isCharging
    property bool toggled: false

    Item {
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        rotation: -90
        transformOrigin: Item.Center

        Text {
            id: chargingIcon
            visible: isCharging
            anchors.centerIn: parent
            font.family: Appearance.materialSymbols
            font.pixelSize: 8 * Appearance.scaleFactor
            text: "bolt"
            color: "white"
            z: 2
        }

        Text {
            id: icon
            anchors.centerIn: parent
            font.family: Appearance.materialSymbols
            font.pixelSize: 32 * Appearance.scaleFactor
            text: "battery_0_bar"
            color: Appearance.white
            z: 1
        }

        Rectangle {
            id: fillBar
            width: 10 * Appearance.scaleFactor
            height: (icon.height - 17 * Appearance.scaleFactor) * (batteryLevel / 100)
            anchors {
                bottom: icon.bottom
                bottomMargin: 6 * Appearance.scaleFactor
                horizontalCenter: icon.horizontalCenter
            }
            radius: 2
            color: batteryLevel <= 30 ? "#ff5555" : Appearance.primary
            z: 0
        }
    }
}
