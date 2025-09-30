import QtQuick
import Quickshell
import Quickshell.Io
import QtCore

Item {
    id: calendarUtil

    property int month: new Date().getMonth()
    property int year: new Date().getFullYear()
    property int currentDay: new Date().getDate()

    property int selectedStartDay: -1
    property int selectedEndDay: -1
    property var markedDays: []
    property var daysInMonth: []

    property string markedPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString().replace(/^file:\/\//, "") + "/quickshell/savedata/calendar-marked.json"

    property bool isCurrentMonth: Qt.formatDate(new Date(), "MMyyyy") === Qt.formatDate(new Date(year, month), "MMyyyy")

    function updateCalendar() {
        const date = new Date(year, month, 1)
        const startDay = (date.getDay() + 6) % 7

        const daysThisMonth = new Date(year, month + 1, 0).getDate()
        const daysPrevMonth = new Date(year, month, 0).getDate()

        let grid = []
        let row = []

        for (let i = startDay - 1; i >= 0; --i)
            row.push({ day: daysPrevMonth - i, monthOffset: -1 })

        for (let d = 1; d <= daysThisMonth; ++d) {
            row.push({ day: d, monthOffset: 0 })
            if (row.length === 7) {
                grid.push(row)
                row = []
            }
        }

        let d = 1
        while (row.length < 7)
            row.push({ day: d++, monthOffset: 1 })
        grid.push(row)

        daysInMonth = grid
    }

    function prevMonth() {
        month--
        if (month < 0) {
            month = 11
            year--
        }
        updateCalendar()
        loadMarked.running = true
    }

    function nextMonth() {
        month++
        if (month > 11) {
            month = 0
            year++
        }
        updateCalendar()
        loadMarked.running = true
    }

    function toggleMarkedDay(day) {
        const key = { day: day, month: month, year: year }
        const idx = markedDays.findIndex(e =>
            e.day === key.day && e.month === key.month && e.year === key.year
        )
        if (idx === -1)
            markedDays = markedDays.concat([key])
        else {
            let temp = markedDays.slice()
            temp.splice(idx, 1)
            markedDays = temp
        }

        const jsonString = JSON.stringify(markedDays).replace(/'/g, "'\\''")
        const shellCmd = "echo '" + jsonString + "' > '" + markedPath + "'"

        writeMarked.command = ["sh", "-c", shellCmd]
        writeMarked.running = true
    }

    function clearMarkedDays() {
        markedDays = []
        const jsonString = "[]"
        const shellCmd = "echo '" + jsonString + "' > '" + markedPath + "'"
        writeMarked.command = ["sh", "-c", shellCmd]
        writeMarked.running = true
    }


    Process {
        id: loadMarked
        command: ["sh", "-c", `cat '${calendarUtil.markedPath}' 2>/dev/null || echo '[]'`]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    calendarUtil.markedDays = JSON.parse(this.text)
                } catch (e) {
                    calendarUtil.markedDays = []
                }
            }
        }
    }

    Process {
        id: writeMarked
        command: []
    }

    Component.onCompleted: {
        updateCalendar()
        loadMarked.running = true
    }
}
