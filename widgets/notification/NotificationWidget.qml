import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.utils
import qs.config

Item {
    id: notificationArea
    width: parent ? parent.width : 360
    implicitHeight: mainLayout.implicitHeight
    property color backgroundColor: Appearance.color

    signal requestNotifToggle(bool forceClose)

    NotificationUtil { id: notificationUtil }

    function formatTimestamp(isoString) {
        const date = new Date(isoString)
        const hours = date.getHours().toString().padStart(2, "0")
        const minutes = date.getMinutes().toString().padStart(2, "0")

        const day = date.getDate().toString().padStart(2, "0")
        const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        const dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

        const weekday = dayNames[date.getDay()]
        const month = monthNames[date.getMonth()]
        const year = date.getFullYear()

        return `${hours}:${minutes} ${weekday} ${day} ${month} ${year} • `
    }


    ColumnLayout {
        id: mainLayout
        anchors.margins: 16 * Appearance.scaleFactor
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 10 * Appearance.scaleFactor

        RowLayout {
            Layout.fillWidth: true
            spacing: 6 * Appearance.scaleFactor

            RowLayout {
                spacing: 10 * Appearance.scaleFactor
                Text {
                    text: "Notifications"
                    font.family: Appearance.materialSymbols
                    font.pixelSize: 24 * Appearance.scaleFactor
                    color: Appearance.white
                }

                Text {
                    text: "Notifications"
                    font.family: Appearance.bitcountFont
                    font.pixelSize: 24 * Appearance.scaleFactor
                    color: Appearance.white
                }
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 18 * Appearance.scaleFactor

                RowLayout {
                    Text {
                        text: "Clear"
                        font.family: Appearance.defaultFont
                        font.pixelSize: 14 * Appearance.scaleFactor
                        color: Appearance.danger
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        text: "clear_all"
                        font.pixelSize: 14 * Appearance.scaleFactor
                        font.family: Appearance.materialSymbols
                        color: Appearance.danger
                        verticalAlignment: Text.AlignVCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            notificationUtil.clearAll()
                        }
                    }
                }
            }
        }

        ListView {
            id: notificationList
            model: notificationUtil.notifications
            Layout.fillWidth: true
            Layout.preferredHeight: 320 * Appearance.scaleFactor
            spacing: 10 * Appearance.scaleFactor
            clip: true
            boundsBehavior: Flickable.DragAndOvershootBounds

            ScrollBar.vertical: ScrollBar {
                policy: Qt.ScrollBarAsNeeded
            }

            delegate: Item {
                id: delegateItem
                width: notificationList.width
                height: notificationCard.implicitHeight
                opacity: 0

                property real startX: 0
                property real dragX: 0

                SequentialAnimation on opacity {
                    PropertyAnimation { from: 0; to: 1; duration: 150 }
                }

                Rectangle {
                    id: notificationCard
                    width: parent.width
                    x: delegateItem.dragX
                    color: backgroundColor
                    radius: 8 * Appearance.scaleFactor
                    border.color: "#444"
                    border.width: 1
                    implicitHeight: contentLayout.implicitHeight + 24 * Appearance.scaleFactor
                    opacity: 1
                    scale: 1

                    Behavior on x {
                        NumberAnimation { duration: 100 }
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }

                    ColumnLayout {
                        id: contentLayout
                        anchors.margins: 12 * Appearance.scaleFactor
                        anchors.fill: parent

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: modelData.summary
                                font.pixelSize: 16 * Appearance.scaleFactor
                                font.bold: true
                                color: "#fff"
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                wrapMode: Text.NoWrap
                            }
                        }

                        Text {
                            text: modelData.body
                            font.pixelSize: 16 * Appearance.scaleFactor
                            color: "#aaa"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.Wrap
                        }

                        Text {
                            text: formatTimestamp(modelData.time) + modelData.appName
                            font.pixelSize: 8 * Appearance.scaleFactor
                            color: "#aaa"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.Wrap
                        }
                    }

                    MouseArea {
                        id: swipeArea
                        anchors.fill: parent
                        drag.target: notificationCard
                        drag.axis: Drag.XAxis
                        drag.minimumX: -parent.width
                        drag.maximumX: parent.width
                        onReleased: {
                            if (Math.abs(notificationCard.x) > parent.width * 0.35) {
                                notificationCard.opacity = 0
                                Qt.callLater(() => notificationUtil.dismiss(modelData))
                            } else {
                                notificationCard.x = 0
                            }
                        }
                    }
                }
            }
        }
    }
}
