import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: util
    property string pastedText: ""

    signal validHexColor(string hex, color rgba)

    Process {
        id: pasteProcess
        command: "wl-paste"

        stdout: StdioCollector {
            onStreamFinished: {
                pastedText = this.text.trim()
                console.debug("🧾 Raw paste input:", pastedText)

                var pasted = pastedText
                if (!pasted.startsWith("#")) {
                    pasted = "#" + pasted
                }

                pasted = pasted.toLowerCase()
                const isHex = /^#([0-9a-f]{6})$/.test(pasted)

                if (isHex) {
                    const rgba = Qt.rgba(
                        parseInt(pasted.substr(1, 2), 16) / 255,
                        parseInt(pasted.substr(3, 2), 16) / 255,
                        parseInt(pasted.substr(5, 2), 16) / 255,
                        1.0
                    )
                    validHexColor(pasted, rgba)
                    console.debug("✅ Valid HEX:", pasted)
                } else {
                    console.warn("❌ Invalid HEX:", pasted)
                }
            }
        }
    }

    function paste() {
        pasteProcess.running = true
    }
}
