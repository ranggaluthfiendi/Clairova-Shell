import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config
import qs.utils

Item {
    id: calendarWidget

    width: parent ? parent.width : 320
    implicitHeight: contentLayout.implicitHeight

    CalendarUtil {
        id: calendarUtil
    }

    Behavior on visible {
        NumberAnimation { duration: 150 }
    }


    property int currentDay: calendarUtil.currentDay
    property int currentYear: calendarUtil.year
    property string currentMonth: Qt.formatDate(new Date(currentYear, calendarUtil.month), "MMMM")
    property alias markedDays: calendarUtil.markedDays
    property alias daysInMonth: calendarUtil.daysInMonth
    property alias isCurrentMonth: calendarUtil.isCurrentMonth

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        spacing: 12 * Appearance.scaleFactor

        RowLayout {
            Layout.fillWidth: true

            Item {
                implicitWidth: contentRow.implicitWidth + 24 * Appearance.scaleFactor
                implicitHeight: contentRow.implicitHeight + 12 * Appearance.scaleFactor
                
                Row {
                    id: contentRow
                    spacing: 2 * Appearance.scaleFactor
                    anchors.left: parent.left
                    anchors.leftMargin: 15 * Appearance.scaleFactor
                    anchors.right: parent.right
                    anchors.rightMargin: 12 * Appearance.scaleFactor
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 6 * Appearance.scaleFactor
                    anchors.bottomMargin: 6 * Appearance.scaleFactor

                    Text {
                        text: calendarWidget.currentMonth + "・"
                        font.pixelSize: 18 * Appearance.scaleFactor
                        font.family: Appearance.defaultFont
                        font.bold: true
                        color: Appearance.white
                    }

                    Text {
                        text: calendarWidget.currentYear
                        font.family: Appearance.defaultFont
                        font.pixelSize: 18 * Appearance.scaleFactor
                        color: "#8d8d8d"
                    }
                }
            }

            Item {
                id: deleteAllMarkWrapper
                visible: markedDays.length > 0
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: 32 * Appearance.scaleFactor
                Layout.preferredWidth: 80 * Appearance.scaleFactor

                RowLayout {
                    id: deletedMarkIndicator
                    anchors.fill: parent

                    Text {
                        text: "cancel"
                        font.family: Appearance.materialSymbols
                        font.pixelSize: 10 * Appearance.scaleFactor
                        color: "#ff5555"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: "Delete all Mark"
                        font.pixelSize: 8 * Appearance.scaleFactor
                        color: "#ff5555"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        calendarUtil.clearMarkedDays()
                    }
                }
            }

            Item { Layout.fillWidth: true }

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
                        if (isToday) return Appearance.primary
                        return "transparent"
                    }

                    property color markedColor: "#772222"

                    Text {
                        anchors.centerIn: parent
                        text: day !== null ? day.toString() : ""
                        font.family: Appearance.bitcountFont
                        font.pixelSize: 14 * Appearance.scaleFactor
                        color: {
                            if (!isCurrent) return "#777"
                            if (isToday && isMarked) return "#fff" 
                            if (isToday) return "#000"
                            return "#fff"
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
                        onClicked: {
                            calendarUtil.toggleMarkedDay(day)
                        }
                    }
                }
            }
        }
    }
}
