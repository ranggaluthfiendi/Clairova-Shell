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
    property var currentOpenMenu: null
    property var hoveredItem: null

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
                width: 28 * Appearance.scaleFactor
                height: 28 * Appearance.scaleFactor
                radius: 6 * Appearance.scaleFactor

                property bool hovered: false
                property bool pressed: false
                property bool active: customMenu.visible // aktif saat popup terbuka

                // Background tetap nyala kalau aktif
                color: active
                    ? Qt.rgba(Appearance.background.r, Appearance.background.g, Appearance.background.b, 0.6)
                    : pressed
                        ? Qt.rgba(Appearance.color.r, Appearance.color.g, Appearance.color.b, 0.8)
                        : hovered
                            ? Qt.rgba(Appearance.background.r, Appearance.background.g, Appearance.background.b, 0.4)
                            : "transparent"

                border.color: active ? Appearance.white : hovered ? Appearance.white : "transparent"

                Behavior on color {
                    ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
                }

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

                    // Animasi denyut (loop)
                    SequentialAnimation {
                        id: pulseAnim
                        running: parent.hovered || parent.active
                        loops: Animation.Infinite
                        NumberAnimation { target: icon; property: "scale"; from: 1.0; to: 1.1; duration: 400; easing.type: Easing.InOutQuad }
                        NumberAnimation { target: icon; property: "scale"; from: 1.1; to: 1.0; duration: 400; easing.type: Easing.InOutQuad }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onEntered: {
                        parent.hovered = true
                        root.hoveredItem = parent
                        if (!pulseAnim.running)
                            pulseAnim.start()
                    }

                    onExited: {
                        parent.hovered = false
                        if (root.hoveredItem === parent)
                            root.hoveredItem = null
                        if (!parent.active) {
                            pulseAnim.stop()
                            icon.scale = 1.0
                        }
                    }

                    onPressed: parent.pressed = true
                    onReleased: parent.pressed = false

                    onClicked: {
                        if (root.currentOpenMenu && root.currentOpenMenu !== customMenu)
                            root.currentOpenMenu.visible = false
                        customMenu.visible = !customMenu.visible
                        root.currentOpenMenu = customMenu.visible ? customMenu : null
                    }
                }

                QsMenuOpener {
                    id: opener
                    menu: modelData.menu
                }

                PopupWindow {
                    id: customMenu
                    visible: false
                    color: "transparent"
                    width: 180 * Appearance.scaleFactor
                    height: contentCol.implicitHeight + (24 * Appearance.scaleFactor)
                    anchor.item: icon
                    anchor.edges: root.edges
                    anchor.gravity: root.gravity

                    onVisibleChanged: {
                        if (visible) {
                            pulseAnim.start()
                        } else {
                            pulseAnim.stop()
                            icon.scale = 1.0
                        }

                        if (!visible && root.currentOpenMenu === this)
                            root.currentOpenMenu = null
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 8 * Appearance.scaleFactor
                        color: Appearance.currentBackground
                        clip: true
                        anchors.topMargin: 18 * Appearance.scaleFactor

                        Column {
                            id: contentCol
                            width: parent.width
                            spacing: 2
                            padding: 4

                            Repeater {
                                model: opener.children
                                delegate: Item {
                                    required property QsMenuEntry modelData
                                    width: parent.width
                                    height: modelData.isSeparator ? 8 : 26

                                    Rectangle {
                                        visible: modelData.isSeparator
                                        width: parent.width - 10
                                        height: 1
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        color: "#444"
                                    }

                                    Rectangle {
                                        visible: !modelData.isSeparator
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.rightMargin: 8
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        color: ma.containsMouse ? "#333" : "transparent"
                                        radius: 5

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            anchors.leftMargin: 10
                                            text: modelData.text
                                            color: modelData.enabled ? "white" : "#666"
                                        }

                                        MouseArea {
                                            id: ma
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            enabled: modelData.enabled
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                modelData.triggered()
                                                customMenu.visible = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
