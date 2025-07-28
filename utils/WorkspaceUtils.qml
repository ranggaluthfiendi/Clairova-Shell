import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: workspaceUtils

    property int currentWorkspace: 1
    property var workspacesWithClients: []
    property int maxVisible: 5
    property int workspaceCount: 5
    property int scrollOffset: 0

    signal workspaceSwitched(int newIndex)

    Process {
        id: getWorkspaceProc
        command: ["hyprctl", "activeworkspace", "-j"]
        running: false
        onExited: running = false

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let json = JSON.parse(text)
                    let id = json.id || 1
                    if (workspaceUtils.currentWorkspace !== id) {
                        workspaceUtils.currentWorkspace = id
                        workspaceUtils.workspaceSwitched(id)
                    }

                    if (id > workspaceUtils.workspaceCount) {
                        workspaceUtils.workspaceCount = Math.min(id, 50)
                    }

                    if (id > (workspaceUtils.scrollOffset + workspaceUtils.maxVisible)) {
                        workspaceUtils.scrollOffset = id - workspaceUtils.maxVisible
                    } else if (id <= workspaceUtils.scrollOffset) {
                        workspaceUtils.scrollOffset = Math.max(0, id - 1)
                    }

                    if (workspaceUtils.scrollOffset > workspaceUtils.workspaceCount - workspaceUtils.maxVisible) {
                        workspaceUtils.scrollOffset = Math.max(0, workspaceUtils.workspaceCount - workspaceUtils.maxVisible)
                    }
                } catch (e) {
                    console.log("Error parsing activeworkspace json:", e)
                    workspaceUtils.currentWorkspace = 1
                }
            }
        }
    }

    Process {
        id: getClientsProc
        command: ["hyprctl", "clients", "-j"]
        running: false
        onExited: running = false

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let clients = JSON.parse(text)
                    let result = []

                    for (let i = 0; i < clients.length; i++) {
                        let wsId = clients[i].workspace.id
                        if (!result.includes(wsId))
                            result.push(wsId)
                    }

                    workspaceUtils.workspacesWithClients = result
                } catch (e) {
                    console.log("Error parsing clients json:", e)
                    workspaceUtils.workspacesWithClients = []
                }
            }
        }
    }

    Timer {
        interval: 300
        running: true
        repeat: true
        onTriggered: {
            if (!getWorkspaceProc.running)
                getWorkspaceProc.running = true
            if (!getClientsProc.running)
                getClientsProc.running = true
        }
    }

    Process {
        id: setWorkspaceProc
        command: []
        running: false
        onExited: running = false
    }


    function switchWorkspace(index) {
        if (index < 1) index = 1
        if (index > 50) index = 50

        currentWorkspace = index
        workspaceSwitched(index)

        setWorkspaceProc.command = ["hyprctl", "dispatch", "workspace", index.toString()]
        setWorkspaceProc.running = true

        if (index > (scrollOffset + maxVisible)) {
            scrollOffset = index - maxVisible
        } else if (index <= scrollOffset) {
            scrollOffset = Math.max(0, index - 1)
        }

        if (scrollOffset > workspaceCount - maxVisible) {
            scrollOffset = Math.max(0, workspaceCount - maxVisible)
        }
    }

    function workspaceHasWindows(index) {
        return workspacesWithClients.includes(index)
    }

    function nextWorkspace() {
        if (currentWorkspace < 50) {
            let newIndex = currentWorkspace + 1
            if (newIndex > workspaceCount) {
                workspaceCount = Math.min(50, workspaceCount + 1)
            }
            switchWorkspace(newIndex)
        }
    }

    function prevWorkspace() {
        let newIndex = Math.max(1, currentWorkspace - 1)
        switchWorkspace(newIndex)
    }
}
