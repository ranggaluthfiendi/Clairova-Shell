import qs.utils
import qs.config

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: wifiWidget
    signal requestSidebarToggle()
    Layout.rightMargin: 8 * Appearance.scaleFactor

    width: 32 * Appearance.scaleFactor
    height: 32 * Appearance.scaleFactor

    WifiUtils { id: wifiUtils }

    property int strength: wifiUtils.signalStrength ?? -2
    property bool toggled: false

    Process {
        id: wifiProcess
        command: ["sh", "-c", "setsid nm-connection-editor"]
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            wifiWidget.toggled = !wifiWidget.toggled
            wifiWidget.requestSidebarToggle()
        }
    }

    Text {
        anchors.centerIn: parent
        font.family: Appearance.materialSymbols
        font.pixelSize: 20 * Appearance.scaleFactor
        color: Appearance.white
        text: {
            if (wifiUtils.signalStrength === -2) return "signal_wifi_off"
            if (wifiUtils.signalStrength === -1 || wifiUtils.signalStrength < 10) return "signal_wifi_0_bar"
            if (wifiUtils.signalStrength < 40) return "network_wifi_1_bar"
            if (wifiUtils.signalStrength < 60) return "network_wifi_2_bar"
            if (wifiUtils.signalStrength < 80) return "network_wifi"
            return "signal_wifi_4_bar"
        }
    }
}
