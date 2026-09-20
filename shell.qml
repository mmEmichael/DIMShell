// shell.qml

import QtQuick
import Quickshell

ShellRoot {
    id: bar

    PanelWindow {
        id: mainWindow

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 34
        color: "transparent"
    }
}
