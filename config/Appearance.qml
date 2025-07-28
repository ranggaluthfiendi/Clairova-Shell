pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: appearance

    // Font Families
    readonly property string materialSymbols: "Material Symbols Rounded"
    readonly property string defaultFont: "Rubik"
    readonly property string bitcountFont: "Bitcount Single"
    readonly property string bitcountFontLight: "Bitcount Single Light"

    // Scaling size widgets
    // Recomended scale is between: 1.35 - 1.6, very good with 1440p laptops
    // Recomended scale for 1080p laptop is: 1 - 1.3
    // scaleFactor 1.7+ is bad
    readonly property real scaleFactor: 1.2

    // Color
    property color background: "#2E2C30"
    property color color: "#1F1F1F"
    property color white: "#cacaca"
    property color primary: "#a6eeb9"

    readonly property color background2: Qt.rgba(
        Qt.colorEqual(background, "transparent") ? 0 : Qt.darker(background).r,
        background.g,
        background.b,
        0.5
    )
    readonly property color color2: Qt.rgba(
        color.r,
        color.g,
        color.b,
        0.5
    )


    // Toggle state (new!)
    property bool useTransparent: false

    // Computed active color (new!)
    property color currentBackground: useTransparent ? color2 : color
    
    // font size
    readonly property int small: 10
    readonly property int normal: 12
    readonly property int large: 16
    readonly property int extraLarge: 24
}