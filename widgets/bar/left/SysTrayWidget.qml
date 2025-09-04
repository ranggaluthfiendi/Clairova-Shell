pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray

import qs.config

Item {
    id: root
    Layout.leftMargin: 5 * Appearance.scaleFactor
    property var edges: Edges.Bottom | Edges.Left
    property var gravity: Edges.Bottom

    visible: SystemTray.items.values.length > 0
    implicitHeight: visible ? column.implicitHeight : 0
    implicitWidth: visible ? column.implicitWidth : 0

    RowLayout {
        id: column
        spacing: 4 * Appearance.scaleFactor

        Repeater {
            id: trayRepeater
            model: SystemTray.items.values

            Rectangle {
                required property SystemTrayItem modelData
                width: 21 * Appearance.scaleFactor
                height: 24 * Appearance.scaleFactor
                color: "transparent"

                Image {
                    id: icon
                    anchors.centerIn: parent
                    source: modelData.icon
                    width: 16 * Appearance.scaleFactor
                    height: 16 * Appearance.scaleFactor
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    scale: 1.0

                    transform: Scale {
                        origin.x: icon.width / 2
                        origin.y: icon.height / 2
                        xScale: icon.scale
                        yScale: icon.scale
                    }

                    Behavior on scale {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    Timer {
                        id: iconScaleLoop
                        interval: 400
                        repeat: true
                        running: false
                        onTriggered: {
                            icon.scale = (icon.scale > 1.0) ? 1.0 : 1.1
                        }
                    }

                    onEntered: iconScaleLoop.start()
                    onExited: {
                        iconScaleLoop.stop()
                        icon.scale = 1.0
                    }

                    onClicked: {
                        if (!menu.visible) menu.open()
                        else menu.close()
                    }
                }

                QsMenuAnchor {
                    id: menu
                    anchor.item: icon
                    anchor.edges: root.edges
                    anchor.gravity: root.gravity
                    anchor.rect.width: icon.implicitWidth
                    anchor.rect.height: 30 * Appearance.scaleFactor
                    menu: modelData.menu
                }
            }
        }
    }
}
