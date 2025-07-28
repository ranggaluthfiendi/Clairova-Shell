import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Pipewire
import qs.config
import qs.utils
import qs.modules
import qs.widgets.setting

Item {
    id: volumeWidget
    width: parent.width
    height: 240 * Appearance.scaleFactor

    property string currentOutputDisplayName: AudioService.output ? AudioService.displayName(AudioService.output) : ""
    property string currentInputDisplayName: AudioService.input ? AudioService.displayName(AudioService.input) : ""
    
    VolumeUtil { id: volumeUtil }
    MicUtil { id: micUtil }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 8 * Appearance.scaleFactor
        anchors.rightMargin: 8 * Appearance.scaleFactor
        anchors.topMargin: 8 * Appearance.scaleFactor
        anchors.bottomMargin: 40 * Appearance.scaleFactor

        RowLayout {
            id: speakerRowLayout
            Layout.fillWidth: true
            spacing: 6 * Appearance.scaleFactor

            Item {
                id: speakerWrapper
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: speakerMetrics.boundingRect.height
                clip: true

                property string displayText: "Current Speaker: " + (volumeWidget.currentOutputDisplayName || "None")

                TextMetrics {
                    id: speakerMetrics
                    text: speakerWrapper.displayText
                    font.pixelSize: 14 * Appearance.scaleFactor
                    font.family: Appearance.defaultFont
                }

                Text {
                    id: speakerText
                    visible: speakerMetrics.width <= speakerWrapper.width
                    text: speakerWrapper.displayText
                    font.pixelSize: 14 * Appearance.scaleFactor
                    font.family: Appearance.defaultFont
                    color: Appearance.white
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    id: speakerMarquee
                    visible: speakerMetrics.width > speakerWrapper.width
                    anchors.fill: parent
                    clip: true
                    property real offset: 0

                    Row {
                        id: speakerScrollRow
                        spacing: 40
                        anchors.verticalCenter: parent.verticalCenter
                        x: speakerMarquee.offset

                        Text {
                            text: speakerWrapper.displayText
                            font.pixelSize: 14 * Appearance.scaleFactor
                            font.family: Appearance.defaultFont
                            color: Appearance.white
                        }
                        Text {
                            text: speakerWrapper.displayText
                            font.pixelSize: 14 * Appearance.scaleFactor
                            font.family: Appearance.defaultFont
                            color: Appearance.white
                        }
                    }

                    NumberAnimation on offset {
                        id: speakerAnim
                        from: 0
                        to: -(speakerMetrics.width + 40)
                        duration: (speakerMetrics.width + 40) * 40
                        loops: Animation.Infinite
                        running: speakerMarquee.visible
                    }

                    Component.onCompleted: if (speakerMarquee.visible) speakerAnim.restart()
                }
            }

            Label {
                text: volumeUtil.muted ? "0%" : Math.round(volumeUtil.volume * 100) + "%"
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
                    onClicked: volumeUtil.muted = !volumeUtil.muted
                }

                Text {
                    anchors.centerIn: parent
                    text: (volumeUtil.muted || volumeUtil.volume === 0) ? "volume_off" : "volume_up"
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
    
        RowLayout {
            id: micRowLayout
            Layout.fillWidth: true

            Item {
                id: micWrapper
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: micMetrics.boundingRect.height
                clip: true

                property string displayText: "Current Mic: " + (volumeWidget.currentInputDisplayName || "None")

                TextMetrics {
                    id: micMetrics
                    text: micWrapper.displayText
                    font.pixelSize: 14 * Appearance.scaleFactor
                    font.family: Appearance.defaultFont
                }

                Text {
                    id: micText
                    visible: micMetrics.width <= micWrapper.width
                    text: micWrapper.displayText
                    font.pixelSize: 14 * Appearance.scaleFactor
                    font.family: Appearance.defaultFont
                    color: Appearance.white
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    id: micMarquee
                    visible: micMetrics.width > micWrapper.width
                    anchors.fill: parent
                    clip: true
                    property real offset: 0

                    Row {
                        id: micScrollRow
                        spacing: 40
                        anchors.verticalCenter: parent.verticalCenter
                        x: micMarquee.offset

                        Text {
                            text: micWrapper.displayText
                            font.pixelSize: 14 * Appearance.scaleFactor
                            font.family: Appearance.defaultFont
                            color: Appearance.white
                        }

                        Text {
                            text: micWrapper.displayText
                            font.pixelSize: 14 * Appearance.scaleFactor
                            font.family: Appearance.defaultFont
                            color: Appearance.white
                        }
                    }

                    NumberAnimation on offset {
                        id: micAnim
                        from: 0
                        to: -(micMetrics.width + 40)
                        duration: (micMetrics.width + 40) * 40
                        loops: Animation.Infinite
                        running: micMarquee.visible
                    }

                    Component.onCompleted: if (micMarquee.visible) micAnim.restart()
                }
            }

            Label {
                text: micUtil.muted ? "0%" : Math.round(micUtil.volume * 100) + "%"
                font.pixelSize: 14 * Appearance.scaleFactor
                color: Appearance.white
                font.family: Appearance.defaultFont
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
                    onClicked: micUtil.muted = !micUtil.muted

                }

                Text {
                    anchors.centerIn: parent
                    text: (micUtil.muted || micUtil.volume === 0) ? "mic_off" : "mic"
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
                id: micContainer
                anchors.fill: parent

                DropShadow {
                    anchors.fill: micFill
                    source: micFill
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 20
                    samples: 60
                    color: Appearance.primary
                    transparentBorder: true
                }

                Rectangle {
                    id: micFill
                    width: (micUtil.muted ? 0 : micUtil.volume) * micBar.width
                    height: micBar.height
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
                id: micBar
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

                        x: leftMargin + index * (micBar.width - leftMargin - rightMargin - width) / 9

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
                    micUtil.volume = Math.max(0, Math.min(1, micUtil.volume + delta))
                }

                function update(mouseX) {
                    var ratio = Math.max(0, Math.min(1, mouseX / micBar.width))
                    micUtil.volume = ratio
                }
            }
        }
    }
}

