import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Io
import QtCore

Item {
    id: util

    readonly property string jsonPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation)
        .toString().replace(/^file:\/\//, "") + "/quickshell/savedata/notifications-log.json"

    property list<QtObject> notifications: []
    property list<QtObject> allWrappers: []

    Component {
        id: notifWrapperComponent

        QtObject {
            property var time: new Date()

            property string summary: ""
            property string body: ""
            property string appName: ""
            property string appIcon: ""
            property string cleanAppIcon: {
                if (!appIcon) return "";
                return appIcon.startsWith("file://") ? appIcon.substring(7) : appIcon;
            }

            property Notification notification

            function dismiss() {
                if (notification)
                    notification.dismiss();
            }
        }
    }

    NotificationServer {
        id: server
        keepOnReload: false
        actionsSupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: notif => {
            notif.tracked = true;

            const wrapper = notifWrapperComponent.createObject(util, {
                notification: notif,
                summary: notif.summary,
                body: notif.body,
                appName: notif.appName,
                appIcon: notif.appIcon
            });

            if (wrapper) {
                allWrappers.push(wrapper);
                notifications.push(wrapper);
                save();
            }
        }
    }

    function dismiss(wrapper) {
        if (!wrapper)
            return;

        wrapper.dismiss();

        const i = notifications.indexOf(wrapper);
        if (i !== -1) notifications.splice(i, 1);

        const j = allWrappers.indexOf(wrapper);
        if (j !== -1) allWrappers.splice(j, 1);

        save();
    }

    function clearAll() {
        for (let w of notifications)
            w.dismiss();

        notifications = [];
        allWrappers = [];
        save();
    }

    function formatRelativeTime(date) {
        const now = new Date();
        const diff = now.getTime() - date.getTime();
        const m = Math.floor(diff / 60000);
        const h = Math.floor(m / 60);

        if (h < 1 && m < 1) return "now";
        if (h < 1) return `${m}m`;
        return `${h}h`;
    }

    Process {
        id: readProc
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(this.text || "[]");
                    for (let n of data) {
                        const wrapper = notifWrapperComponent.createObject(util, {
                            summary: n.summary,
                            body: n.body,
                            appName: n.appName,
                            appIcon: n.appIcon,
                            time: new Date(n.time)
                        });
                        if (wrapper) {
                            allWrappers.push(wrapper);
                            notifications.push(wrapper);
                        }
                    }
                } catch (e) {
                    notifications = [];
                    allWrappers = [];
                }
            }
        }
    }

    Process {
        id: writeProc
        command: []
    }

    function load() {
        const fallback = "[]";
        readProc.command = ["sh", "-c", "cat '" + jsonPath + "' 2>/dev/null || echo '" + fallback + "'"];
        readProc.running = true;
    }

    function save() {
        const data = allWrappers.map(n => ({
            summary: n.summary,
            body: n.body,
            appName: n.appName,
            appIcon: n.appIcon,
            time: n.time.toISOString?.() || ""
        }));
        const json = JSON.stringify(data).replace(/'/g, "'\\''");
        writeProc.command = ["sh", "-c", "echo '" + json + "' > '" + jsonPath + "'"];
        writeProc.running = true;
    }
    
    Component.onCompleted: load()
}
