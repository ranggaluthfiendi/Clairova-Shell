import qs.utils
import qs.config

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import Quickshell.Services.Pipewire

Item {
    id: volumeWidget
    signal requestSidebarToggle()

    width: 32 * Appearance.scaleFactor
    height: 32 * Appearance.scaleFactor

    property PwNode node: Pipewire.defaultAudioSink;

	PwObjectTracker { objects: [ node ] }

    Text {
        anchors.centerIn: parent
        font.family: Appearance.materialSymbols
        font.pixelSize: 20 * Appearance.scaleFactor
        color: Appearance.white
        text: (!node || !node.audio || node.audio.muted || node.audio.volume === 0) ? "volume_off" : "volume_up"
    }
}
