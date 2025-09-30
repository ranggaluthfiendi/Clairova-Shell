import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.config
import qs.utils

ColumnLayout {
    id: accentSlider
    width: parent.width
    spacing: 6 * Appearance.scaleFactor

    property bool thumbVisible: false
    property real lastAppliedHue: accent.hexToHue(accent.currentColor)
    property bool isModified: false
    property bool expanded: false

    AccentUtil { id: accent }
    PasteUtil {
        id: pasteUtil
        onValidHexColor: (hex, rgba) => {
            Appearance.white = rgba
            hueSlider.value = accent.hexToHue(hex)
            thumbVisible = true
            isModified = (hex !== accent.defaultColor.toLowerCase())
        }
    }

    RowLayout {
        spacing: 12 * Appearance.scaleFactor
        Layout.fillWidth: true
        Layout.margins: 8 * Appearance.scaleFactor

        Label {
            text: "Accent"
            font.pixelSize: 14 * Appearance.scaleFactor
            color: Appearance.white
            font.family: Appearance.defaultFont
        }

        Rectangle {
            width: 14 * Appearance.scaleFactor
            height: 14 * Appearance.scaleFactor
            radius: 3 * Appearance.scaleFactor
            color: Appearance.white
            border.color: "white"
            border.width: 1
            antialiasing: true
        }

        Item { Layout.fillWidth: true }

        RowLayout {
            visible: !expanded
            spacing: 4 * Appearance.scaleFactor

            Text {
                text: "palette"
                font.pixelSize: 14 * Appearance.scaleFactor
                color: Appearance.white
                font.family: Appearance.materialSymbols
            }

            Text {
                text: "Change Color"
                font.pixelSize: 14 * Appearance.scaleFactor
                color: Appearance.white
                font.family: Appearance.defaultFont
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: expanded = true
            }
        }

        RowLayout {
            visible: expanded
            spacing: 4 * Appearance.scaleFactor

            Text {
                text: "undo"
                font.pixelSize: 14 * Appearance.scaleFactor
                color: Appearance.white
                font.family: Appearance.materialSymbols
            }

            Text {
                text: "Reset Color"
                font.pixelSize: 14 * Appearance.scaleFactor
                color: Appearance.white
                font.family: Appearance.defaultFont
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    accent.resetColor()
                    hueSlider.value = accent.hexToHue(accent.defaultColor)
                    lastAppliedHue = hueSlider.value
                    isModified = false
                    thumbVisible = false
                    expanded = false
                }
            }
        }

        RowLayout {
            visible: expanded
            spacing: 4 * Appearance.scaleFactor

            Text {
                text: "save"
                font.pixelSize: 14 * Appearance.scaleFactor
                color: Appearance.white
                font.family: Appearance.materialSymbols
            }

            Text {
                text: "Save Color"
                font.pixelSize: 14 * Appearance.scaleFactor
                color: Appearance.white
                font.family: Appearance.defaultFont
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const hex = accent.colorToHex(Appearance.white)
                    accent.applyColor(hex)
                    const currentHue = accent.hexToHue(hex)
                    lastAppliedHue = currentHue
                    isModified = (hex.toLowerCase() !== accent.defaultColor.toLowerCase())
                    thumbVisible = isModified
                    expanded = false
                }
            }
        }
    }

    Rectangle {
        id: sliderArea
        visible: expanded
        Layout.alignment: Qt.AlignHCenter
        width: 360 * Appearance.scaleFactor
        height: 18 * Appearance.scaleFactor
        radius: 10 * Appearance.scaleFactor
        color: "transparent"
        clip: true

        Canvas {
            id: hueCanvas
            anchors.fill: parent
            contextType: "2d"
            onPaint: {
                const ctx = getContext("2d")
                const w = width
                const h = height
                const r = 8 * Appearance.scaleFactor

                ctx.clearRect(0, 0, w, h)
                ctx.beginPath()
                ctx.moveTo(r, 0)
                ctx.lineTo(w - r, 0)
                ctx.quadraticCurveTo(w, 0, w, r)
                ctx.lineTo(w, h - r)
                ctx.quadraticCurveTo(w, h, w - r, h)
                ctx.lineTo(r, h)
                ctx.quadraticCurveTo(0, h, 0, h - r)
                ctx.lineTo(0, r)
                ctx.quadraticCurveTo(0, 0, r, 0)
                ctx.closePath()
                ctx.clip()

                const grad = ctx.createLinearGradient(0, 0, w, 0)
                for (let i = 0; i <= 360; i++) {
                    grad.addColorStop(i / 360, `hsl(${i}, 100%, 50%)`)
                }

                ctx.fillStyle = grad
                ctx.fillRect(0, 0, w, h)
            }
        }

        Rectangle {
            id: thumb
            width: 4 * Appearance.scaleFactor
            height: parent.height
            radius: width / 2
            anchors.verticalCenter: parent.verticalCenter
            x: hueSlider.visualPosition * (sliderArea.width - width)
            visible: thumbVisible
            color: "white"
            border.color: Appearance.white
            border.width: 2
            z: 2

            layer.enabled: true
            layer.effect: DropShadow {
                color: Appearance.white
                radius: 10 * Appearance.scaleFactor
                samples: 30
                horizontalOffset: 0
                verticalOffset: 0
            }

            SequentialAnimation on opacity {
                id: blinkAnim
                running: thumbVisible && isModified
                loops: Animation.Infinite
                NumberAnimation { to: 0.5; duration: 400; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 1.0; duration: 400; easing.type: Easing.InOutQuad }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            drag.target: hueSlider
            cursorShape: Qt.PointingHandCursor

            Slider {
                id: hueSlider
                anchors.fill: parent
                from: 0
                to: 360
                value: 0
                background: null
                handle: null

                onMoved: {
                    const hex = accent.hueToHex(value)
                    Appearance.white = Qt.color(hex)
                    thumbVisible = true
                    isModified = (hex.toLowerCase() !== accent.defaultColor.toLowerCase())
                }
            }
        }
    }

    RowLayout {
        visible: expanded
        spacing: 16 * Appearance.scaleFactor
        Layout.fillWidth: true
        Layout.margins: 8 * Appearance.scaleFactor

        Text {
            id: colorText
            text: accent.colorToHex(Appearance.white)
            font.pixelSize: 14 * Appearance.scaleFactor
            color: Appearance.white
            font.family: Appearance.defaultFont
        }

        RowLayout {
            spacing: 4 * Appearance.scaleFactor

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const hex = colorText.text.trim()
                    Quickshell.clipboardText = hex
                }
            }

            Text {
                text: "content_copy"
                font.pixelSize: 14 * Appearance.scaleFactor
                color: Appearance.white
                font.family: Appearance.materialSymbols
            }

            Text {
                text: "Copy"
                font.pixelSize: 14 * Appearance.scaleFactor
                color: Appearance.white
                font.family: Appearance.defaultFont
            }
        }

        RowLayout {
            spacing: 4 * Appearance.scaleFactor

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    pasteUtil.paste()
                }
            }

            Text {
                text: "content_paste"
                font.pixelSize: 14 * Appearance.scaleFactor
                color: Appearance.white
                font.family: Appearance.materialSymbols
            }

            Text {
                text: "Paste"
                font.pixelSize: 14 * Appearance.scaleFactor
                color: Appearance.white
                font.family: Appearance.defaultFont
            }
        }
    }

    Connections {
        target: accent
        onColorLoaded: (hexColor) => {
            hueSlider.value = accent.hexToHue(hexColor)
            lastAppliedHue = hueSlider.value
            isModified = (hexColor.toLowerCase() !== accent.defaultColor.toLowerCase())
            thumbVisible = isModified
        }
    }

    Component.onCompleted: {
        hueSlider.value = accent.hexToHue(accent.currentColor)
        lastAppliedHue = hueSlider.value
        isModified = (accent.currentColor.toLowerCase() !== accent.defaultColor.toLowerCase())
        thumbVisible = isModified
    }
}
