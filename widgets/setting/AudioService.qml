pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// shoutout to https://github.com/bbedward/DankMaterialShell/blob/master/Services/AudioService.qml
// https://github.com/bbedward

Singleton {
    id: audioService

    readonly property PwNode output: Pipewire.defaultAudioSink
    readonly property PwNode input: Pipewire.defaultAudioSource

    function displayName(node) {
        if (!node) return ""
        
        if (node.properties && node.properties["device.description"]) {
            return node.properties["device.description"]
        }

        if (node.description && node.description !== node.name) {
            return node.description
        }

        if (node.nickname && node.nickname !== node.name) {
            return node.nickname
        }

        if (node.name.includes("analog-stereo")) return "Built-in Speakers"
        else if (node.name.includes("bluez")) return "Bluetooth Audio"
        else if (node.name.includes("usb")) return "USB Audio"
        else if (node.name.includes("hdmi")) return "HDMI Audio"

        return node.name
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

}