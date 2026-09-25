import QtQuick
import Quickshell

import "widgets"

// import "components"
// import "services"

ShellRoot {
    id: root

    // qmllint disable uncreatable-type
    PanelWindow {
        id: panel
        anchors {
            top: true
        }

        implicitHeight: 120
        implicitWidth: 270
        exclusiveZone: 16 // высота таблетки 32 + отступ сверху 2 + отступ снизу 2 - niri gap 20

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
