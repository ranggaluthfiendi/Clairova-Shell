import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell.Widgets
import QtCore
import qs.utils
import qs.config

Item {
    id: mediaWidget
    property real scaleFactor: Appearance.scaleFactor
    property bool expanded: false
    Layout.leftMargin: 5 * Appearance.scaleFactor

    width: expanded ? 250 * scaleFactor : 40 * scaleFactor
    height: 40 * scaleFactor

    MediaUtil { id: mediaUtil }

    Process { id: playPauseProc; command: ["playerctl", "-p", "plasma-browser-integration", "play-pause"] }
    Process { id: nextProc;      command: ["playerctl", "-p", "plasma-browser-integration", "next"] }
    Process { id: prevProc;      command: ["playerctl", "-p", "plasma-browser-integration", "previous"] }
    Process {
        id: volumeUpProc
        command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "+5%"]
    }

    Process {
        id: volumeDownProc
        command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "-5%"]
    }
    function mediaPlayPause() { playPauseProc.running = true }
    function mediaNext()      { nextProc.running = true }
    function mediaPrev()      { prevProc.running = true }

    Behavior on width {
        NumberAnimation {
            duration: 2000
            easing.type: Easing.InOutQuad
        }
    }
    
    RowLayout {
        anchors.fill: parent

        Item {
            width: 24 * scaleFactor
            height: 24 * scaleFactor

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

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        propagateComposedEvents: true
                        hoverEnabled: true
                        onWheel: {
                            if (wheel.angleDelta.y > 0)
                                volumeUpProc.running = true
                            else if (wheel.angleDelta.y < 0)
                                volumeDownProc.running = true
                        }
                    }

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
                        font.pixelSize: 18 * scaleFactor
                        color: "white"
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    mediaWidget.expanded = !mediaWidget.expanded
                    pressEffect.restart()
                }
            }
        }

        RowLayout {
            id: expandedArea
            property bool hiding: false

            width: mediaWidget.expanded ? implicitWidth : 0
            opacity: mediaWidget.expanded ? 1 : 0
            visible: mediaWidget.expanded || hiding
            spacing: 8 * scaleFactor
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            clip: true

            Behavior on width {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                    onFinished: {
                        if (!mediaWidget.expanded) {
                            expandedArea.hiding = false
                            expandedArea.visible = false
                        }
                    }
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }

            Connections {
                target: mediaWidget
                function onExpandedChanged() {
                    if (!mediaWidget.expanded) {
                        expandedArea.hiding = true
                    }
                }
            }

            ClippingWrapperRectangle {
                width: 24 * scaleFactor
                height: 24 * scaleFactor
                radius: 4 * scaleFactor

                Item {
                    id: container
                    anchors.fill: parent
                    property bool hovered: false

                    Rectangle {
                        anchors.fill: parent
                        color: Appearance.primary
                    }

                    Image {
                        id: cover
                        source: mediaUtil.coverArt || ""
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                    }
                }
            }

            ColumnLayout {
                spacing: 2 * scaleFactor
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                TextMetrics {
                    id: titleMetrics
                    text: mediaUtil.title || "Unknown Title"
                    font.pixelSize: 10 * scaleFactor
                }

                TextMetrics {
                    id: artistMetrics
                    text: mediaUtil.artist || "Unknown Artist"
                    font.pixelSize: 9 * scaleFactor
                }

                Item {
                    id: titleWrapper
                    Layout.fillWidth: true
                    height: 12 * scaleFactor
                    clip: true

                    Text {
                        id: titleText
                        visible: titleMetrics.width <= titleWrapper.width
                        text: mediaUtil.title || "Unknown Title"
                        font.pixelSize: 10 * scaleFactor
                        color: "white"
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
                            id: titleRow
                            spacing: 40
                            anchors.verticalCenter: parent.verticalCenter
                            x: titleMarquee.offset

                            Text {
                                text: mediaUtil.title || "Unknown Title"
                                font.pixelSize: 10 * scaleFactor
                                color: "white"
                            }

                            Text {
                                text: mediaUtil.title || "Unknown Title"
                                font.pixelSize: 10 * scaleFactor
                                color: "white"
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
                    id: artistWrapper
                    Layout.fillWidth: true
                    height: 11 * scaleFactor
                    clip: true

                    Text {
                        id: artistText
                        visible: artistMetrics.width <= artistWrapper.width
                        text: mediaUtil.artist || "Unknown Artist"
                        font.pixelSize: 9 * scaleFactor
                        color: "#aaa"
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                    }

                    Item {
                        id: artistMarquee
                        visible: artistMetrics.width > artistWrapper.width
                        anchors.fill: parent
                        clip: true
                        property real offset: 0

                        Row {
                            id: artistRow
                            spacing: 40
                            anchors.verticalCenter: parent.verticalCenter
                            x: artistMarquee.offset

                            Text {
                                text: mediaUtil.artist || "Unknown Artist"
                                font.pixelSize: 9 * scaleFactor
                                color: "#aaa"
                            }

                            Text {
                                text: mediaUtil.artist || "Unknown Artist"
                                font.pixelSize: 9 * scaleFactor
                                color: "#aaa"
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
            }

            RowLayout {
                spacing: 6 * scaleFactor
                Layout.alignment: Qt.AlignVCenter

                Repeater {
                    model: [
                        { icon: "skip_previous", action: mediaPrev },
                        { icon: mediaUtil.isPlaying ? "pause" : "resume", action: mediaPlayPause },
                        { icon: "skip_next", action: mediaNext }
                    ]

                    delegate: Item {
                        width: 20 * scaleFactor
                        height: 20 * scaleFactor

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.family: Appearance.materialSymbols
                            font.pixelSize: 16 * scaleFactor
                            color: "white"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: modelData.action()
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
        }
    }
}    

