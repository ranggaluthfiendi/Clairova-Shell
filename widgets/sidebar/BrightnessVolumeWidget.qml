import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.config
import Quickshell

import qs.utils
import qs.modules

Item {
    id: brightnessVolumeWidget
    width: 200 * Appearance.scaleFactor
    height: 100 * Appearance.scaleFactor

    VolumeUtil { id: volumeUtil }
    BrightnessUtil { id: brightnessUtil }
    VolumeControl { id: volumeControl }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 16 * Appearance.scaleFactor
        anchors.rightMargin: 12 * Appearance.scaleFactor
        spacing: 20 * Appearance.scaleFactor

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 25 * Appearance.scaleFactor
            spacing: 6 * Appearance.scaleFactor

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 25 * Appearance.scaleFactor

                Item {
                    id: volumeContainer
                    anchors.fill: parent

                    DropShadow {
                        anchors.fill: volumeFill
                        source: volumeFill
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: 20
                        samples: 60
                        color: Appearance.primary
                        transparentBorder: true
                    }

                    Rectangle {
                        id: volumeFill
                        width: (volumeUtil.muted ? 0 : volumeUtil.volume) * volumeBar.width
                        height: volumeBar.height
                        radius: 30 * Appearance.scaleFactor
                        color: Appearance.primary
                        anchors.left: parent.left
                        layer.enabled: true
                        layer.smooth: true

                        Behavior on width {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }

                Rectangle {
                    id: volumeBar
                    anchors.fill: parent
                    radius: 30 * Appearance.scaleFactor
                    z: -1
                    color: "transparent"

                    Repeater {
                        model: 10
                        Rectangle {
                            width: 8 * Appearance.scaleFactor
                            height: 8 * Appearance.scaleFactor
                            radius: width / 2
                            color: Appearance.background
                            anchors.verticalCenter: parent.verticalCenter
                            property real leftMargin: 8 * Appearance.scaleFactor
                            property real rightMargin: 8 * Appearance.scaleFactor

                            x: leftMargin + index * (volumeBar.width - leftMargin - rightMargin - width) / 9

                            Text {
                                text: "•"
                                color: Appearance.white
                                anchors.centerIn: parent
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.AllButtons
                    property bool dragging: false

                    onPressed: (mouse) => {
                        dragging = true
                        update(mouse.x)
                    }

                    onPositionChanged: (mouse) => {
                        if (dragging) update(mouse.x)
                    }

                    onReleased: dragging = false

                    onWheel: (wheel) => {
                        var delta = wheel.angleDelta.y > 0 ? 0.01 : -0.01
                        volumeUtil.volume = Math.max(0, Math.min(1, volumeUtil.volume + delta))
                    }

                    function update(mouseX) {
                        var ratio = Math.max(0, Math.min(1, mouseX / volumeBar.width))
                        volumeUtil.volume = ratio
                    }
                }
            }

            Item {
                Layout.preferredWidth: 30 * Appearance.scaleFactor
                Layout.preferredHeight: 30 * Appearance.scaleFactor
                Layout.alignment: Qt.AlignVCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.AllButtons

                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            volumeUtil.muted = !volumeUtil.muted
                        } else if (mouse.button === Qt.RightButton) {
                            barWindow.toggleVolume()
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: (volumeUtil.muted || volumeUtil.volume === 0) ? "volume_off" : "volume_up"
                    font.family: Appearance.materialSymbols
                    font.pixelSize: Appearance.extraLarge * Appearance.scaleFactor
                    color: Appearance.white
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 25 * Appearance.scaleFactor
            spacing: 6 * Appearance.scaleFactor

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 25 * Appearance.scaleFactor

                Item {
                    id: brightnessContainer
                    anchors.fill: parent

                    DropShadow {
                        anchors.fill: brightnessFill
                        source: brightnessFill
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: 20
                        samples: 60
                        color: Appearance.primary
                        transparentBorder: true
                    }

                    Rectangle {
                        id: brightnessFill
                        width: brightnessUtil.brightness * brightnessBar.width
                        height: brightnessBar.height
                        radius: 30 * Appearance.scaleFactor
                        color: Appearance.primary
                        anchors.left: parent.left
                        layer.enabled: true
                        layer.smooth: true

                        Behavior on width {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }

                Rectangle {
                    id: brightnessBar
                    anchors.fill: parent
                    radius: 30 * Appearance.scaleFactor
                    z: -1
                    color: "transparent"

                    Repeater {
                        model: 10
                        Rectangle {
                            width: 8 * Appearance.scaleFactor
                            height: 8 * Appearance.scaleFactor
                            radius: width / 2
                            color: Appearance.background
                            anchors.verticalCenter: parent.verticalCenter
                            property real leftMargin: 8 * Appearance.scaleFactor
                            property real rightMargin: 8 * Appearance.scaleFactor

                            x: leftMargin + index * (brightnessBar.width - leftMargin - rightMargin - width) / 9

                            Text {
                                text: "•"
                                color: Appearance.white
                                anchors.centerIn: parent
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.AllButtons
                    property bool dragging: false

                    onPressed: (mouse) => {
                        dragging = true
                        update(mouse.x)
                    }

                    onPositionChanged: (mouse) => {
                        if (dragging) update(mouse.x)
                    }

                    onReleased: dragging = false

                    onWheel: (wheel) => {
                        var delta = wheel.angleDelta.y > 0 ? 0.01 : -0.01
                        brightnessUtil.brightness = Math.max(0, Math.min(1, brightnessUtil.brightness + delta))
                    }

                    function update(mouseX) {
                        var ratio = Math.max(0, Math.min(1, mouseX / brightnessBar.width))
                        brightnessUtil.brightness = ratio
                    }
                }
            }

            Text {
                text: "sunny"
                font.family: Appearance.materialSymbols
                font.pixelSize: Appearance.extraLarge * Appearance.scaleFactor
                color: Appearance.white
                verticalAlignment: Text.AlignVCenter
                Layout.preferredWidth: 30 * Appearance.scaleFactor
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
