pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.modules
import Quickshell.Hyprland 

Scope {
    id: logout
    property color backgroundColor: Qt.rgba(Appearance.background.r, Appearance.background.g, Appearance.background.b, 0.8)
    property color buttonColor: Appearance.color
    property color buttonHoverColor: Appearance.primary
    default property list<LogoutButton> buttons

    property var panelWindowRef: null

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: w
            visible: false
            property var modelData
            screen: modelData

            Component.onCompleted: logout.panelWindowRef = w

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            color: "transparent"

            contentItem {
                focus: true
                Keys.onPressed: event => {
                    if (event.key == Qt.Key_Escape) w.visible = false
                    else {
                        for (let i = 0; i < buttons.length; i++) {
                            let button = buttons[i];
                            if (event.key == button.keybind) button.exec();
                        }
                    }
                }
            }

            anchors {
                top: true
                left: true
                bottom: true
                right: true
            }

            Rectangle {
                color: backgroundColor
                anchors.fill: parent

                MouseArea {
                    anchors.fill: parent
                    onClicked: w.visible = false

                    GridLayout {
                        anchors.centerIn: parent
                        width: parent.width * 0.2
                        height: width / 4
                        columns: 3
                        columnSpacing: 0
                        rowSpacing: 0

                        Repeater {
                            model: buttons
                            delegate: Rectangle {
                                required property LogoutButton modelData
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.margins: 10
                                radius: 10
                                color: ma.containsMouse ? buttonHoverColor : buttonColor
                                border.color: "black"
                                border.width: ma.containsMouse ? 0 : 1

                                MouseArea {
                                    id: ma
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: modelData.exec()
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 5
                                    Text {
                                        font.family: Appearance.materialSymbols
                                        id: icon
                                        anchors.centerIn: parent
                                        text: modelData.icon
                                        font.pointSize: 40
                                        color: Appearance.white
                                    }
                                    Text {
                                        anchors.top: icon.bottom
                                        anchors.topMargin: 25
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.text
                                        font.pointSize: 20
                                        color: Appearance.white
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    GlobalShortcut {
        id: toggleLogoutShortcut
        appid: "quickshell"
        name: "toggle-logout"
        description: "Toggle WLogout panel"
        onPressed: {
            if (logout.panelWindowRef) {
                logout.panelWindowRef.visible = !logout.panelWindowRef.visible
            }
        }
    }
}
