import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.widgets.bar.right

Rectangle {
    id: systemWrapper
    radius: 6 * Appearance.scaleFactor
    color: pressed ? Appearance.background : "transparent"
    Layout.fillHeight: true
    Layout.minimumWidth: iconRow.implicitWidth + 8 * Appearance.scaleFactor
    Layout.maximumWidth: iconRow.implicitWidth + 8 * Appearance.scaleFactor

    signal requestSidebarToggle()

    property bool pressed: false

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    RowLayout {
        id: iconRow
        anchors.fill: parent
        anchors.rightMargin: 12 * Appearance.scaleFactor
        spacing: 6 * Appearance.scaleFactor

        TimeWidget {}
        BluetoothWidget {}
        WifiWidget {}
        BatteryWidget {}
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onPressed: systemWrapper.pressed = true
        cursorShape: Qt.PointingHandCursor
        onReleased: {
            systemWrapper.pressed = false
            systemWrapper.requestSidebarToggle()
        }
    }
}
