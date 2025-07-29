import qs.utils
import qs.config

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: bluetoothWidget
    signal requestSidebarToggle()

    width: 32 * Appearance.scaleFactor
    height: 32 * Appearance.scaleFactor

    BluetoothUtils { id: bluetoothUtils }

    property string icon: bluetoothUtils.icon ?? "bluetooth_disabled"
    property color baseColor: Appearance.color
    property bool toggled: false

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            bluetoothWidget.toggled = !bluetoothWidget.toggled
            bluetoothWidget.requestSidebarToggle()
        }
    }

    Text {
        anchors.centerIn: parent
        font.family: Appearance.materialSymbols
        font.pixelSize: 20 * Appearance.scaleFactor
        color: Appearance.white
        text: icon
    }

}
