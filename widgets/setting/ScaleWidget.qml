import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.config
import qs.utils

ColumnLayout {
    id: scaleSlider
    width: parent.width
    spacing: 6 * Appearance.scaleFactor

    property real scaleValue: util.currentScale
    property real pendingScale: util.currentScale // untuk slider

    ScaleUtil { id: util }

    Connections {
        target: util
        onScaleLoaded: {
            scaleValue = scale
            pendingScale = scale
        }
    }

    RowLayout {
        spacing: 12 * Appearance.scaleFactor
        Layout.fillWidth: true
        Layout.margins: 8 * Appearance.scaleFactor

        Label {
            text: "UI Scale"
            font.pixelSize: 14 * Appearance.scaleFactor
            color: Appearance.white
            font.family: Appearance.defaultFont
        }
    }

    Rectangle {
        id: sliderArea
        Layout.fillWidth: true
        Layout.margins: 8 * Appearance.scaleFactor
        height: 6 * Appearance.scaleFactor
        radius: height / 2
        color: Appearance.background
        clip: true

        Rectangle {
            id: filledTrack
            width: scaleSliderItem.visualPosition * sliderArea.width
            height: parent.height
            radius: height / 2
            color: Appearance.white
        }

        Repeater {
            model: 10
            delegate: Rectangle {
                width: 2 * Appearance.scaleFactor
                height: 2 * Appearance.scaleFactor
                radius: width / 2
                color: "#888888"
                anchors.verticalCenter: parent.verticalCenter
                x: (index / 9) * (sliderArea.width - width)
            }
        }

        Slider {
            id: scaleSliderItem
            anchors.fill: parent
            from: 1
            to: 1.5
            stepSize: 0.01
            value: pendingScale
            background: null
            handle: null

            onMoved: {
                pendingScale = value
                // Jangan langsung apply
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.margins: 8 * Appearance.scaleFactor
        spacing: 8 * Appearance.scaleFactor

        Text {
            text: "Scale: " + pendingScale.toFixed(2)
            font.pixelSize: 14 * Appearance.scaleFactor
            color: Appearance.white
            font.family: Appearance.defaultFont
        }

        Item { Layout.fillWidth: true }

        RowLayout {
            spacing: 4 * Appearance.scaleFactor

            Text {
                text: "undo"
                font.pixelSize: 14 * Appearance.scaleFactor
                color: Appearance.white
                font.family: Appearance.materialSymbols
            }

            Text {
                text: "Reset"
                font.pixelSize: 14 * Appearance.scaleFactor
                color: Appearance.white
                font.family: Appearance.defaultFont
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    pendingScale = util.defaultScale
                    scaleValue = util.defaultScale
                    util.resetScale()
                }
            }
        }

        RowLayout {
            spacing: 4 * Appearance.scaleFactor

            Text {
                text: "save"
                font.pixelSize: 14 * Appearance.scaleFactor
                color: Appearance.white
                font.family: Appearance.materialSymbols
            }

            Text {
                text: "Save"
                font.pixelSize: 14 * Appearance.scaleFactor
                color: Appearance.white
                font.family: Appearance.defaultFont
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    scaleValue = pendingScale
                    util.applyScale(scaleValue)
                }
            }
        }
    }
}
