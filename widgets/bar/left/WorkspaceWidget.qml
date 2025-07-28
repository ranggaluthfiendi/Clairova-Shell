import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.utils
import qs.config

Item {
    id: workspaceWidget

    Layout.preferredHeight: 32 * Appearance.scaleFactor
    Layout.preferredWidth: 120 * Appearance.scaleFactor

    WorkspaceUtils {
        id: utils
        workspaceCount: 5
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                let newIndex = Math.max(1, utils.currentWorkspace - 1)
                utils.switchWorkspace(newIndex)
            } else if (wheel.angleDelta.y < 0) {
                let newIndex = utils.currentWorkspace + 1
                if (newIndex > utils.workspaceCount) {
                    utils.workspaceCount = Math.min(50, utils.workspaceCount + 1)
                }
                utils.switchWorkspace(newIndex)
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10 * Appearance.scaleFactor
        spacing: 8 * Appearance.scaleFactor

        Repeater {
            model: Math.min(utils.maxVisible, utils.workspaceCount - utils.scrollOffset)
            delegate: RowLayout {
                id: wsItemRow
                spacing: 6 * Appearance.scaleFactor
                Layout.alignment: Qt.AlignVCenter

                property int wsIndex: index + 1 + utils.scrollOffset
                property bool isActive: wsIndex === utils.currentWorkspace
                property bool hasWindows: utils.workspaceHasWindows(wsIndex)

                function qColorToCss(color) {
                    let r = Math.round(color.r * 255);
                    let g = Math.round(color.g * 255);
                    let b = Math.round(color.b * 255);
                    let a = color.a;
                    if (a === 1)
                        return "#" + [r,g,b].map(x => x.toString(16).padStart(2,"0")).join("");
                    else
                        return `rgba(${r},${g},${b},${a})`;
                }

                // Left Arrow
                Item {
                    width: isActive ? 6 * Appearance.scaleFactor : 0
                    height: 16 * Appearance.scaleFactor
                    visible: isActive

                    Canvas {
                        id: leftArrowCanvas
                        anchors.centerIn: parent
                        width: 6 * Appearance.scaleFactor
                        height: 10 * Appearance.scaleFactor

                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            ctx.fillStyle = qColorToCss(Appearance.primary);
                            ctx.beginPath();
                            ctx.moveTo(width, 0);
                            ctx.lineTo(0, height / 2);
                            ctx.lineTo(width, height);
                            ctx.closePath();
                            ctx.fill();
                        }
                    }

                    Connections {
                        target: Appearance
                        onPrimaryChanged: leftArrowCanvas.requestPaint()
                    }
                }

                // Workspace indicator
                Item {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: indicator.width
                    implicitHeight: indicator.height

                    Rectangle {
                        id: indicator
                        width: 8 * Appearance.scaleFactor
                        height: isActive
                            ? 24 * Appearance.scaleFactor
                            : hasWindows
                            ? 16 * Appearance.scaleFactor
                            : 8 * Appearance.scaleFactor
                        radius: 4 * Appearance.scaleFactor
                        color: isActive ? Appearance.primary : hasWindows ? "#999" : "#444"
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: isActive ? animatedOpacity : 1.0

                        property real animatedOpacity: 1.0

                        Behavior on height {
                            NumberAnimation { duration: 100 }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                utils.switchWorkspace(wsIndex)
                            }
                        }

                        SequentialAnimation on animatedOpacity {
                            running: isActive
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.2; duration: 700 }
                            PauseAnimation { duration: 200 }
                            NumberAnimation { to: 1.0; duration: 700 }
                            PauseAnimation { duration: 200 }
                        }
                    }
                }

                // Right Arrow
                Item {
                    width: isActive ? 6 * Appearance.scaleFactor : 0
                    height: 16 * Appearance.scaleFactor
                    visible: isActive

                    Canvas {
                        id: rightArrowCanvas
                        anchors.centerIn: parent
                        width: 6 * Appearance.scaleFactor
                        height: 10 * Appearance.scaleFactor

                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            ctx.fillStyle = qColorToCss(Appearance.primary);
                            ctx.beginPath();
                            ctx.moveTo(0, 0);
                            ctx.lineTo(width, height / 2);
                            ctx.lineTo(0, height);
                            ctx.closePath();
                            ctx.fill();
                        }
                    }

                    Connections {
                        target: Appearance
                        onPrimaryChanged: rightArrowCanvas.requestPaint()
                    }
                }
            }
        }
    }
}
