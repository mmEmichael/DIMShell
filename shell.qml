import QtQuick
import Quickshell

ShellRoot {
    id: root

    property bool appMenuOpen: false

    PanelWindow {
        id: bar

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 34

        color: "transparent"

        Pill {
            id: pill
            anchors.centerIn: parent

            Clock {
                visible: pill.menuMode
            }
            Battery {
                visible: !pill.menuMode
            }
        }
    }
}
