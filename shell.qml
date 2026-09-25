import QtQuick
import Quickshell
import Quickshell.Io

import "widgets"

// import "components"
// import "services"

ShellRoot {
    id: root

    property var outputs: ({})

    function move(id) {
        const name = root.outputs[id];

        for (const screen of Quickshell.screens) {
            if (screen.name === name) {
                animation.screen = screen;
                animation.start();
                break;
            }
        }
    }

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

                if (e.WorkspacesChanged) {
                    for (const ws of e.WorkspacesChanged.workspaces)
                        root.outputs[ws.id] = ws.output;
                }

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
            item: pill // Маска автоматически примет форму и раз меры этого элемента
        }

        color: "transparent"

        Pill {
            id: pill
            ClockWidget {
                visible: !pill.controllMode
            }
        }
    }
}
