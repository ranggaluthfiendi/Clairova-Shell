import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Pipewire
import qs.config
import qs.modules

Item {
    id: mixerOutput
    width: parent.width
    height: 80 * Appearance.scaleFactor

    required property PwNode node

    PwObjectTracker { objects: [ node ] }

    readonly property string safeDisplayName: {
        if (!node || !node.properties) return "Default Output"
        const p = node.properties

        if (p["device.description"]) return p["device.description"]
        if (p["media.name"] && p["media.name"] !== p["device.description"])
            return `${p["device.description"] ?? "Output"} - ${p["media.name"]}`

        const name = node.name ?? ""

        if (name.includes("analog")) return "Built-in Speaker"
        if (name.includes("bluez")) return "Bluetooth Audio"
        if (name.includes("usb")) return "USB Audio"
        if (name.includes("hdmi")) return "HDMI Audio"

        return name || "Default Output"
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
                id: outputWrapper
                Layout.fillWidth: true
                Layout.preferredHeight: 30 * Appearance.scaleFactor
                clip: true

                TextMetrics {
                    id: outputMetrics
                    text: {
                        const base = safeDisplayName
                        const media = node?.properties?.["media.name"]
                        return (media && media !== base) ? `${base} - ${media}` : (base || "Default Output")
                    }
                    font.pixelSize: 14 * Appearance.scaleFactor
                    font.family: Appearance.defaultFont
                }

                Text {
                    visible: outputMetrics.width <= outputWrapper.width
                    text: outputMetrics.text
                    font.pixelSize: 14 * Appearance.scaleFactor
                    font.family: Appearance.defaultFont
                    color: Appearance.white
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    anchors.fill: parent
                }

                Item {
                    id: speakerMarquee
                    visible: outputMetrics.width > outputWrapper.width
                    anchors.fill: parent
                    clip: true
                    property real offset: 0

                    Row {
                        spacing: 40
                        anchors.verticalCenter: parent.verticalCenter
                        x: speakerMarquee.offset

                        Text {
                            text: outputMetrics.text
                            font.pixelSize: 14 * Appearance.scaleFactor
                            font.family: Appearance.defaultFont
                            color: Appearance.white
                        }
                        Text {
                            text: outputMetrics.text
                            font.pixelSize: 14 * Appearance.scaleFactor
                            font.family: Appearance.defaultFont
                            color: Appearance.white
                        }
                    }

                    NumberAnimation on offset {
                        from: 0
                        to: -(outputMetrics.width + 40)
                        duration: (outputMetrics.width + 40) * 40
                        loops: Animation.Infinite
                        running: speakerMarquee.visible
                    }

                }
            }

            Item {
                Layout.preferredWidth: 60 * Appearance.scaleFactor
                Layout.preferredHeight: 30 * Appearance.scaleFactor
                Layout.alignment: Qt.AlignRight

                RowLayout {
                    anchors.fill: parent
                    spacing: 4 * Appearance.scaleFactor

                    Text {
                        text: (!node || !node.audio) ? "0%" : (node.audio.muted ? "0%" : Math.floor(node.audio.volume * 100) + "%")
                        font.pixelSize: 14 * Appearance.scaleFactor
                        font.family: Appearance.defaultFont
                        color: Appearance.white
                        verticalAlignment: Text.AlignVCenter
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item {
                        width: 30 * Appearance.scaleFactor
                        height: 30 * Appearance.scaleFactor

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.AllButtons
                            onClicked: if (node?.audio) node.audio.muted = !node.audio.muted
                        }

                        Text {
                            anchors.centerIn: parent
                            text: (!node || !node.audio || node.audio.muted || node.audio.volume === 0) ? "volume_off" : "volume_up"
                            font.family: Appearance.materialSymbols
                            font.pixelSize: 14 * Appearance.scaleFactor
                            color: Appearance.white
                        }
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
                    if (!node || !node.audio) return
                    var delta = wheel.angleDelta.y > 0 ? 0.01 : -0.01
                    node.audio.volume = Math.max(0, Math.min(1, node.audio.volume + delta))
                }

                function update(mouseX) {
                    if (!node || !node.audio) return
                    var ratio = Math.max(0, Math.min(1, mouseX / volumeBar.width))
                    node.audio.volume = ratio
                }
            }
        }
    }
}
