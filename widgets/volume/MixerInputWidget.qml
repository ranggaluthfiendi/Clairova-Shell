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
    height: 80 * Appearance.scaleFactor

    required property PwNode node

    PwObjectTracker { objects: [ node ] }

    readonly property string safeDisplayName: {
        if (!node || !node.properties) return "Default Mic"

        const p = node.properties

        if (p["device.description"]) return p["device.description"]
        if (p["media.name"] && p["media.name"] !== p["device.description"])
            return `${p["device.description"] ?? "Mic"} - ${p["media.name"]}`

        const name = node.name ?? ""

        if (name.includes("analog")) return "Built-in Mic"
        else if (name.includes("bluez")) return "Bluetooth Audio"
        else if (name.includes("usb")) return "USB Audio"
        else if (name.includes("hdmi")) return "HDMI Audio"

        return name || "Default Mic"
    }

    function displayName() {
        if (!node || !node.properties) return safeDisplayName
        const media = node.properties["media.name"]
        if (media && media !== safeDisplayName)
            return `${safeDisplayName} - ${media}`
        return safeDisplayName
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 8 * Appearance.scaleFactor
        anchors.rightMargin: 8 * Appearance.scaleFactor

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 30 * Appearance.scaleFactor
            spacing: 8 * Appearance.scaleFactor

            Item {
                id: inputWrapper
                Layout.fillWidth: true
                Layout.preferredHeight: 30 * Appearance.scaleFactor
                clip: true

                TextMetrics {
                    id: inputMetrics
                    text: displayName()
                    font.pixelSize: 14 * Appearance.scaleFactor
                    font.family: Appearance.defaultFont
                }

                Text {
                    id: micText
                    visible: inputMetrics.width <= inputWrapper.width
                    text: displayName()
                    font.pixelSize: 14 * Appearance.scaleFactor
                    font.family: Appearance.defaultFont
                    color: Appearance.white
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    anchors.fill: parent
                }

                Item {
                    id: speakerMarquee
                    visible: inputMetrics.width > inputWrapper.width
                    anchors.fill: parent
                    clip: true
                    property real offset: 0

                    Row {
                        spacing: 40
                        anchors.verticalCenter: parent.verticalCenter
                        x: speakerMarquee.offset

                        Text {
                            text: displayName()
                            font.pixelSize: 14 * Appearance.scaleFactor
                            font.family: Appearance.defaultFont
                            color: Appearance.white
                        }
                        Text {
                            text: displayName()
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

            RowLayout {
                Layout.preferredWidth: 60 * Appearance.scaleFactor
                Layout.preferredHeight: 30 * Appearance.scaleFactor
                Layout.alignment: Qt.AlignRight
                spacing: 4 * Appearance.scaleFactor

                Label {
                    text: (!node || !node.audio) ? "0%" : (node.audio.muted ? "0%" : Math.floor(node.audio.volume * 100) + "%")
                    font.pixelSize: 14 * Appearance.scaleFactor
                    font.family: Appearance.defaultFont
                    color: Appearance.white
                    verticalAlignment: Label.AlignVCenter
                }

                Item {
                    width: 30 * Appearance.scaleFactor
                    height: 30 * Appearance.scaleFactor

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.AllButtons
                        onClicked: if (node && node.audio) node.audio.muted = !node.audio.muted
                    }

                    Text {
                        anchors.centerIn: parent
                        text: (!node || !node.audio || node.audio.muted || node.audio.volume === 0) ? "mic_off" : "mic"
                        font.family: Appearance.materialSymbols
                        font.pixelSize: 14 * Appearance.scaleFactor
                        color: Appearance.white
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 18 * Appearance.scaleFactor

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
                    width: (!node || !node.audio || node.audio.muted ? 0 : node.audio.volume * volumeBar.width)
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
                    if (node && node.audio) {
                        node.audio.volume = Math.max(0, Math.min(1, node.audio.volume + delta))
                    }
                }

                function update(mouseX) {
                    var ratio = Math.max(0, Math.min(1, mouseX / volumeBar.width))
                    if (node && node.audio) {
                        node.audio.volume = ratio
                    }
                }
            }
        }
    }
}
