import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

ColumnLayout {
    spacing: 6
    

    function getNodeName(node) {
        const props = node.properties;

        const appName   = props["application.name"];
        const mediaName = props["media.name"];
        const desc      = node.description;
        const name      = appName || (desc && desc !== "" ? desc : node.name) || node.name;

        return mediaName ? `${name} — ${mediaName}` : `${name} (${node.id})`;
    }

    Repeater {
        model: Pipewire.nodes

        delegate: Column {
            spacing: 2
            property var node: modelData
            
            visible: node.audio !== null

            Text {
                text: {
                    const title = getNodeName(node);
                    const isDefault = (node === Pipewire.defaultAudioSink) ? " (default audio)" : "";
                    return `${title}${isDefault}`;
                }
                font.pointSize: 11
                color: "white"
            }

            Text {
                text: `Type: ${node.type}`
                font.pointSize: 10
                color: "#888"
            }

            Text {
                text: `ID: ${node.id}, Name: ${node.name}`
                font.pointSize: 9
                color: "#666"
            }
        }
    }
}
