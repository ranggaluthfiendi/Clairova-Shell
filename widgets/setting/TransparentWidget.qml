import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config
import qs.utils

Item {
    id: transparentWidget
    width: parent.width
    height: 60 * Appearance.scaleFactor

    TransparentUtil {
        id: transparent
    }

    property alias checked: toggleSwitch.checked
    signal toggled(bool value)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8 * Appearance.scaleFactor
        spacing: 12 * Appearance.scaleFactor

        Label {
            text: "Toggle Transparent"
            font.pixelSize: 14 * Appearance.scaleFactor
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            color: Appearance.white
            font.family: Appearance.defaultFont
        }

        Switch {
            id: toggleSwitch
            checked: false

            onToggled: {
                transparent.apply(checked)
                transparentWidget.toggled(checked)
            }

            indicator: Item {
                implicitWidth: 40 * Appearance.scaleFactor
                implicitHeight: 20 * Appearance.scaleFactor

                Rectangle {
                    id: track
                    anchors.fill: parent
                    radius: height / 2
                    color: toggleSwitch.checked ? Appearance.primary : Appearance.color
                    border.color: Appearance.background
                    border.width: 1
                    antialiasing: true
                }

                Rectangle {
                    id: thumb
                    width: 18 * Appearance.scaleFactor
                    height: 18 * Appearance.scaleFactor
                    radius: width / 2
                    y: 1
                    x: toggleSwitch.checked ? (parent.width - width - 1) : 1
                    color: "white"
                    border.color: Appearance.white
                    border.width: 1
                    antialiasing: true

                    Behavior on x {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: transparent
        onTransparentLoaded: (value) => {
            toggleSwitch.checked = value
        }
    }

    Component.onCompleted: {
        toggleSwitch.checked = transparent.useTransparent
    }
}
