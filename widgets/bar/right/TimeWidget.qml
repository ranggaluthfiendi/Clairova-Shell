import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.utils
import qs.config
import Quickshell

Item {
    id: timeWrapper
    
    signal requestSidebarToggle()   

    Layout.preferredWidth: 115 * Appearance.scaleFactor
    Layout.preferredHeight: 32 * Appearance.scaleFactor
    Layout.rightMargin: 12 * Appearance.scaleFactor
    Layout.leftMargin: 10 * Appearance.scaleFactor

    property string timeText: "--:--"
    property bool toggled: false

    TimeUtils {
        onTimeChanged: timeWrapper.timeText = time
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true
        // cursorShape: Qt.PointingHandCursor

        onClicked: {
            timeWrapper.toggled = !timeWrapper.toggled
            timeWrapper.requestSidebarToggle()
        }
    }

    Label {
        id: label
        anchors.fill: parent
        anchors.margins: 6 * Appearance.scaleFactor
        font.family: Appearance.bitcountFont
        font.pixelSize: Appearance.normal * Appearance.scaleFactor
        color: Appearance.white
        text: timeText
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}
