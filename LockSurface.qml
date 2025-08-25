import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Qt5Compat.GraphicalEffects
import Quickshell.Wayland
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.config
import qs.utils
import qs.widgets.bar.left
import qs.widgets.bar.right
import QtCore
import qs.widgets.sidebar

import Quickshell.Services.Pipewire

Rectangle {
    id: root
    color: Appearance.color
    visible: true
    required property LockContext context
    readonly property string wallpaperPath: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/Pictures/Wallpapers/Wallpaper.jpg"
    
    y: -200
    SequentialAnimation on y { NumberAnimation { to: 0; duration: 800; easing.type: Easing.OutCubic } }
    
    property PwNode node: Pipewire.defaultAudioSink;
	PwObjectTracker { objects: [ node ] }
    BrightnessUtil { id: brightnessUtil }

    Item {
        id: volumeHotCorner
        width: 60; height: 60
        anchors.top: parent.top
        anchors.left: parent.left
        z: 2

        Text {
            id: volumeIcon
            anchors.centerIn: parent
            text: "volume_up"
            font.family: Appearance.materialSymbols
            font.pixelSize: 32 * Appearance.scaleFactor
            color: "white"
            opacity: maVolume.containsMouse ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        MouseArea {
            id: maVolume
            anchors.fill: parent
            hoverEnabled: true
            onWheel: (wheel) => {
                var delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                node.audio.volume = Math.max(0, Math.min(1, node.audio.volume + delta))
            }
        }
    }

    Item {
        id: brightnessHotCorner
        width: 60; height: 60
        anchors.top: parent.top
        anchors.right: parent.right
        z: 2

        Text {
            id: brightnessIcon
            anchors.centerIn: parent
            text: "light_mode"
            font.family: Appearance.materialSymbols
            font.pixelSize: 32 * Appearance.scaleFactor
            color: "white"
            opacity: maBrightness.containsMouse ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        MouseArea {
            id: maBrightness
            anchors.fill: parent
            hoverEnabled: true
            onWheel: (wheel) => {
                var delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                brightnessUtil.brightness = Math.max(0, Math.min(1, brightnessUtil.brightness + delta))
            }
        }
    }

    Item {
        anchors.fill: parent

        Rectangle { anchors.fill: parent; color: Appearance.primary }

        Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            cache: false
            asynchronous: true
            source: wallpaperPath
        }

        Rectangle { anchors.fill: parent; color: "#000000"; opacity: 0.7 }
    }

    MediaUtil { id: mediaUtil }
    Process { id: playPauseProc; command: ["playerctl", "-p", "plasma-browser-integration", "play-pause"] }
    Process { id: nextProc; command: ["playerctl", "-p", "plasma-browser-integration", "next"] }
    Process { id: prevProc; command: ["playerctl", "-p", "plasma-browser-integration", "previous"] }
    function mediaPlayPause() { playPauseProc.running = true }
    function mediaNext() { nextProc.running = true }
    function mediaPrev() { prevProc.running = true }

    Item {
        id: profileUtil
        property string username: "Unknown"
        property string profileImage: "root:/assets/default-profile.png"

        Process {
            id: getUsernameProc
            command: ["whoami"]
            stdout: StdioCollector {
                onStreamFinished: {
                    const name = this.text.trim()
                    if (name.length > 0) {
                        profileUtil.username = name
                        const accIconPath = "/var/lib/AccountsService/icons/" + name
                        checkImage.command = ["sh", "-c", "test -f " + accIconPath + " && echo OK || echo NO"]
                        checkImage.running = true
                    }
                }
            }
        }

        Process {
            id: checkImage
            command: []
            stdout: StdioCollector {
                onStreamFinished: {
                    const iconPath = "/var/lib/AccountsService/icons/" + profileUtil.username
                    profileUtil.profileImage = (this.text.trim() === "OK")
                        ? "file://" + iconPath
                        : "root:/assets/default-profile.png"
                }
            }
        }

        Component.onCompleted: getUsernameProc.running = true
    }

    RowLayout{
        id: topBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 80
        // anchors.topMargin: 40 
        // anchors.leftMargin: 615 
        // anchors.rightMargin: 720 

        opacity: 0
        IndicatorWidget {}
        Item { Layout.fillWidth: true }
        SystemWidget {isInBar: false}

        SequentialAnimation on opacity { NumberAnimation { to: 1; duration: 800; easing.type: Easing.OutCubic } }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20 * Appearance.scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter

        ClippingWrapperRectangle {
            id: profilePic
            width: 200
            height: width
            radius: height / 2
            clip: true
            anchors.horizontalCenter: parent.horizontalCenter
            y: -400
            opacity: 0
            scale: 1.0

            Image { 
                source: profileUtil.profileImage
                fillMode: Image.PreserveAspectCrop
                smooth: true
                sourceSize.width: parent.width
                sourceSize.height: parent.height 
            }

            SequentialAnimation on y { NumberAnimation { to: 0; duration: 800; easing.type: Easing.OutCubic } }
            SequentialAnimation on opacity { NumberAnimation { to: 1; duration: 800; easing.type: Easing.OutCubic } }
            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { to: 1.05; duration: 1500; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutQuad }
            }
        }

        Label {
            id: usernameLabel
            text: profileUtil.username
            font.pointSize: 28 
            color: Appearance.white
            font.family: Appearance.bitcountFont
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: 0
            SequentialAnimation on opacity { NumberAnimation { to: 1; duration: 800; easing.type: Easing.OutQuad } }
        }

        TextField {
            id: passwordBox
            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: 300 
            implicitHeight: 50 
            padding: 12
            focus: true
            enabled: !root.context.unlockInProgress
            echoMode: TextInput.Password
            inputMethodHints: Qt.ImhSensitiveData
            horizontalAlignment: Text.AlignHCenter
            opacity: 0

            background: Rectangle {
                radius: 25 
                border.color: passwordBox.activeFocus ? Appearance.primary : Appearance.background
                border.width: 2
                color: "transparent"
            }

            font.pointSize: 16 
            color: Appearance.white
            placeholderText: "Enter password…"
            placeholderTextColor: Appearance.white

            onTextChanged: root.context.currentText = text
            onAccepted: root.context.tryUnlock()

            Connections { target: root.context
                function onCurrentTextChanged() { passwordBox.text = root.context.currentText }
            }

            SequentialAnimation on opacity { NumberAnimation { to: 1; duration: 1000; easing.type: Easing.OutQuad } }
        }

        Label {
            id: errorLabel
            color: "#ff5050"
            visible: root.context.showFailure
            font.family: Appearance.bitcountFont
            text: "Incorrect password"
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 16 * Appearance.scaleFactor
            opacity: 0
            SequentialAnimation on opacity { NumberAnimation { to: 1; duration: 500; easing.type: Easing.OutQuad } }
        }

        ColumnLayout {
            id: bottomColumn
            spacing: 6
            opacity: 0
            // Layout.topMargin: 100 * Appearance.scaleFactor
            SequentialAnimation on opacity { NumberAnimation { to: 1; duration: 1000; easing.type: Easing.OutCubic } }

            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 50

                ColumnLayout {
                    x : -200
                    SequentialAnimation on x { NumberAnimation { to: 0; duration: 800; easing.type: Easing.OutCubic } }
                    
                    Label {
                        id: clock
                        property var date: new Date()
                        font.pointSize: 16
                        color: Appearance.white
                        font.family: Appearance.bitcountFont

                        Timer { running: true; repeat: true; interval: 1000; onTriggered: clock.date = new Date() }

                        text: { const h = clock.date.getHours().toString().padStart(2,"0"); const m = clock.date.getMinutes().toString().padStart(2,"0"); return `${h}:${m}` }
                    }

                    Label {
                        id: dateLabel
                        property var date: new Date()
                        font.pointSize: 12
                        color: Appearance.white
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family: Appearance.bitcountFont

                        Timer { running: true; repeat: true; interval: 60000; onTriggered: dateLabel.date = new Date() }

                        text: Qt.formatDate(date, "ddd dd • MMMM • yyyy")
                    }
                }

                Item { Layout.fillWidth: true }
                MediaWidget { iconSize: 28 }

                Column {
                    spacing: 8
                    opacity: 0

                    SequentialAnimation on opacity { NumberAnimation { to: 1; duration: 500; easing.type: Easing.OutQuad } }

                    Item {
                        width: 200 * Appearance.scaleFactor
                        height: 16 * Appearance.scaleFactor
                        clip: true

                        TextMetrics { id: titleMetrics; text: mediaUtil.title || "No Media Found"; font.pixelSize: 14 * Appearance.scaleFactor; font.bold: true }

                        Text {
                            visible: titleMetrics.width <= parent.width
                            anchors.verticalCenter: parent.verticalCenter
                            text: mediaUtil.title || "No Media Found"
                            font.pixelSize: 14 * Appearance.scaleFactor
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

                                Text { text: mediaUtil.title || "No Media Found"; font.pixelSize: 14 * Appearance.scaleFactor; font.bold: true; color: Appearance.white }
                                Text { text: mediaUtil.title || "No Media Found"; font.pixelSize: 14 * Appearance.scaleFactor; font.bold: true; color: Appearance.white }
                            }

                            NumberAnimation on offset { from: 0; to: -(titleMetrics.width + 40); duration: (titleMetrics.width + 40) * 40; loops: Animation.Infinite; running: true }
                        }
                    }

                    Item {
                        width: 330 * Appearance.scaleFactor
                        height: 14 * Appearance.scaleFactor
                        clip: true

                        TextMetrics { id: artistMetrics; text: mediaUtil.artist || "Open music player app to start"; font.pixelSize: 12 * Appearance.scaleFactor }

                        Text {
                            visible: artistMetrics.width <= parent.width
                            anchors.verticalCenter: parent.verticalCenter
                            text: mediaUtil.artist || "Open music player app to start"
                            font.pixelSize: 12 * Appearance.scaleFactor
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

                                Text { text: mediaUtil.artist || "Open music player app to start"; font.pixelSize: 12 * Appearance.scaleFactor; color: Appearance.white }
                                Text { text: mediaUtil.artist || "Open music player app to start"; font.pixelSize: 12 * Appearance.scaleFactor; color: Appearance.white }
                            }

                            NumberAnimation on offset { from: 0; to: -(artistMetrics.width + 40); duration: (artistMetrics.width + 40) * 40; loops: Animation.Infinite; running: true }
                        }
                    }
                }

                Row {
                    x: 900
                    spacing: 25 * Appearance.scaleFactor
                    SequentialAnimation on x { NumberAnimation { to: 700; duration: 800; easing.type: Easing.OutCubic } }

                    Item {
                        width: 18*Appearance.scaleFactor; height:18*Appearance.scaleFactor
                        Text { anchors.centerIn: parent; text: "skip_previous"; font.family: Appearance.materialSymbols; font.pixelSize: 18*Appearance.scaleFactor; color: Appearance.white }
                        MouseArea { 
                            anchors.fill: parent
                            onClicked: {
                                mediaPrev()
                                // reset opacity & fade
                                mediaColumn.opacity = 0
                                fadeAnim.start()
                                // reset y & slide-in lagi
                                mediaColumn.y = 200
                                yAnim.start()
                            }
                            cursorShape: Qt.PointingHandCursor 
                        }
                    }

                    Item {
                        width: 18*Appearance.scaleFactor; height:18*Appearance.scaleFactor
                        Text { anchors.centerIn: parent; text: mediaUtil.isPlaying ? "pause" : "resume"; font.family: Appearance.materialSymbols; font.pixelSize: 18*Appearance.scaleFactor; color: Appearance.white }
                        MouseArea { anchors.fill: parent; onClicked: mediaPlayPause(); cursorShape: Qt.PointingHandCursor }
                    }

                    Item {
                        width: 18*Appearance.scaleFactor; height:18*Appearance.scaleFactor
                        Text { anchors.centerIn: parent; text: "skip_next"; font.family: Appearance.materialSymbols; font.pixelSize: 18*Appearance.scaleFactor; color: Appearance.white }
                        MouseArea { 
                            anchors.fill: parent
                            onClicked: {
                                mediaNext()
                                mediaColumn.opacity = 0
                                fadeAnim.start()
                                mediaColumn.y = 200
                                yAnim.start()
                            } 
                            cursorShape: Qt.PointingHandCursor 
                        }
                    }
                }
            }
            ColumnLayout {
                id: mediaColumn
                anchors.horizontalCenter: parent.horizontalCenter
                y: 200
                opacity: 1

                Layout.topMargin: 50 * Appearance.scaleFactor

                SequentialAnimation {
                    id: yAnim
                    running: true
                    NumberAnimation { target: mediaColumn; property: "y"; from: 200; to: 100; duration: 800; easing.type: Easing.OutCubic }
                }

                ClippingWrapperRectangle {
                    width: 300 * Appearance.scaleFactor
                    height: 180 * Appearance.scaleFactor
                    radius: 12 * Appearance.scaleFactor

                    opacity: mediaUtil.title && mediaUtil.title !== "No Media Found" ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

                    Item {
                        id: container
                        anchors.fill: parent

                        Rectangle { anchors.fill: parent; color: Appearance.primary }

                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            cache: false
                            asynchronous: true
                            source: mediaUtil.coverSource
                        }


                        Rectangle { anchors.fill: parent; color: "#000000"; opacity: 0.2 }
                    }
                }

                NumberAnimation {
                    id: fadeAnim
                    target: mediaColumn
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 600
                    easing.type: Easing.OutCubic
                    running: false
                }
            }
        }
    }
}
