import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.widgets.bar.right

Rectangle {
    id: systemWrapper
    radius: 6 * Appearance.scaleFactor
    color: isInBar
           ? (pressed ? Appearance.background : "transparent")
           : "transparent"

    property bool isInBar: true   // default true, kalau di screen set jadi false
    property bool pressed: false

    Layout.fillHeight: true
    Layout.minimumWidth: iconRow.implicitWidth + 8 * Appearance.scaleFactor
    Layout.maximumWidth: iconRow.implicitWidth + 8 * Appearance.scaleFactor

    signal requestSidebarToggle()

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    RowLayout {
        id: iconRow
        anchors.fill: parent
        anchors.rightMargin: 12 * Appearance.scaleFactor
        VolumeWidget {}
        BluetoothWidget {}
        WifiWidget {}
        BatteryWidget {}
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: systemWrapper.isInBar ? Qt.PointingHandCursor : Qt.ArrowCursor
        onPressed: if (systemWrapper.isInBar) systemWrapper.pressed = true
        onReleased: {
            if (systemWrapper.isInBar) systemWrapper.pressed = false
            systemWrapper.requestSidebarToggle()
        }
    }
}
