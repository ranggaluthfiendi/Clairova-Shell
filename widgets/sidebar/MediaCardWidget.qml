import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import qs.config
import qs.utils
import qs.widgets.sidebar

Item {
    id: mediaCard
    width: 400 * scaleFactor
    height: 100 * scaleFactor

    property real scaleFactor: Appearance.scaleFactor
    property MediaUtil mediaUtil

    Process { id: playPauseProc; command: ["playerctl", "-p", "plasma-browser-integration", "play-pause"] }
    Process { id: nextProc; command: ["playerctl", "-p", "plasma-browser-integration", "next"] }
    Process { id: prevProc; command: ["playerctl", "-p", "plasma-browser-integration", "previous"] }

    function mediaPlayPause() { playPauseProc.running = true }
    function mediaNext()      { nextProc.running = true }
    function mediaPrev()      { prevProc.running = true }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15 * scaleFactor
        spacing: 10 * scaleFactor

        Item {
            id: coverWrapper
            width: 100 * scaleFactor
            height: 100 * scaleFactor
            property bool hovered: false

            readonly property bool isBrightCover: mediaUtil.coverArt.includes("googleusercontent") || mediaUtil.coverArt.includes("ytimg")

            Rectangle {
                anchors.fill: parent
                color: Appearance.primary
                radius: 8 * scaleFactor
            }

            Image {
                id: coverArt
                anchors.fill: parent
                source: mediaUtil.coverArt || ""
                fillMode: Image.PreserveAspectCrop
                smooth: true

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: coverArt.width
                        height: coverArt.height
                        radius: 8 * scaleFactor
                    }
                }
            }

            Text {
                visible: coverWrapper.hovered
                anchors.centerIn: parent
                font.family: Appearance.materialSymbols
                font.pixelSize: 36 * scaleFactor
                text: "open_in_new"
                color: coverWrapper.isBrightCover ? "black" : "white"
                z: 2

                layer.enabled: true
                layer.effect: DropShadow {
                    color: coverWrapper.isBrightCover ? "#ffffffcc" : "#000000cc"
                    radius: 8
                    samples: 16
                    horizontalOffset: 0
                    verticalOffset: 0
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: coverWrapper.hovered = true
                onExited: coverWrapper.hovered = false
                onClicked: {
                    if (mediaUtil.url)
                        Qt.openUrlExternally(mediaUtil.url)
                }
                cursorShape: Qt.PointingHandCursor
            }
        }

        ColumnLayout {
            spacing: 6 * scaleFactor
            Layout.fillWidth: true

            RowLayout {
                id: titleRowLayout
                Layout.fillWidth: true
                spacing: 6 * scaleFactor

                Item {
                    id: titleWrapper
                    Layout.fillWidth: true
                    height: 16 * scaleFactor
                    clip: true

                    TextMetrics {
                        id: titleMetrics
                        text: mediaUtil.title || "Unknown Title"
                        font.pixelSize: 14 * scaleFactor
                        font.bold: true
                    }

                    Text {
                        id: titleText
                        visible: titleMetrics.width <= titleWrapper.width
                        text: mediaUtil.title || "Unknown Title"
                        font.pixelSize: 14 * scaleFactor
                        font.bold: true
                        color: Appearance.white
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                    }

                    Item {
                        id: titleMarquee
                        visible: titleMetrics.width > titleWrapper.width
                        anchors.fill: parent
                        clip: true
                        property real offset: 0

                        Row {
                            id: titleScrollRow
                            spacing: 40
                            anchors.verticalCenter: parent.verticalCenter
                            x: titleMarquee.offset

                            Text {
                                text: mediaUtil.title || "Unknown Title"
                                font.pixelSize: 14 * scaleFactor
                                font.bold: true
                                color: Appearance.white
                            }
                            Text {
                                text: mediaUtil.title || "Unknown Title"
                                font.pixelSize: 14 * scaleFactor
                                font.bold: true
                                color: Appearance.white
                            }
                        }

                        NumberAnimation on offset {
                            id: titleAnim
                            from: 0
                            to: -(titleMetrics.width + 40)
                            duration: (titleMetrics.width + 40) * 40
                            loops: Animation.Infinite
                            running: titleMarquee.visible
                        }

                        Component.onCompleted: if (titleMarquee.visible) titleAnim.restart()
                    }
                }
                Item {
                    id: rotatingIcon
                    width: 20 * scaleFactor
                    height: 20 * scaleFactor
                    transformOrigin: Item.Center
                    property real currentRotation: 0
                    rotation: currentRotation

                    transform: Scale {
                        id: scaleTransform
                        origin.x: rotatingIcon.width / 2
                        origin.y: rotatingIcon.height / 2
                        xScale: 1.0
                        yScale: 1.0
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                        propagateComposedEvents: true
                        onWheel: {
                            if (wheel.angleDelta.y > 0)
                                volumeUpProc.running = true
                            else if (wheel.angleDelta.y < 0)
                                volumeDownProc.running = true
                        }
                    }

                    Timer {
                        id: loopTimer
                        interval: 16
                        repeat: true
                        running: false
                        onTriggered: {
                            rotatingIcon.currentRotation += 1
                            if (rotatingIcon.currentRotation >= 360)
                                rotatingIcon.currentRotation = 0
                        }
                    }

                    NumberAnimation {
                        id: returnToZero
                        target: rotatingIcon
                        property: "currentRotation"
                        easing.type: Easing.InOutQuad
                    }

                    SequentialAnimation {
                        id: pressEffect
                        running: false
                        NumberAnimation {
                            target: scaleTransform
                            property: "xScale"
                            to: 1.2
                            duration: 60
                        }
                        NumberAnimation {
                            target: scaleTransform
                            property: "xScale"
                            to: 1.0
                            duration: 80
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: scaleTransform
                                property: "yScale"
                                to: 1.2
                                duration: 60
                            }
                            NumberAnimation {
                                target: scaleTransform
                                property: "yScale"
                                to: 1.0
                                duration: 80
                            }
                        }
                    }

                    Connections {
                        target: mediaUtil
                        function onStatusChanged() {
                            if (mediaUtil.status === "Playing") {
                                returnToZero.stop()
                                loopTimer.running = true
                            } else {
                                loopTimer.running = false
                                let angle = rotatingIcon.currentRotation
                                let remaining = (360 - (angle % 360)) % 360
                                returnToZero.from = angle
                                returnToZero.to = angle + remaining
                                returnToZero.duration = (mediaUtil.status === "Paused") ? 1200 : 800
                                returnToZero.restart()
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "music_note"
                        font.pixelSize: 18 * scaleFactor
                        font.family: Appearance.materialSymbols
                        color: Appearance.white
                    }
                }
            }

            Item {
                id: artistWrapper
                Layout.fillWidth: true
                height: 14 * scaleFactor
                clip: true

                TextMetrics {
                    id: artistMetrics
                    text: mediaUtil.artist || "Unknown Artist"
                    font.pixelSize: 12 * scaleFactor
                }

                Text {
                    id: artistText
                    visible: artistMetrics.width <= artistWrapper.width
                    text: mediaUtil.artist || "Unknown Artist"
                    font.pixelSize: 12 * scaleFactor
                    color: Appearance.white
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    id: artistMarquee
                    visible: artistMetrics.width > artistWrapper.width
                    anchors.fill: parent
                    clip: true
                    property real offset: 0

                    Row {
                        id: artistScrollRow
                        spacing: 40
                        anchors.verticalCenter: parent.verticalCenter
                        x: artistMarquee.offset

                        Text {
                            text: mediaUtil.artist || "Unknown Artist"
                            font.pixelSize: 12 * scaleFactor
                            color: Appearance.white
                        }
                        Text {
                            text: mediaUtil.artist || "Unknown Artist"
                            font.pixelSize: 12 * scaleFactor
                            color: Appearance.white
                        }
                    }

                    NumberAnimation on offset {
                        id: artistAnim
                        from: 0
                        to: -(artistMetrics.width + 40)
                        duration: (artistMetrics.width + 40) * 40
                        loops: Animation.Infinite
                        running: artistMarquee.visible
                    }

                    Component.onCompleted: if (artistMarquee.visible) artistAnim.restart()
                }
            }
            Text {
                text: mediaUtil.formattedTime
                font.pixelSize: 10 * scaleFactor
                color: Appearance.white
            }

            Item {
                Layout.fillHeight: true
            }

            RowLayout {
                spacing: 8 * scaleFactor
                Layout.alignment: Qt.AlignLeft
                Layout.fillWidth: true

                ProgressBar {
                    id: progressBar
                    Layout.fillWidth: true
                    height: 6 * scaleFactor
                    backgroundColor: Appearance.background
                    progress: mediaUtil.progress
                }
                
            }

            RowLayout {
                // Previous
                Item {
                    width: 20 * scaleFactor
                    height: 20 * scaleFactor

                    Text {
                        anchors.centerIn: parent
                        text: "skip_previous"
                        font.family: Appearance.materialSymbols
                        font.pixelSize: 18 * scaleFactor
                        color: Appearance.white
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: mediaPrev()
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Item { Layout.fillWidth: true }

                Item {
                    width: 20 * scaleFactor
                    height: 20 * scaleFactor

                    Text {
                        anchors.centerIn: parent
                        text: mediaUtil.isPlaying ? "pause" : "resume"
                        font.family: Appearance.materialSymbols
                        font.pixelSize: 18 * scaleFactor
                        color: Appearance.white
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: mediaPlayPause()
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Item { Layout.fillWidth: true }

                // Next
                Item {
                    width: 20 * scaleFactor
                    height: 20 * scaleFactor

                    Text {
                        anchors.centerIn: parent
                        text: "skip_next"
                        font.family: Appearance.materialSymbols
                        font.pixelSize: 18 * scaleFactor
                        color: Appearance.white
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: mediaNext()
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }
}
