import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.utils
import qs.config
import Quickshell

Item {
    id: speedWidget
    width: 130 * Appearance.scaleFactor
    height: 32 * Appearance.scaleFactor
    Layout.rightMargin: 30 * Appearance.scaleFactor

    SpeedUtil { id: speedUtil }

    property real animatedDownload: 0
    property real animatedUpload: 0

    Behavior on animatedDownload {
        NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
    }
    Behavior on animatedUpload {
        NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            animatedDownload = speedUtil.downloadSpeed
            animatedUpload = speedUtil.uploadSpeed
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 8 * Appearance.scaleFactor

        RowLayout {
            id: downloadRow
            spacing: 4 * Appearance.scaleFactor

            Text {
                font.family: Appearance.materialSymbols
                font.pixelSize: 14 * Appearance.scaleFactor
                text: "arrow_downward_alt"
                color: Appearance.white
            }

            Text {
                font.pixelSize: 11 * Appearance.scaleFactor
                text: animatedDownload >= 1024
                    ? `${(animatedDownload / 1024).toFixed(1)} MB/s`
                    : `${animatedDownload.toFixed(0)} KB/s`
                color: Appearance.white
                font.family: Appearance.bitcountFont
            }
        }
        
        RowLayout {
            id: uploadRow
            spacing: 4 * Appearance.scaleFactor

            Text {
                font.family: Appearance.materialSymbols
                font.pixelSize: 14 * Appearance.scaleFactor
                text: "arrow_upward_alt"
                color: Appearance.white
            }

            Text {
                font.pixelSize: 11 * Appearance.scaleFactor
                text: animatedUpload >= 1024
                    ? `${(animatedUpload / 1024).toFixed(1)} MB/s`
                    : `${animatedUpload.toFixed(0)} KB/s`
                color: Appearance.white
                font.family: Appearance.bitcountFont
            }
        }
    }
}
