import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config
import qs.utils

Item {
    id: calendarWidget

    width: parent ? parent.width : 320
    implicitHeight: headerRow.implicitHeight + (expanded ? contentLayout.implicitHeight : 0)

    property bool expanded: false

    CalendarUtil {
        id: calendarUtil
    }

    property int currentDay: calendarUtil.currentDay
    property int currentYear: calendarUtil.year
    property string currentMonth: Qt.formatDate(new Date(currentYear, calendarUtil.month), "MMMM")
    property alias markedDays: calendarUtil.markedDays
    property alias daysInMonth: calendarUtil.daysInMonth
    property alias isCurrentMonth: calendarUtil.isCurrentMonth

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: 8 * Appearance.scaleFactor

        RowLayout {
            id: headerRow
            Layout.fillWidth: true

            Item {
                implicitWidth: titleRow.implicitWidth + 24 * Appearance.scaleFactor
                implicitHeight: titleRow.implicitHeight + 12 * Appearance.scaleFactor

                Row {
                    id: titleRow
                    anchors.left: parent.left
                    anchors.leftMargin: 15 * Appearance.scaleFactor
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: calendarWidget.currentMonth + "・"
                        font.pixelSize: 16 * Appearance.scaleFactor
                        font.family: Appearance.defaultFont
                        font.bold: true
                        color: Appearance.white
                    }

                    Text {
                        text: calendarWidget.currentYear
                        font.family: Appearance.defaultFont
                        font.pixelSize: 16 * Appearance.scaleFactor
                        color: Qt.rgba(Appearance.white.r, Appearance.white.g, Appearance.white.b, 0.5)
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.rightMargin: 10 * Appearance.scaleFactor
                radius: 20 * Appearance.scaleFactor
                Layout.preferredHeight: 28 * Appearance.scaleFactor
                Layout.preferredWidth: 28 * Appearance.scaleFactor
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    text: calendarWidget.expanded ? "arrow_drop_up" : "arrow_drop_down"
                    font.family: Appearance.materialSymbols
                    font.pixelSize: 38 * Appearance.scaleFactor
                    color: Appearance.white
                }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: calendarWidget.expanded = !calendarWidget.expanded
            }
        }

        Item {
            id: contentWrapper
            Layout.fillWidth: true
            implicitHeight: contentLayout.implicitHeight
            opacity: calendarWidget.expanded ? 1 : 0

            Behavior on implicitHeight { 
                NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } 
            }

            Behavior on opacity { 
                NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } 
            }

            SequentialAnimation on opacity {
                running: !calendarWidget.expanded
                NumberAnimation { to: 0; duration: 100; easing.type: Easing.InOutQuad }
                ScriptAction { script: contentWrapper.visible = false }
            }

            onOpacityChanged: {
                if (calendarWidget.expanded) contentWrapper.visible = true
            }

            ColumnLayout {
                id: contentLayout
                anchors.fill: parent
                spacing: 12 * Appearance.scaleFactor

                RowLayout {
                    Layout.fillWidth: true

                    Item {
                        id: deleteAllMarkWrapper
                        visible: markedDays.length > 0
                        Layout.leftMargin: 15 * Appearance.scaleFactor
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredHeight: 32 * Appearance.scaleFactor
                        Layout.preferredWidth: 80 * Appearance.scaleFactor

                        RowLayout {
                            id: deletedMarkIndicator
                            anchors.fill: parent
                            
                            Text {
                                text: "cancel"
                                font.family: Appearance.materialSymbols
                                font.pixelSize: 12 * Appearance.scaleFactor
                                color: Appearance.primary
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Text {
                                text: "Delete all Mark"
                                font.pixelSize: 14 * Appearance.scaleFactor
                                color: Appearance.primary
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: calendarUtil.clearMarkedDays()
                        }
                    }

                    Item { Layout.fillWidth: true }

                    RowLayout {
                        spacing: 6 * Appearance.scaleFactor
                        Layout.rightMargin: 15 * Appearance.scaleFactor

                        Rectangle {
                            color: Appearance.background
                            radius: 20 * Appearance.scaleFactor
                            Layout.preferredHeight: 32 * Appearance.scaleFactor
                            Layout.preferredWidth: 32 * Appearance.scaleFactor

                            Text {
                                anchors.centerIn: parent
                                text: "keyboard_arrow_left"
                                font.family: Appearance.materialSymbols
                                font.pixelSize: 20 * Appearance.scaleFactor
                                color: Appearance.white
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: calendarUtil.prevMonth()
                            }
                        }

                        Rectangle {
                            color: Appearance.background
                            radius: 20 * Appearance.scaleFactor
                            Layout.preferredHeight: 32 * Appearance.scaleFactor
                            Layout.preferredWidth: 32 * Appearance.scaleFactor

                            Text {
                                anchors.centerIn: parent
                                text: "keyboard_arrow_right"
                                font.family: Appearance.materialSymbols
                                font.pixelSize: 20 * Appearance.scaleFactor
                                color: Appearance.white
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: calendarUtil.nextMonth()
                            }
                        }
                    }
                }

                // Calendar grid
                GridLayout {
                    id: calendarGrid
                    columns: 7
                    Layout.fillWidth: true
                    rowSpacing: 6 * Appearance.scaleFactor
                    columnSpacing: 4 * Appearance.scaleFactor

                    Repeater {
                        model: ["M", "T", "W", "T", "F", "S", "S"]
                        delegate: Text {
                            text: modelData
                            font.pixelSize: 18 * Appearance.scaleFactor
                            font.family: Appearance.defaultFont
                            color: Appearance.white
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            Layout.preferredWidth: (calendarWidget.width - 6 * 6) / 7
                            Layout.preferredHeight: 28 * Appearance.scaleFactor
                        }
                    }

                    Repeater {
                        model: [].concat.apply([], calendarWidget.daysInMonth)

                        delegate: Rectangle {
                            id: dayRect
                            Layout.preferredWidth: (calendarWidget.width - 6 * 6) / 7
                            Layout.preferredHeight: 40 * Appearance.scaleFactor
                            radius: 6 * Appearance.scaleFactor

                            property int day: modelData.day
                            property bool isCurrent: modelData.monthOffset === 0 && day !== null
                            property bool isToday: isCurrent && day === calendarWidget.currentDay && calendarWidget.isCurrentMonth
                            property bool isMarked: isCurrent && calendarWidget.markedDays.some(m => m.day === day && m.month === calendarUtil.month && m.year === calendarUtil.year)

                            color: {
                                if (day === null) return "transparent"
                                if (isMarked) return markedColor
                                if (isCurrent && calendarUtil.selectedStartDay !== -1 && day >= calendarUtil.selectedStartDay && day <= calendarUtil.selectedEndDay)
                                    return "#2A2A2A"
                                if (isToday) return Qt.rgba(Appearance.primary.r, Appearance.primary.g, Appearance.primary.b, 0.6)
                                return "transparent"
                            }

                            property color markedColor: Qt.rgba(Appearance.primary.r, Appearance.primary.g, Appearance.primary.b, 0.2)

                            Text {
                                anchors.centerIn: parent
                                text: day !== null ? day.toString() : ""
                                font.family: Appearance.bitcountFont
                                font.pixelSize: 14 * Appearance.scaleFactor
                                color: {
                                    if (!isCurrent) return Qt.rgba(Appearance.white.r, Appearance.white.g, Appearance.white.b, 0.4)
                                    if (isToday && isMarked) return Appearance.white
                                    if (isToday) return Qt.rgba(Appearance.white.r, Appearance.white.g, Appearance.white.b, 1)
                                    return Appearance.white
                                }
                            }

                            SequentialAnimation on scale {
                                id: pulseAnim
                                running: isToday
                                loops: Animation.Infinite
                                NumberAnimation { to: 1.1; duration: 500; easing.type: Easing.InOutQuad }
                                NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
                            }

                            Behavior on color {
                                ColorAnimation { duration: 250; easing.type: Easing.InOutCubic }
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: isCurrent && day !== null
                                cursorShape: Qt.PointingHandCursor
                                onClicked: calendarUtil.toggleMarkedDay(day)
                            }
                        }
                    }
                }
            }
        }
    }
}
