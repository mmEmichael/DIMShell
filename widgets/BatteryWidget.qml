import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

import "../components"

Item {
    id: root

    property bool expanded: false
    property var battery: UPower.displayDevice
    property var battery_state: battery.state
    property int percentage: Math.round(battery.percentage * 100)

    implicitHeight: row.implicitHeight
    implicitWidth: row.implicitWidth

    function get_bat_icon(percentage) {
        if (battery_state === UPowerDeviceState.Charging)
            return "󰂄";
        if (percentage <= 5)
            return "󰂃";
        if (percentage <= 10)
            return "󰁺";
        if (percentage <= 20)
            return "󰁻";
        if (percentage <= 30)
            return "󰁼";
        if (percentage <= 40)
            return "󰁽";
        if (percentage <= 50)
            return "󰁾";
        if (percentage <= 60)
            return "󰁿";
        if (percentage <= 70)
            return "󰂀";
        if (percentage <= 80)
            return "󰂁";
        if (percentage <= 90)
            return "󰂂";
        return "󰁹"; // full
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        TextDIMS {
            text: root.get_bat_icon(root.percentage)
            // color: root.percentage < 20 ? "red" : "green"
        }
        TextDIMS {
            text: root.percentage

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
