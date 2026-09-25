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
