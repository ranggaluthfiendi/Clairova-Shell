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
        spacing: 10 * Appearance.scaleFactor

        // === Bluetooth Tile ===
        Rectangle {
            id: bluetoothTile
            Layout.fillWidth: true
            Layout.preferredHeight: 60 * Appearance.scaleFactor
            radius: 30 * Appearance.scaleFactor

            property bool isActive: bluetoothUtils.enabled
            color: isActive ? Appearance.primary : Appearance.background

            MouseArea {
                anchors.fill: parent
                onClicked: bluetoothUtils.toggleBluetooth()
                cursorShape: Qt.PointingHandCursor
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15 * Appearance.scaleFactor
                spacing: 18 * Appearance.scaleFactor

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

        // === WiFi Tile ===
        Rectangle {
            id: wifiTile
            Layout.fillWidth: true
            Layout.preferredHeight: 60 * Appearance.scaleFactor
            radius: 30 * Appearance.scaleFactor

            property bool isActive: wifiUtils.enabled
            color: isActive ? Appearance.primary : Appearance.background

            MouseArea {
                anchors.fill: parent
                onClicked: wifiUtils.toggle()
                cursorShape: Qt.PointingHandCursor
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15 * Appearance.scaleFactor
                spacing: 18 * Appearance.scaleFactor

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