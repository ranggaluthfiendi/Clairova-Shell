import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.utils
import qs.config
import Quickshell

Item {
    id: activeAppWrapper
    implicitWidth: 160 * Appearance.scaleFactor
    implicitHeight: 32 * Appearance.scaleFactor
    clip: true

    property string activeApp: "Rang"
    property string icon: "arrow_right" 

    ActiveApp {
        onAppChanged: activeAppWrapper.activeApp = app
    }

    Rectangle {
        radius: 8 * Appearance.scaleFactor
        color: Appearance.background
        anchors.fill: parent

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8 * Appearance.scaleFactor
            anchors.rightMargin: 12 * Appearance.scaleFactor
            spacing: 4 * Appearance.scaleFactor

            Text {
                text: icon
                font.family: Appearance.materialSymbols
                font.pixelSize: Appearance.extraLarge * Appearance.scaleFactor
                color: Appearance.white
                verticalAlignment: Text.AlignVCenter
            }

            Label {
                text: activeApp
                Layout.fillWidth: true
                font.family: Appearance.defaultFont
                font.pixelSize: Appearance.normal * Appearance.scaleFactor
                color: Appearance.white
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                elide: Text.ElideRight
                maximumLineCount: 1
                clip: true
            }
        }
    }
}
