import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Pipewire
import qs.config
import qs.utils
import qs.modules

Item {
    id: mixerInput
    width: parent.width
    height: 100 * Appearance.scaleFactor

    required property PwNode node;

	PwObjectTracker { objects: [ node ] }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 8 * Appearance.scaleFactor
        anchors.rightMargin: 8 * Appearance.scaleFactor

        RowLayout {
            id: speakerRowLayout
            Layout.fillWidth: true
            spacing: 6 * Appearance.scaleFactor

            Item {
                id: inputWrapper
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: inputMetrics.boundingRect.height
                clip: true

                TextMetrics {
                    id: inputMetrics
                    text: {
                        const app = node.properties["application.name"] ?? (node.description != "" ? node.description : node.name);
                        const media = node.properties["media.name"];
                        return media != undefined ? `${app} - ${media}` : app;
                    }
                    font.pixelSize: 14 * Appearance.scaleFactor
                    font.family: Appearance.defaultFont
                }

                Text {
                    id: speakerText
                    visible: inputMetrics.width <= inputWrapper.width
                    text: {
                        const app = node.properties["application.name"] ?? (node.description != "" ? node.description : node.name);
                        const media = node.properties["media.name"];
                        return media != undefined ? `${app} - ${media}` : app;
                    }
                    font.pixelSize: 14 * Appearance.scaleFactor
                    font.family: Appearance.defaultFont
                    color: Appearance.white
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    id: speakerMarquee
                    visible: inputMetrics.width > inputWrapper.width
                    anchors.fill: parent
                    clip: true
                    property real offset: 0

                    Row {
                        id: speakerScrollRow
                        spacing: 40
                        anchors.verticalCenter: parent.verticalCenter
                        x: speakerMarquee.offset

                        Text {
                            text: {
                                const app = node.properties["application.name"] ?? (node.description != "" ? node.description : node.name);
                                const media = node.properties["media.name"];
                                return media != undefined ? `${app} - ${media}` : app;
                            }
                            font.pixelSize: 14 * Appearance.scaleFactor
                            font.family: Appearance.defaultFont
                            color: Appearance.white
                        }
                        Text {
                            text: {
                                const app = node.properties["application.name"] ?? (node.description != "" ? node.description : node.name);
                                const media = node.properties["media.name"];
                                return media != undefined ? `${app} - ${media}` : app;
                            }
                            font.pixelSize: 14 * Appearance.scaleFactor
                            font.family: Appearance.defaultFont
                            color: Appearance.white
                        }
                    }

                    NumberAnimation on offset {
                        id: speakerAnim
                        from: 0
                        to: -(inputMetrics.width + 40)
                        duration: (inputMetrics.width + 40) * 40
                        loops: Animation.Infinite
                        running: speakerMarquee.visible
                    }

                    Component.onCompleted: if (speakerMarquee.visible) speakerAnim.restart()
                }
            }

            Label {
                text: node.audio.muted ? "0%" : Math.floor(node.audio.volume * 100) + "%"
                font.pixelSize: 14 * Appearance.scaleFactor
                font.family: Appearance.defaultFont
                color: Appearance.white
                Layout.alignment: Qt.AlignVCenter
            }

            Item {
                Layout.preferredWidth: 30 * Appearance.scaleFactor
                Layout.preferredHeight: 30 * Appearance.scaleFactor
                Layout.alignment: Qt.AlignVCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.AllButtons
                    onClicked: node.audio.muted = !node.audio.muted
                }

                Text {
                    anchors.centerIn: parent
                    text: (node.audio.muted || node.audio.volume === 0) ? "mic_off" : "mic"
                    font.family: Appearance.materialSymbols
                    font.pixelSize: 14 * Appearance.scaleFactor
                    color: Appearance.white
                }
            }
        }

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
                    width: (node.audio.muted ? 0 : node.audio.volume) * volumeBar.width
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
                    node.audio.volume = Math.max(0, Math.min(1, node.audio.volume + delta))
                }

                function update(mouseX) {
                    var ratio = Math.max(0, Math.min(1, mouseX / volumeBar.width))
                    node.audio.volume = ratio
                }
            }
        }
    }
}    