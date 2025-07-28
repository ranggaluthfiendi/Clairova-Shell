import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.utils
import qs.config
import Quickshell

Item {
    id: batteryWrapper
    signal requestSidebarToggle()

    width: 32 * Appearance.scaleFactor
    height: 32 * Appearance.scaleFactor

    BatteryUtils { id: batteryUtils }


    property int batteryLevel: batteryUtils.batteryPercent
    property bool isCharging: batteryUtils.isCharging
    property bool toggled: false

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            batteryWrapper.toggled = !batteryWrapper.toggled
            batteryWrapper.requestSidebarToggle()
        }
    }

    Canvas {
        id: ring
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d");
            const w = width;
            const h = height;
            const r = Math.min(w, h) / 2 - 2;
            const cx = w / 2;
            const cy = h / 2;

            ctx.clearRect(0, 0, w, h);

            ctx.beginPath();
            ctx.arc(cx, cy, r, 0, 2 * Math.PI);
            ctx.lineWidth = 2;
            ctx.strokeStyle = "#444";
            ctx.stroke();

            const angle = 2 * Math.PI * (batteryLevel / 100);
            ctx.beginPath();
            ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + angle);
            ctx.strokeStyle = batteryLevel <= 30 ? "#ff5555" : Appearance.primary;
            ctx.stroke();
        }

        Connections {
            target: batteryUtils
            function onBatteryPercentChanged() { ring.requestPaint(); }
        }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: batteryLevel
        color: Appearance.white
        font.family: Appearance.bitcountFont
        font.pixelSize: 10 * Appearance.scaleFactor
    }

    Text {
        id: chargingIcon
        visible: isCharging
        anchors.right: label.left
        anchors.rightMargin: 2
        anchors.verticalCenter: label.verticalCenter
        font.family: Appearance.materialSymbols
        font.pixelSize: 10 * Appearance.scaleFactor
        text: "bolt"
        color: "yellow"
    }
}
