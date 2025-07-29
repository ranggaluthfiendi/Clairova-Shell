import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.config
import qs.utils

ColumnLayout {
    id: transparentStrengthSlider
    width: parent.width
    spacing: 6 * Appearance.scaleFactor

    property real strength: util.currentStrength

    TransparentStrengthUtil { id: util }

    Connections {
        target: util
        // onStrengthLoaded: strength = strengthValue
    }

    RowLayout {
        spacing: 12 * Appearance.scaleFactor
        Layout.fillWidth: true
        Layout.margins: 8 * Appearance.scaleFactor

        Label {
            text: "Transparent Strength"
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
            width: strengthSlider.visualPosition * sliderArea.width
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
            id: strengthSlider
            anchors.fill: parent
            from: 0.0
            to: 1.0
            stepSize: 0.01
            value: strength
            background: null
            handle: null

            onMoved: {
                strength = value
                util.applyStrength(value)
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.margins: 8 * Appearance.scaleFactor
        spacing: 8 * Appearance.scaleFactor

        Text {
            text: "Strength: " + strength.toFixed(2)
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
                    strength = util.defaultStrength
                    util.resetStrength()
                }
            }
        }
    }
}
