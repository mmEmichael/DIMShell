import QtQuick
import QtQuick.Layouts
import Quickshell

import "../components"

Item {
    id: root

    property bool expanded: false

    implicitHeight: row.implicitHeight
    implicitWidth: row.implicitWidth

    SystemClock {
        id: clock
        precision: SystemClock.Seconds  // обновление каждую секунду
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 0

        TextDIMS {
            text: Qt.formatDateTime(clock.date, "HH:mm")
        }
        TextDIMS {
            id: seconds
            text: Qt.formatDateTime(clock.date, ":ss")

            opacity: root.expanded
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutCubic
                }
            }
        }

        HoverHandler {
            onHoveredChanged: {
                root.expanded = hovered;
            }
        }
    }
}
