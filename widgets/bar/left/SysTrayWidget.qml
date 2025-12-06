pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import qs.config

Item {
    id: root
    Layout.leftMargin: 5 * Appearance.scaleFactor
    visible: SystemTray.items.values.length > 0
    implicitHeight: visible ? column.implicitHeight : 0
    implicitWidth: visible ? column.implicitWidth : 0

    property var currentMainMenu: null
    property var currentSubMenu: null
    property var currentPulseIcon: null

    function closeAll() {
        if (currentMainMenu) currentMainMenu.visible = false
        if (currentSubMenu) currentSubMenu.visible = false
        if (currentPulseIcon) { currentPulseIcon.stopPulse(); currentPulseIcon = null }
        currentMainMenu = null
        currentSubMenu = null
    }

    function pulseStart(iconObj) {
        if (currentPulseIcon && currentPulseIcon !== iconObj)
            currentPulseIcon.stopPulse()
        currentPulseIcon = iconObj
        if (iconObj && iconObj.startPulse) iconObj.startPulse()
    }

    function pulseStop(iconObj) {
        if (currentPulseIcon === iconObj) {
            if (iconObj && iconObj.stopPulse) iconObj.stopPulse()
            currentPulseIcon = null
        }
    }

    RowLayout {
        id: column
        spacing: 4 * Appearance.scaleFactor

        Repeater {
            model: SystemTray.items.values

            Rectangle {
                required property SystemTrayItem modelData

                width: 28 * Appearance.scaleFactor
                height: 28 * Appearance.scaleFactor
                radius: 6 * Appearance.scaleFactor

                property bool hovered: false
                property bool pressed: false
                property bool active: root.currentMainMenu === customMenu
                property bool invalidIcon: !modelData

                color: invalidIcon ? "transparent" :
                       active
                        ? Qt.rgba(Appearance.background.r, Appearance.background.g, Appearance.background.b, 0.6)
                        : pressed
                            ? Qt.rgba(Appearance.color.r, Appearance.color.g, Appearance.color.b, 0.8)
                            : hovered
                                ? Qt.rgba(Appearance.background.r, Appearance.background.g, Appearance.background.b, 0.4)
                                : "transparent"

                border.color: (active || hovered) ? Appearance.white : "transparent"

                Image {
                    id: icon
                    anchors.centerIn: parent
                    source: invalidIcon ? "" : (modelData.icon || "")
                    width: 16 * Appearance.scaleFactor
                    height: 16 * Appearance.scaleFactor
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    scale: 1.0

                    function startPulse() { pulse.running = true }
                    function stopPulse() { pulse.running = false; icon.scale = 1 }

                    transform: Scale {
                        origin.x: icon.width / 2
                        origin.y: icon.height / 2
                        xScale: icon.scale
                        yScale: icon.scale
                    }

                    SequentialAnimation {
                        id: pulse
                        running: false
                        loops: Animation.Infinite
                        NumberAnimation { target: icon; property: "scale"; from: 1; to: 1.1; duration: 350 }
                        NumberAnimation { target: icon; property: "scale"; from: 1.1; to: 1; duration: 350 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onEntered: {
                        parent.hovered = true
                        root.pulseStart(icon)
                    }

                    onExited: {
                        parent.hovered = false
                        if (!parent.active)
                            root.pulseStop(icon)
                    }

                    onPressed: parent.pressed = true
                    onReleased: parent.pressed = false

                    onClicked: {
                        if (!customMenu.visible)
                            root.closeAll()

                        customMenu.visible = !customMenu.visible

                        if (customMenu.visible)
                            root.pulseStart(icon)
                        else
                            root.pulseStop(icon)

                        root.currentMainMenu = customMenu.visible ? customMenu : null
                    }
                }

                QsMenuOpener { id: opener; menu: modelData ? modelData.menu : null }

                PopupWindow {
                    id: customMenu
                    visible: false
                    color: "transparent"
                    implicitWidth: 180 * Appearance.scaleFactor
                    implicitHeight: menuColumn.implicitHeight + 20 * Appearance.scaleFactor
                    anchor.item: icon

                    anchor.margins.top: 12 * Appearance.scaleFactor

                    Rectangle {
                        anchors.fill: parent
                        radius: 8 * Appearance.scaleFactor
                        color: Appearance.currentBackground
                        clip: true
                        anchors.topMargin: 20 * Appearance.scaleFactor

                        Column {
                            id: menuColumn
                            width: parent ? parent.width : (180 * Appearance.scaleFactor)
                            spacing: 2
                            padding: 4

                            Repeater {
                                model: opener ? opener.children : []

                                delegate: Item {
                                    required property QsMenuEntry modelData
                                    property bool invalid: modelData === null || modelData === undefined

                                    
                                    property real delegateWidth: parent ? parent.width : (180 * Appearance.scaleFactor)
                                    width: delegateWidth
                                    height: invalid ? 0 : (modelData.isSeparator ? 8 : 26)
                                    visible: !invalid

                                    Rectangle {
                                        visible: !invalid && modelData.isSeparator
                                        width: delegateWidth - 10
                                        height: 1
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        color: "#444"
                                    }

                                    Rectangle {
                                        id: entryRect
                                        visible: !invalid && !modelData.isSeparator
                                        anchors.fill: parent
                                        anchors.rightMargin: 8
                                        color: hoverArea.containsMouse
                                            ? Qt.rgba(Appearance.color.r, Appearance.color.g, Appearance.color.b, 0.25)
                                            : "transparent"
                                        radius: 5

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.leftMargin: 10
                                            anchors.left: parent.left
                                            text: invalid ? "" : (modelData.text || "")
                                            color: invalid ? "white" : (modelData.enabled ? "white" : "#666")
                                            elide: Text.ElideRight
                                        }

                                        MouseArea {
                                            id: hoverArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor

                                            onClicked: {
                                                if (invalid) return;

                                                if (modelData.hasChildren) {

                                                    if (subLoader.item && subLoader.item.visible) {
                                                        subLoader.item.visible = false;
                                                        return;
                                                    }

                                                    if (subLoader.item)
                                                        subLoader.item.openAt(entryRect);

                                                } else {
                                                    try { modelData.triggered() } catch(e) {}
                                                    customMenu.visible = false
                                                }
                                            }

                                        }
                                    }

                                    Loader {
                                        id: subLoader
                                        sourceComponent: (!invalid && modelData.hasChildren) ? subPopupComp : null
                                        onLoaded: {
                                            if (item) {
                                                try { item.qsmenu = modelData } catch(e) {}
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: subPopupComp

        PopupWindow {
            id: subPopup
            visible: false
            color: "transparent"
            property var qsmenu: null
            implicitWidth: 180 * Appearance.scaleFactor
            implicitHeight: column.implicitHeight + 20 * Appearance.scaleFactor

            function openAt(item) {
                if (!item) return
                if (root.currentSubMenu && root.currentSubMenu !== subPopup)
                    root.currentSubMenu.visible = false
                anchor.item = item
                anchor.edges = Edges.Left
                anchor.gravity = Edges.Right

                var itemWidth = (item && typeof item.width === "number") ? item.width : (100 * Appearance.scaleFactor)
                anchor.margins.left = itemWidth + 8 * Appearance.scaleFactor
                anchor.margins.top = 24 * Appearance.scaleFactor
                visible = true
            }

            onVisibleChanged: {
                if (visible)
                    root.currentSubMenu = subPopup
                else if (root.currentSubMenu === subPopup)
                    root.currentSubMenu = null
            }

            Rectangle {
                anchors.fill: parent
                radius: 6 * Appearance.scaleFactor
                color: Appearance.currentBackground
                clip: true
                anchors.topMargin: 10 * Appearance.scaleFactor

                Column {
                    id: column
                    width: parent ? parent.width : (180 * Appearance.scaleFactor)
                    spacing: 2
                    padding: 4

                    Repeater {
                        model: subOpener ? subOpener.children : []

                        delegate: Item {
                            required property QsMenuEntry modelData
                            property bool invalid: modelData === null || modelData === undefined

                            property real delegateWidth: parent ? parent.width : (180 * Appearance.scaleFactor)
                            width: delegateWidth
                            height: invalid ? 0 : (modelData.isSeparator ? 8 : 26)
                            visible: !invalid

                            Rectangle {
                                visible: !invalid && modelData.isSeparator
                                width: delegateWidth - 10
                                height: 1
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: "#444"
                            }

                            Rectangle {
                                anchors.fill: parent
                                anchors.rightMargin: 8
                                radius: 5
                                color: hover.containsMouse
                                    ? Qt.rgba(Appearance.color.r, Appearance.color.g, Appearance.color.b, 0.25)
                                    : "transparent"

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: 10
                                    anchors.left: parent.left
                                    text: invalid ? "" : (modelData.text || "")
                                    color: invalid ? "white" : (modelData.enabled ? "white" : "#666")
                                    elide: Text.ElideRight
                                }

                                MouseArea {
                                    id: hover
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        if (!invalid) {
                                            try { modelData.triggered() } catch(e) {}
                                            subPopup.visible = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            QsMenuOpener { id: subOpener; menu: subPopup.qsmenu }
        }
    }
}
