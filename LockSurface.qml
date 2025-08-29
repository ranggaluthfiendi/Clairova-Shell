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
import Quickshell.Services.Mpris

Rectangle { 
    id: root 
    color: Appearance.color 
    visible: true 
    focus: true 
    required property LockContext context 
    readonly property string wallpaperPath: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/Pictures/Wallpapers/Wallpaper.jpg" 
    y: -200 
    
    SequentialAnimation on y { NumberAnimation { to: 0; duration: 800; easing.type: Easing.OutCubic } } 
    
    property PwNode node: Pipewire.defaultAudioSink; 
    
    PwObjectTracker { objects: [ node ] } 
    
    BrightnessUtil { id: brightnessUtil } 
    
    Component.onCompleted: { passwordBox.focus = false } 
    
    MediaCoverUtil {
        id: coverUtil
        trackArtUrl: currentPlayer.trackArtUrl
    }

    property MprisPlayer currentPlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

    MediaUtil { id: mediaUtil }

    

    function mediaPlayPause() {
        if (currentPlayer && currentPlayer.canTogglePlaying) {
            currentPlayer.togglePlaying()
        }
    }

    function mediaNext() {
        if (currentPlayer && currentPlayer.canGoNext) {
            currentPlayer.next()
        }
    }

    function mediaPrev() {
        if (currentPlayer && currentPlayer.canGoPrevious) {
            currentPlayer.previous()
        }
    }

    function mediaTitle() {
        return currentPlayer ? (currentPlayer.trackTitle || "No Media Found") : "No Media Found"
    }

    function mediaArtist() {
        return currentPlayer ? (currentPlayer.trackArtist || "Open music player app to start") : "Open music player app to start"
    }

    Keys.onPressed: (event) => { if ((event.key === Qt.Key_Space || event.key === Qt.Key_Tab) && !passwordBox.focus) { passwordBox.forceActiveFocus() } } 
    
    MouseArea { 
        id: unfocusArea 
        anchors.fill: parent 
        acceptedButtons: Qt.LeftButton 
        propagateComposedEvents: true 
        onClicked: { if (!passwordBox.containsMouse) { passwordBox.focus = false } } 
    } 
    
    Item { 
        id: volumeHotCorner 
        width: 60
        height: 60
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
            scale: 1.0

            transform: Scale {
                origin.x: volumeIcon.width / 2
                origin.y: volumeIcon.height / 2
                xScale: volumeIcon.scale
                yScale: volumeIcon.scale
            }

            Behavior on opacity { NumberAnimation { duration: 200 } }
            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        } 
        
        Timer {
            id: volumeScaleLoop
            interval: 400
            repeat: true
            running: false
            onTriggered: {
                volumeIcon.scale = (volumeIcon.scale > 1.0) ? 1.0 : 1.1
            }
        }

        MouseArea { 
            id: maVolume 
            anchors.fill: parent 
            hoverEnabled: true 

            onEntered: volumeScaleLoop.start()
            onExited: {
                volumeScaleLoop.stop()
                volumeIcon.scale = 1.0
            }

            onWheel: (wheel) => { 
                var delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05 
                node.audio.volume = Math.max(0, Math.min(1, node.audio.volume + delta)) 
            } 
        } 
    }


    Item { 
        id: brightnessHotCorner 
        width: 60
        height: 60
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
            scale: 1.0

            transform: Scale {
                origin.x: brightnessIcon.width / 2
                origin.y: brightnessIcon.height / 2
                xScale: brightnessIcon.scale
                yScale: brightnessIcon.scale
            }

            Behavior on opacity { NumberAnimation { duration: 200 } }
            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        } 

        Timer {
            id: brightnessScaleLoop
            interval: 400
            repeat: true
            running: false
            onTriggered: {
                brightnessIcon.scale = (brightnessIcon.scale > 1.0) ? 1.0 : 1.1
            }
        }

        MouseArea { 
            id: maBrightness 
            anchors.fill: parent 
            hoverEnabled: true 

            onEntered: brightnessScaleLoop.start()
            onExited: {
                brightnessScaleLoop.stop()
                brightnessIcon.scale = 1.0
            }

            onWheel: (wheel) => { 
                var delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05 
                brightnessUtil.brightness = Math.max(0, Math.min(1, brightnessUtil.brightness + delta)) 
            } 
        } 
    }


    Item { 
        anchors.fill: parent 
        
        Rectangle { 
            anchors.fill: parent; 
            color: Appearance.color 
        } 
        
        Image { 
            anchors.fill: parent 
            fillMode: Image.PreserveAspectCrop 
            cache: false 
            asynchronous: true 
            source: wallpaperPath 
        } 
        
        Rectangle { 
            anchors.fill: parent; 
            color: "#000000"; 
            opacity: 0.7 
        } 
    } 
    
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
                    profileUtil.profileImage = (this.text.trim() === "OK") ? "file://" + iconPath : "root:/assets/default-profile.png" 
                } 
            } 
        } 
        
        Component.onCompleted: getUsernameProc.running = true 
    } 
    
    RowLayout { 
        id: topBar 
        anchors.bottom: parent.bottom 
        anchors.left: parent.left 
        anchors.right: parent.right 
        anchors.margins: 80 
        opacity: 0 
        property real initialY: y 
        y: parent.height + height 
        
        ColumnLayout { 
            spacing: 12 
            Rectangle { 
                id: powerButton 
                width: 32 * Appearance.scaleFactor 
                height: 32 * Appearance.scaleFactor 
                radius: 10 
                color: Appearance.primary 
                scale: 1.0 

                // Animasi pulse unik tiap 3 detik
                SequentialAnimation on scale {
                    id: pulseAnim
                    loops: Animation.Infinite
                    running: !maPower.containsMouse && !maPower.pressed
                    NumberAnimation { to: 1.2; duration: 250; easing.type: Easing.OutBack }
                    NumberAnimation { to: 1.0; duration: 250; easing.type: Easing.InBack }
                    PauseAnimation { duration: 2500 } // jeda 2.5 detik biar total 3 detik siklus
                }

                Process { 
                    id: powerProc; 
                    command: [] 
                } 

                MouseArea { 
                    id: maPower
                    anchors.fill: parent 
                    cursorShape: Qt.PointingHandCursor 
                    hoverEnabled: true 

                    onEntered: powerButton.scale = 1.1
                    onExited: powerButton.scale = 1.0
                    onClicked: { 
                        confirmDialogPower.visible = !confirmDialogPower.visible 
                        confirmDialogReboot.visible = false 
                    } 
                } 

                Text { 
                    anchors.centerIn: parent
                    text: "power_settings_new"
                    color: Appearance.color
                    font.family: Appearance.materialSymbols
                    font.pixelSize: 20 * Appearance.scaleFactor 
                } 

                Rectangle { 
                    id: confirmDialogPower 
                    visible: false
                    width: 85
                    height: 30
                    radius: 8
                    color: powerButton.color
                    anchors.verticalCenter: parent.verticalCenter 
                    anchors.left: parent.right
                    anchors.leftMargin: 8 
                    
                    RowLayout { 
                        anchors.fill: parent
                        anchors.margins: 6 
                        spacing: 4 
                        
                        Text { 
                            text: "Shutdown?" 
                            color: Appearance.color 
                            anchors.verticalCenter: parent.verticalCenter 
                            verticalAlignment: Text.AlignVCenter 
                            font.bold: true 
                            Layout.rightMargin: 8 
                        } 
                        
                        Rectangle { 
                            width: 40; height: 28 
                            radius: 6 
                            color: powerButton.color 
                            border.color: Appearance.color 
                            border.width: 1 
                            anchors.verticalCenter: parent.verticalCenter 
                            
                            Text { 
                                anchors.centerIn: parent 
                                font.family: Appearance.materialSymbols 
                                text: "check" 
                                color: Appearance.color 
                                font.bold: true 
                            } 
                            
                            MouseArea { 
                                anchors.fill: parent 
                                onClicked: { 
                                    powerProc.command = ["sh", "-c", "systemctl poweroff"] 
                                    powerProc.running = true 
                                    confirmDialogPower.visible = false 
                                } 
                                hoverEnabled: true 
                                onEntered: parent.opacity = 0.8
                                onExited: parent.opacity = 1.0
                                cursorShape: Qt.PointingHandCursor 
                            } 
                        } 
                        
                        Rectangle {
                            width: 40; height: 28
                            radius: 6 
                            color: powerButton.color 
                            border.color: Appearance.color 
                            border.width: 1 
                            anchors.verticalCenter: parent.verticalCenter 
                            Text { 
                                anchors.centerIn: parent 
                                font.family: Appearance.materialSymbols 
                                text: "close" 
                                color: Appearance.color 
                                font.bold: true 
                            } 
                            
                            MouseArea { 
                                anchors.fill: parent 
                                onClicked: confirmDialogPower.visible = false 
                                hoverEnabled: true 
                                onEntered: parent.opacity = 0.8 
                                onExited: parent.opacity = 1.0 
                                cursorShape: Qt.PointingHandCursor 
                            } 
                        } 
                    } 
                } 
            }
        
            Rectangle { 
                id: rebootButton 
                width: 32 * Appearance.scaleFactor 
                height: 32 * Appearance.scaleFactor 
                radius: 10 
                color: Appearance.color 
                scale: 1.0

                Behavior on scale { 
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } 
                } 

                Process { id: rebootProc; command: [] } 

                Timer {
                    id: rotateTimer
                    interval: 3000
                    repeat: true
                    running: true
                    onTriggered: rotationAnim.start()
                }

                NumberAnimation {
                    id: rotationAnim
                    target: rebootIcon
                    property: "rotation"
                    from: 0
                    to: 360
                    duration: 1200
                    easing.type: Easing.InOutQuad
                }

                MouseArea { 
                    anchors.fill: parent 
                    cursorShape: Qt.PointingHandCursor 
                    hoverEnabled: true 

                    onEntered: {
                        rebootButton.scale = 1.2
                        rotateTimer.stop()
                        rotationAnim.stop()
                    }
                    onExited: {
                        rebootButton.scale = 1.0
                        rotateTimer.start()
                    }
                    onClicked: { 
                        confirmDialogReboot.visible = !confirmDialogReboot.visible 
                        confirmDialogPower.visible = false 
                        rotateTimer.stop()
                        rotationAnim.stop()
                    } 
                } 

                Text { 
                    id: rebootIcon
                    anchors.centerIn: parent 
                    text: "restart_alt" 
                    color: Appearance.white 
                    font.family: Appearance.materialSymbols 
                    font.pixelSize: 20 * Appearance.scaleFactor 
                    rotation: 0
                }

                Rectangle { 
                    id: confirmDialogReboot 
                    visible: false 
                    width: 62 
                    height: 30 
                    radius: 8 
                    color: rebootButton.color 
                    anchors.verticalCenter: parent.verticalCenter 
                    anchors.left: parent.right 
                    anchors.leftMargin: 8 

                    RowLayout { 
                        anchors.fill: parent 
                        anchors.margins: 6 
                        spacing: 8 

                        Text { 
                            text: "Reboot?" 
                            color: Appearance.white 
                            anchors.verticalCenter: parent.verticalCenter 
                            verticalAlignment: Text.AlignVCenter 
                            font.bold: true 
                        } 

                        Rectangle { 
                            width: 40 
                            height: 28 
                            radius: 6 
                            color: rebootButton.color 
                            border.color: Appearance.color 
                            border.width: 1 
                            anchors.verticalCenter: parent.verticalCenter 

                            Text { 
                                anchors.centerIn: parent 
                                font.family: Appearance.materialSymbols 
                                text: "check" 
                                color: Appearance.white 
                                font.bold: true 
                            } 

                            MouseArea { 
                                anchors.fill: parent 
                                onClicked: { 
                                    rebootProc.command = ["sh", "-c", "systemctl reboot"] 
                                    rebootProc.running = true 
                                    confirmDialogReboot.visible = false 
                                } 
                                hoverEnabled: true 
                                onEntered: parent.opacity = 0.8 
                                onExited: parent.opacity = 1.0 
                                cursorShape: Qt.PointingHandCursor 
                            } 
                        } 

                        Rectangle { 
                            width: 40 
                            height: 28 
                            radius: 6 
                            color: rebootButton.color 
                            border.color: Appearance.color 
                            border.width: 1 
                            anchors.verticalCenter: parent.verticalCenter 

                            Text { 
                                anchors.centerIn: parent 
                                font.family: Appearance.materialSymbols 
                                text: "close" 
                                color: Appearance.white 
                                font.bold: true
                            } 

                            MouseArea { 
                                anchors.fill: parent 
                                onClicked: confirmDialogReboot.visible = false 
                                hoverEnabled: true 
                                onEntered: parent.opacity = 0.8 
                                onExited: parent.opacity = 1.0 
                                cursorShape: Qt.PointingHandCursor 
                            } 
                        } 
                    } 
                } 
            }
        } 

        Item { Layout.fillWidth: true } 

        Item {
            width: 40; height: 40
            VolumeWidget { anchors.fill: parent }

            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 1.2; duration: 800; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 1.2; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
            }
        } 

        Item {
            width: 40; height: 40
            BluetoothWidget { anchors.fill: parent }

            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 1.2; duration: 900; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 1.2; to: 1.0; duration: 900; easing.type: Easing.InOutQuad }
            }
        }

        Item {
            width: 40; height: 40
            WifiWidget { anchors.fill: parent }

            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 1.2; duration: 1000; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 1.2; to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
            }
        }
        
        BatteryWidget {} 
        SequentialAnimation { 
            running: true 
            NumberAnimation { target: topBar; property: "y"; from: topBar.y; to: topBar.initialY; duration: 800; easing.type: Easing.OutCubic } 
            NumberAnimation { target: topBar; property: "opacity"; from: 0; to: 1; duration: 800; easing.type: Easing.OutCubic } 
        } 
    }
     
    ColumnLayout { 
        id: icon 
        anchors.top: parent.top 
        anchors.margins: 40 * Appearance.scaleFactor 
        spacing: 90 
        anchors.horizontalCenter: parent.horizontalCenter 

        Rectangle { 
            anchors.horizontalCenter: parent.horizontalCenter 
            id: lockButton 
            width: 32 * Appearance.scaleFactor 
            height: 32 * Appearance.scaleFactor 
            radius: width / 2 
            color: Appearance.primary 
            scale: 1.0 
            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
            
            Text { 
                id: lockIcon 
                anchors.centerIn: parent 
                text: "lock" 
                color: Appearance.color 
                font.family: Appearance.materialSymbols 
                font.pixelSize: 20 * Appearance.scaleFactor } 
                
                Timer { 
                    id: scaleLoop 
                    interval: 400 
                    repeat: true 
                    running: true 
                    property bool enlarged: false
                    onTriggered: { 
                        lockButton.scale = enlarged ? 1.0 : 1.05 
                        enlarged = !enlarged 
                    } 
                } 
                
                Timer { 
                    id: iconLoop 
                    interval: 1000 
                    repeat: true 
                    running: true 
                    onTriggered: { 
                        lockIcon.text = (lockIcon.text === "lock") ? "lock_open" : "lock" 
                    } 
                } 
            } 
        IndicatorWidget {} 
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
        
        Item { 
            id: passwordContainer 
            anchors.centerIn: parent 
            MouseArea { 
                anchors.fill: parent 
                onClicked: { if (!passwordBox.containsMouse) { passwordBox.focus = false } } 
            } 
            
            TextField { 
                id: passwordBox 
                property bool isError: false 
                property string basePlaceholder: "Enter password" 
                property int dotCount: 0 
                anchors.centerIn: parent 
                implicitWidth: 300 
                implicitHeight: 50 
                padding: 12 
                enabled: !root.context.unlockInProgress 
                echoMode: TextInput.Password 
                inputMethodHints: Qt.ImhSensitiveData 
                horizontalAlignment: Text.AlignHCenter 
                opacity: 0 
                focus: false 

                background: Rectangle { 
                    id: bgRect 
                    radius: 25 
                    border.width: 2 
                    color: "transparent" 
                    border.color: passwordBox.isError ? "red" : (passwordBox.activeFocus ? Appearance.primary : Appearance.background) 
                } 

                font.pointSize: 16 
                color: Appearance.white 
                placeholderText: basePlaceholder 
                placeholderTextColor: Appearance.white 

                Timer { 
                    id: placeholderAnim 
                    interval: 500 
                    repeat: true 
                    running: true 
                    onTriggered: { 
                        passwordBox.dotCount = (passwordBox.dotCount + 1) % 4 
                        var dots = "" 
                        for (var i = 0; i < passwordBox.dotCount; i++) dots += "."
                        passwordBox.placeholderText = passwordBox.basePlaceholder + dots 
                    } 
                } 
                
                onTextChanged: { 
                    root.context.currentText = text 
                    if (passwordBox.isError && text.trim().length > 0) { 
                        passwordBox.isError = false 
                        if (errorHoldTimer.running) errorHoldTimer.stop() 
                    } 
                } 
                onAccepted: { 
                    if (text.length === 0) { 
                        errorLabel.text = "Password cannot be empty" 
                        errorLabel.visible = true 
                        triggerError() 
                    } else if (text.trim().length === 0) { 
                        errorLabel.text = "Incorrect password" 
                        errorLabel.visible = true 
                        triggerError() 
                    } else { 
                        root.context.tryUnlock() 
                        unlockResultTimer.attempts = 0 
                        unlockResultTimer.start() 
                    } 
                } 
                onActiveFocusChanged: if (!activeFocus) root.forceActiveFocus() 
                Connections { 
                    target: root.context 
                    function onCurrentTextChanged() { 
                        passwordBox.text = root.context.currentText 
                    } 
                    
                    function onUnlockFailed() { 
                        errorLabel.text = "Incorrect password"
                        errorLabel.visible = true 
                        passwordBox.triggerError() 
                    } 
                    
                    onShowFailureChanged: { 
                        if (root.context.showFailure) { 
                            errorLabel.text = "Incorrect password" 
                            errorLabel.visible = true 
                            passwordBox.triggerError() 
                        } 
                    } 
                } 
                SequentialAnimation on opacity { NumberAnimation { to: 1; duration: 1000; easing.type: Easing.OutQuad } } 
                Keys.onEscapePressed: passwordBox.focus = false 

                function triggerError() {
                    passwordBox.isError = true
                    if (shakeAnim.running) shakeAnim.stop()
                    if (errorHoldTimer.running) errorHoldTimer.stop()
                    shakeAnim.start()

                    passwordBox.text = ""

                    errorLabel.visible = true
                    errorLabel.opacity = 1
                    hideErrorTimer.restart()
                }

                SequentialAnimation { 
                    id: shakeAnim 
                    running: false 
                    PropertyAnimation { target: passwordBox.anchors; property: "horizontalCenterOffset"; to: -10; duration: 50 } 
                    PropertyAnimation { target: passwordBox.anchors; property: "horizontalCenterOffset"; to: 10; duration: 50 } 
                    PropertyAnimation { target: passwordBox.anchors; property: "horizontalCenterOffset"; to: -6; duration: 40 } 
                    PropertyAnimation { target: passwordBox.anchors; property: "horizontalCenterOffset"; to: 6; duration: 40 } 
                    PropertyAnimation { target: passwordBox.anchors; property: "horizontalCenterOffset"; to: 0; duration: 30 } 
                    
                    onStopped: errorHoldTimer.start() 
                } 
                    
                Timer { 
                    id: errorHoldTimer 
                    interval: 150 
                    repeat: false 
                    onTriggered: passwordBox.isError = false 
                } 
                    
                Timer { 
                    id: unlockResultTimer 
                    interval: 100 
                    repeat: true 
                    property int attempts: 0 
                    onTriggered: { 
                        attempts += 1 
                        if (root.context.showFailure) { 
                            errorLabel.text = "Incorrect password" 
                            errorLabel.visible = true 
                            passwordBox.triggerError() 
                            stop() 
                        } 
                        if (attempts > 30) stop() 
                    } 
                } 
            } 
        } 
        Label { 
            anchors.topMargin: 30 
            anchors.top: passwordContainer.bottom 
            id: errorLabel 
            color: Appearance.primary 
            visible: false 
            font.family: Appearance.bitcountFont 
            text: "" 
            horizontalAlignment: Text.AlignHCenter 
            anchors.horizontalCenter: parent.horizontalCenter 
            font.pointSize: 16 * Appearance.scaleFactor 
            opacity: 0 
            
            SequentialAnimation on opacity { NumberAnimation { to: 1; duration: 500; easing.type: Easing.OutQuad } } 
            
            Timer { 
                id: hideErrorTimer 
                interval: 
                2000 
                repeat: false 
                onTriggered: { 
                    errorLabel.visible = false 
                    errorLabel.opacity = 0 
                } 
            } 
        } 
        
        ColumnLayout { 
            anchors.top: errorLabel.bottom 
            id: bottomColumn 
            spacing: 6 
            opacity: 0 
            
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

                        text: {
                            const h = clock.date.getHours().toString().padStart(2, "0")
                            const m = clock.date.getMinutes().toString().padStart(2, "0")
                            return h + ":" + m
                        }
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
                        TextMetrics { id: titleMetrics; text: mediaTitle(); font.pixelSize: 14 * Appearance.scaleFactor; font.bold: true } 
                        Text { 
                            visible: titleMetrics.width <= parent.width 
                            anchors.verticalCenter: parent.verticalCenter 
                            text: mediaTitle()
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
                                Text { text: mediaTitle(); font.pixelSize: 14 * Appearance.scaleFactor; font.bold: true; color: Appearance.white } 
                                Text { text: mediaTitle(); font.pixelSize: 14 * Appearance.scaleFactor; font.bold: true; color: Appearance.white } 
                            } 
                            NumberAnimation on offset { from: 0; to: -(titleMetrics.width + 40); duration: (titleMetrics.width + 40) * 40; loops: Animation.Infinite; running: true } 
                        } 
                    } 
                    
                    Item { 
                        width: 330 * Appearance.scaleFactor 
                        height: 14 * Appearance.scaleFactor 
                        clip: true 
                        TextMetrics { id: artistMetrics; text: mediaArtist(); font.pixelSize: 12 * Appearance.scaleFactor } 
                        Text { 
                            visible: artistMetrics.width <= parent.width 
                            anchors.verticalCenter: parent.verticalCenter 
                            text: mediaArtist()
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
                                Text { text: mediaArtist(); font.pixelSize: 12 * Appearance.scaleFactor; color: Appearance.white } 
                                Text { text: mediaArtist(); font.pixelSize: 12 * Appearance.scaleFactor; color: Appearance.white } 
                            } 
                            NumberAnimation on offset { from: 0; to: -(artistMetrics.width + 40); duration: (artistMetrics.width + 40) * 40; loops: Animation.Infinite; running: true } 
                        } 
                    } 
                } 
                Row { 
                    x: 900 
                    spacing: 25 * Appearance.scaleFactor 
                    SequentialAnimation on x { 
                        NumberAnimation { to: 700; duration: 800; easing.type: Easing.OutCubic } 
                    } 
                    
                    Item { 
                        width: 18*Appearance.scaleFactor; 
                        height:18*Appearance.scaleFactor 
                        Text { 
                            anchors.centerIn: parent; 
                            text: "skip_previous"; 
                            font.family: Appearance.materialSymbols; 
                            font.pixelSize: 18*Appearance.scaleFactor; 
                            color: Appearance.white 
                        } 
                        MouseArea { 
                            anchors.fill: parent
                            onClicked: { 
                                mediaPrev() 
                                mediaColumn.opacity = 0 
                                fadeAnim.start() 
                                mediaColumn.y = 200 
                                yAnim.start() 
                            } 
                            cursorShape: Qt.PointingHandCursor 
                        } 
                    } 
                    
                    Item {
                            width: 18 *Appearance.scaleFactor; 
                            height:18*Appearance.scaleFactor 
                            Text { 
                            anchors.centerIn: parent; 
                            text: currentPlayer && currentPlayer.isPlaying ? "pause" : "play_arrow"
                            font.family: Appearance.materialSymbols; 
                            font.pixelSize: 18*Appearance.scaleFactor; 
                            color: Appearance.white 
                        } 
                        MouseArea { 
                            anchors.fill: parent; 
                            onClicked: mediaPlayPause(); 
                            cursorShape: Qt.PointingHandCursor 
                        } 
                    } 
                    Item { 
                        width: 18 *Appearance.scaleFactor; 
                        height:18*Appearance.scaleFactor 
                        Text { 
                            anchors.centerIn: parent; 
                            text: "skip_next"; 
                            font.family: Appearance.materialSymbols; 
                            font.pixelSize: 18*Appearance.scaleFactor; 
                            color: Appearance.white 
                        } 
                        
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
                NumberAnimation { target: mediaColumn; property: "y"; from: 200; to: 100; duration: 800; easing.type: Easing.OutCubic } } 
                ClippingWrapperRectangle { 
                    width: 300 * Appearance.scaleFactor 
                    height: 180 * Appearance.scaleFactor 
                    radius: 12 * Appearance.scaleFactor 
                    opacity: mediaTitle() && mediaTitle() !== "No Media Found" ? 1 : 0 
                    Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } } 

                    Item { 
                        id: container 
                        anchors.fill: parent 
                        Rectangle { 
                            anchors.fill: parent; 
                            color: Appearance.primary 
                        } 
                        
                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            cache: false
                            asynchronous: true
                            source: coverUtil.coverSource
                        }

                        Rectangle { anchors.fill: parent; color: "#000000"; opacity: 0.5 } 
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
