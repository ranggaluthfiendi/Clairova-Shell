import QtQuick
import QtCore
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.config
import qs.utils
import qs.widgets

Item {
    id: mediaCard
    width: 400 * scaleFactor
    height: 160 * scaleFactor
    property real scaleFactor: Appearance.scaleFactor
    property MediaUtil mediaUtil

    Process { id: playPauseProc; command: ["playerctl", "-p", "plasma-browser-integration", "play-pause"] }
    Process { id: nextProc;      command: ["playerctl", "-p", "plasma-browser-integration", "next"] }
    Process { id: prevProc;      command: ["playerctl", "-p", "plasma-browser-integration", "previous"] }

    function mediaPlayPause() { playPauseProc.running = true }
    function mediaNext()      { nextProc.running = true }
    function mediaPrev()      { prevProc.running = true }
    property color current: Appearance.color

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15 * scaleFactor

        ClippingWrapperRectangle {
            width: 200 * scaleFactor
            height: 130 * scaleFactor
            radius: 8 * scaleFactor

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
                    anchors.fill: parent
                    source: mediaUtil.coverArt || ""
                    fillMode: Image.PreserveAspectCrop
                }

                readonly property bool isBrightCover: mediaUtil.coverArt.includes("googleusercontent") || mediaUtil.coverArt.includes("ytimg")

                Text {
                    visible: container.hovered
                    anchors.centerIn: parent
                    font.family: Appearance.materialSymbols
                    font.pixelSize: 36 * scaleFactor
                    text: "open_in_new"
                    color: container.isBrightCover ? "black" : "white"
                    z: 2

                    layer.enabled: true
                    layer.effect: DropShadow {
                        color: container.isBrightCover ? "#ffffffcc" : "#000000cc"
                        radius: 8
                        samples: 16
                        horizontalOffset: 0
                        verticalOffset: 0
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: container.hovered = true
                    onExited: container.hovered = false
                    onClicked: {
                        if (mediaUtil.url) {
                            Qt.openUrlExternally(mediaUtil.url)
                        }
                    }
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
           
            ProgressBar {
                backgroundColor: current
                anchors.horizontalCenter: parent.horizontalCenter
                height: 10 * scaleFactor
            }

            // ProgressBar2 {
            //     anchors.horizontalCenter: parent.horizontalCenter
            //     height: 20 * scaleFactor
            // }

            // ProgressBar3 {
            //     backgroundColor: current
            //     anchors.horizontalCenter: parent.horizontalCenter
            //     height: 20 * scaleFactor
            // }

            WaveBackground {
                anchors.fill: parent
                mediaUtil: mediaCard.mediaUtil
                z: -1
            }

            Item {
                anchors.fill: parent

                Item {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter

                    Column {
                        id: titleArtistLayout
                        width: parent.width
                        spacing: 5 * scaleFactor
                        anchors.horizontalCenter: parent.horizontalCenter

                        TextMetrics {
                            id: titleMetrics
                            text: mediaUtil.title || "Unknown Title"
                            font.pixelSize: 13 * scaleFactor
                            font.bold: true
                        }

                        TextMetrics {
                            id: artistMetrics
                            text: mediaUtil.artist || "Unknown Artist"
                            font.pixelSize: 11 * scaleFactor
                        }

                        Item {
                            id: titleWrapper
                            width: 160 * scaleFactor
                            height: 15 * scaleFactor
                            anchors.horizontalCenter: parent.horizontalCenter
                            clip: true

                            Text {
                                id: titleText
                                visible: titleMetrics.width <= titleWrapper.width
                                font.family: Appearance.defaultFont
                                text: mediaUtil.title || "Unknown Title"
                                font.pixelSize: 13 * scaleFactor
                                color: Appearance.background
                                anchors.verticalCenter: parent.verticalCenter
                                elide: Text.ElideRight
                                font.bold: true
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
                                        font.pixelSize: 13 * scaleFactor
                                        font.family: Appearance.defaultFont
                                        color: Appearance.background
                                        font.bold: true
                                    }

                                    Text {
                                        text: mediaUtil.title || "Unknown Title"
                                        font.pixelSize: 13 * scaleFactor
                                        font.family: Appearance.defaultFont
                                        color: Appearance.background
                                        font.bold: true
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
                            width: 160 * scaleFactor
                            height: 14 * scaleFactor
                            anchors.horizontalCenter: parent.horizontalCenter
                            clip: true

                            Text {
                                id: artistText
                                visible: artistMetrics.width <= artistWrapper.width
                                text: mediaUtil.artist || "Unknown Artist"
                                font.family: Appearance.defaultFont
                                font.pixelSize: 11 * scaleFactor
                                color: Appearance.background
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
                                        font.pixelSize: 11 * scaleFactor
                                        font.family: Appearance.defaultFont
                                        color: Appearance.background
                                    }

                                    Text {
                                        text: mediaUtil.artist || "Unknown Artist"
                                        font.pixelSize: 11 * scaleFactor
                                        font.family: Appearance.defaultFont
                                        color: Appearance.background
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
                }

                RowLayout {
                    id: controlLayout
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 5 * scaleFactor
                    spacing: 10 * scaleFactor

                    Text {
                        text: mediaUtil.formattedTime
                        font.pixelSize: 10 * scaleFactor
                        color: Appearance.background
                    }

                    Item {
                        width: 20 * scaleFactor
                        height: 20 * scaleFactor

                        Text {
                            anchors.centerIn: parent
                            text: "skip_previous"
                            font.family: Appearance.materialSymbols
                            font.pixelSize: 18 * scaleFactor
                            color: Appearance.background
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: mediaPrev()
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    Item {
                        width: 20 * scaleFactor
                        height: 20 * scaleFactor

                        Text {
                            anchors.centerIn: parent
                            text: mediaUtil.isPlaying ? "pause" : "resume"
                            font.family: Appearance.materialSymbols
                            font.pixelSize: 18 * scaleFactor
                            color: Appearance.background
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: mediaPlayPause()
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    Item {
                        width: 20 * scaleFactor
                        height: 20 * scaleFactor

                        Text {
                            anchors.centerIn: parent
                            text: "skip_next"
                            font.family: Appearance.materialSymbols
                            font.pixelSize: 18 * scaleFactor
                            color: Appearance.background
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
}
