import QtQuick
import Quickshell
import Quickshell.Io

import "widgets"

// import "components"
// import "services"

ShellRoot {
    id: root

    property var outputs: ({})

    // ИЗМЕНЕНИЕ: если workspace всё ещё на том же мониторе,
    // ничего не делаем. Поэтому переключение рабочих столов
    // на одном мониторе не запускает анимацию.
    function move(id) {
        const name = root.outputs[id];

        if (panel.screen?.name === name)
            return;

        for (const screen of Quickshell.screens) {
            if (screen.name === name) {
                animation.screen = screen;
                animation.start();
                break;
            }
        }
    }

    // Анимация: исчезновение → перенос → появление
    SequentialAnimation {
        id: animation

        property var screen

        NumberAnimation {
            target: pill
            property: "opacity"
            to: 0
            duration: 150
            easing.type: Easing.InQuad
        }

        ScriptAction {
            script: panel.screen = animation.screen
        }

        NumberAnimation {
            target: pill
            property: "opacity"
            to: 1
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    Process {
        command: ["niri", "msg", "-j", "event-stream"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const e = JSON.parse(data);

                // ИЗМЕНЕНИЕ:
                // WorkspacesChanged теперь также используется
                // для восстановления панели после подключения/
                // отключения монитора.
                if (e.WorkspacesChanged) {
                    for (const ws of e.WorkspacesChanged.workspaces) {
                        root.outputs[ws.id] = ws.output;

                        if (ws.is_focused)
                            root.move(ws.id);
                    }
                }

                // Переключение фокуса между workspace.
                if (e.WorkspaceActivated?.focused)
                    root.move(e.WorkspaceActivated.id);
            }
        }
    }

    // qmllint disable uncreatable-type
    PanelWindow {
        id: panel

        anchors {
            top: true
        }

        implicitHeight: 120
        implicitWidth: 270
        exclusiveZone: 0

        mask: Region {
            item: pill
        }

        color: "transparent"

        Pill {
            id: pill

            ClockWidget {
                visible: !pill.controllMode
            }
            BatteryWidget {
                visible: pill.controllMode || percentage <= 10
            }
        }
    }
}
