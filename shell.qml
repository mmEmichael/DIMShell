// shell.qml

import QtQuick
import Quickshell
import Quickshell.Wayland

// Подключаем папку с компонентами.
import "components"

ShellRoot {
    PanelWindow {
        id: mainWindow

        anchors {
            top: true
            left: true
            right: true
        }

        margins {
            top: 4
        }

        // Высота окна. Должна быть больше высоты островка,
        // чтобы был запас для анимации.
        implicitHeight: 32

        color: "transparent"

        // Наш компонент.
        ClockIsland {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
        }
    }
}
