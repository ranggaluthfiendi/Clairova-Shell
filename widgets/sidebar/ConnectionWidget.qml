import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config
import qs.utils

Item {
    id: connectionRow
    Layout.fillWidth: true
    Layout.preferredHeight: 80 * Appearance.scaleFactor

    WifiUtils { id: wifiUtils }
    BluetoothUtils { id: bluetoothUtils }

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.margins: 10 * Appearance.scaleFactor
        spacing: 8 * Appearance.scaleFactor

        // Bluetooth Tile
        Rectangle {
            id: bluetoothTile
            Layout.fillWidth: true
            Layout.preferredHeight: 60 * Appearance.scaleFactor
            radius: 30 * Appearance.scaleFactor
            property bool isActive: bluetoothUtils.enabled
            scale: 1.0
            color: isActive ? Appearance.primary : Appearance.background

            Behavior on scale {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: bluetoothUtils.toggleBluetooth()
                onEntered: scaleLoop.start()
                onExited: {
                    scaleLoop.stop()
                    bluetoothTile.scale = 1.0
                }
            }

            Timer {
                id: scaleLoop
                interval: 400
                repeat: true
                running: false
                onTriggered: {
                    bluetoothTile.scale = (bluetoothTile.scale > 1.0) ? 1.0 : 1.05
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15 * Appearance.scaleFactor
                spacing: 10 * Appearance.scaleFactor

                Label {
                    text: bluetoothUtils.icon
                    font.family: Appearance.materialSymbols
                    font.pixelSize: 24 * Appearance.scaleFactor
                    color: bluetoothTile.isActive ? Appearance.color : Appearance.white
                    verticalAlignment: Text.AlignVCenter
                }

                ColumnLayout {
                    spacing: 2 * Appearance.scaleFactor
                    Layout.fillWidth: true

                    Label {
                        text: bluetoothUtils.connected && bluetoothUtils.connectedDeviceName
                              ? bluetoothUtils.connectedDeviceName
                              : "Bluetooth"
                        font.family: Appearance.bitcountFont
                        font.pixelSize: Appearance.normal * Appearance.scaleFactor
                        color: bluetoothTile.isActive ? Appearance.color : Appearance.white
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Label {
                        text: bluetoothUtils.connected
                              ? "Connected"
                              : bluetoothUtils.enabled ? "Enabled" : "Disabled"
                        font.family: Appearance.defaultFont
                        font.pixelSize: Appearance.small * Appearance.scaleFactor
                        color: bluetoothTile.isActive ? Appearance.color : Appearance.white
                        opacity: 0.7
                    }
                }
            }
        }

        // Wi-Fi Tile
        Rectangle {
            id: wifiTile
            Layout.fillWidth: true
            Layout.preferredHeight: 60 * Appearance.scaleFactor
            radius: 30 * Appearance.scaleFactor
            property bool isActive: wifiUtils.enabled
            scale: 1.0
            color: isActive ? Appearance.primary : Appearance.background

            Behavior on scale {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: wifiUtils.toggle()
                onEntered: scaleLoopWifi.start()
                onExited: {
                    scaleLoopWifi.stop()
                    wifiTile.scale = 1.0
                }
            }

            Timer {
                id: scaleLoopWifi
                interval: 400
                repeat: true
                running: false
                onTriggered: {
                    wifiTile.scale = (wifiTile.scale > 1.0) ? 1.0 : 1.05
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15 * Appearance.scaleFactor
                spacing: 10 * Appearance.scaleFactor

                Label {
                    text: {
                        if (wifiUtils.signalStrength === -2) return "signal_wifi_off"
                        if (wifiUtils.signalStrength === -1 || wifiUtils.signalStrength < 10) return "signal_wifi_0_bar"
                        if (wifiUtils.signalStrength < 40) return "network_wifi_1_bar"
                        if (wifiUtils.signalStrength < 60) return "network_wifi_2_bar"
                        if (wifiUtils.signalStrength < 80) return "network_wifi"
                        return "signal_wifi_4_bar"
                    }
                    font.family: Appearance.materialSymbols
                    font.pixelSize: 24 * Appearance.scaleFactor
                    color: wifiTile.isActive ? Appearance.color : Appearance.white
                    verticalAlignment: Text.AlignVCenter
                }

                ColumnLayout {
                    spacing: 2 * Appearance.scaleFactor
                    Layout.fillWidth: true

                    Label {
                        text: wifiUtils.networkName || "Wi-Fi"
                        font.family: Appearance.bitcountFont
                        font.pixelSize: Appearance.normal * Appearance.scaleFactor
                        color: wifiTile.isActive ? Appearance.color : Appearance.white
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Label {
                        text: wifiTile.isActive ? "Enabled" : "Disabled"
                        font.family: Appearance.defaultFont
                        font.pixelSize: Appearance.small * Appearance.scaleFactor
                        color: wifiTile.isActive ? Appearance.color : Appearance.white
                        opacity: 0.7
                    }
                }
            }
        }
    }
}
