import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.config
import qs.utils
import qs.widgets.sidebar

Item {
    id: mediaCard

    MediaUtil { id: mediaUtil }
    width: parent ? parent.width : 360
    implicitHeight: contentLayout.implicitHeight

    property real scaleFactor: Appearance.scaleFactor
    Process { id: playPauseProc; command: ["playerctl", "-p", "plasma-browser-integration", "play-pause"] }
    Process { id: nextProc; command: ["playerctl", "-p", "plasma-browser-integration", "next"] }
    Process { id: prevProc; command: ["playerctl", "-p", "plasma-browser-integration", "previous"] }

    function mediaPlayPause() { playPauseProc.running = true }
    function mediaNext()      { nextProc.running = true }
    function mediaPrev()      { prevProc.running = true }

    Component.onCompleted: {
        mediaUtil.loadMedia()
    }

    Column {
        id: contentLayout
        anchors.fill: parent
        spacing: 2

        ClippingWrapperRectangle {
            width: 370 * Appearance.scaleFactor
            height: 180 * Appearance.scaleFactor
            radius: 12 * Appearance.scaleFactor

            Item {
                id: container
                anchors.fill: parent

                Rectangle {
                    anchors.fill: parent
                    color: Appearance.primary
                }

                Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    cache: false
                    asynchronous: true
                    source: mediaUtil.coverSource
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#000000"
                    opacity: 0.7
                }
            }
        }

        Column {
            anchors.fill: parent
            anchors.topMargin: 5 * Appearance.scaleFactor
            anchors.leftMargin: 335 * Appearance.scaleFactor
            Item {
                width: 30 * scaleFactor
                height: 30 * scaleFactor

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Appearance.background
                }

                Item {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height

                    Item {
                        id: rotatingIcon
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
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
                            font.family: Appearance.materialSymbols
                            font.pixelSize: 24 * scaleFactor
                            color: "white"
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        pressEffect.restart()
                    }
                }
            }
        }

        Column{
            anchors.fill: parent
            anchors.topMargin: 80 * Appearance.scaleFactor
            anchors.leftMargin: 20 * Appearance.scaleFactor
            anchors.rightMargin: 20 * Appearance.scaleFactor
            spacing: 18
            Column {
                spacing: 8
                Item {
                    width: 330 * scaleFactor
                    height: 16 * scaleFactor
                    clip: true

                    TextMetrics {
                        id: titleMetrics
                        text: mediaUtil.title || "No Media Found"
                        font.pixelSize: 14 * scaleFactor
                        font.bold: true
                    }

                    Text {
                        visible: titleMetrics.width <= parent.width
                        anchors.verticalCenter: parent.verticalCenter
                        text: mediaUtil.title || "No Media Found"
                        font.pixelSize: 14 * scaleFactor
                        font.bold: true
                        color: Appearance.white
                        elide: Text.ElideRight
                    }

                    Item {
                        visible: titleMetrics.width > parent.width
                        anchors.fill: parent
                        clip: true
                        property real offset: 0

                        Row {
                            id: titleScroll
                            spacing: 40
                            anchors.verticalCenter: parent.verticalCenter
                            x: parent.offset

                            Text {
                                text: mediaUtil.title || "No Media Found"
                                font.pixelSize: 14 * scaleFactor
                                font.bold: true
                                color: Appearance.white
                            }
                            Text {
                                text: mediaUtil.title || "No Media Found"
                                font.pixelSize: 14 * scaleFactor
                                font.bold: true
                                color: Appearance.white
                            }
                        }

                        NumberAnimation on offset {
                            from: 0
                            to: -(titleMetrics.width + 40)
                            duration: (titleMetrics.width + 40) * 40
                            loops: Animation.Infinite
                            running: true
                        }
                    }
                }

                Item {
                    width: 330 * scaleFactor
                    height: 14 * scaleFactor
                    clip: true

                    TextMetrics {
                        id: artistMetrics
                        text: mediaUtil.artist || "Open music player app to start"
                        font.pixelSize: 12 * scaleFactor
                    }

                    Text {
                        visible: artistMetrics.width <= parent.width
                        anchors.verticalCenter: parent.verticalCenter
                        text: mediaUtil.artist || "Open music player app to start"
                        font.pixelSize: 12 * scaleFactor
                        color: Appearance.white
                        elide: Text.ElideRight
                    }

                    Item {
                        visible: artistMetrics.width > parent.width
                        anchors.fill: parent
                        clip: true
                        property real offset: 0

                        Row {
                            id: artistScroll
                            spacing: 40
                            anchors.verticalCenter: parent.verticalCenter
                            x: parent.offset

                            Text {
                                text: mediaUtil.artist || "Open music player app to start"
                                font.pixelSize: 12 * scaleFactor
                                color: Appearance.white
                            }
                            Text {
                                text: mediaUtil.artist || "Open music player app to start"
                                font.pixelSize: 12 * scaleFactor
                                color: Appearance.white
                            }
                        }

                        NumberAnimation on offset {
                            from: 0
                            to: -(artistMetrics.width + 40)
                            duration: (artistMetrics.width + 40) * 40
                            loops: Animation.Infinite
                            running: true
                        }
                    }
                }
            }

            ProgressBar {
                id: progressBar
                Layout.fillWidth: true
                width: 330 * Appearance.scaleFactor
                height: 6 * scaleFactor
                backgroundColor: Appearance.background
                progress: mediaUtil.progress
            }
        }

        Column {
            anchors.fill: parent
            anchors.topMargin: 150 * Appearance.scaleFactor
            anchors.leftMargin: 20 * Appearance.scaleFactor
            Text {
                text: mediaUtil.formattedTime
                font.pixelSize: 12 * scaleFactor
                color: Appearance.white
                font.family: Appearance.defaultFont
            }
        }

        Column {
            anchors.fill: parent
            anchors.topMargin: 150 * Appearance.scaleFactor
            anchors.leftMargin: 250 * Appearance.scaleFactor
            Row {
                spacing: 25 * Appearance.scaleFactor
                Item {
                    width: 18 * scaleFactor
                    height: 18 * scaleFactor

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
                Item {
                    width: 18 * scaleFactor
                    height: 18 * scaleFactor

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
                Item {
                    width: 18 * scaleFactor
                    height: 18 * scaleFactor

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
