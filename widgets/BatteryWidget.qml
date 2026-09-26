import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

import "../components"

Item {
    id: root

    property bool expanded: false
    property bool menuMode: false
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

        RowLayout {
            id: percentageView
            visible: !root.menuMode
            IconDIMS {
                icon: root.get_bat_icon(root.percentage)
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
            TapHandler {
                onTapped: {
                    root.menuMode = true;
                }
            }
        }

        // === Menu ===
        RowLayout {
            id: menuView
            visible: root.menuMode

            spacing: 6
            IconDIMS {
                id: back
                icon: ""
                color: "gray"

                TapHandler {
                    onTapped: {
                        root.menuMode = false;
                    }
                }
            }
            IconDIMS {
                id: balanced
                icon: "󰾅"
                color: PowerProfiles.profile === PowerProfile.Balanced ? "white" : "gray"
                size: PowerProfiles.profile === PowerProfile.Balanced ? 16 : 12
                TapHandler {
                    onTapped: {
                        PowerProfiles.profile = PowerProfile.Balanced;
                    }
                }

                Behavior on size {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            IconDIMS {
                id: powerSave
                icon: "󰾆"
                color: PowerProfiles.profile === PowerProfile.PowerSaver ? "white" : "gray"
                size: PowerProfiles.profile === PowerProfile.PowerSaver ? 16 : 12
                TapHandler {
                    onTapped: {
                        PowerProfiles.profile = PowerProfile.PowerSaver;
                    }
                }

                Behavior on size {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            IconDIMS {
                id: perfomance
                icon: "󰓅"
                color: PowerProfiles.profile === PowerProfile.Performance ? "white" : "gray"
                size: PowerProfiles.profile === PowerProfile.Performance ? 16 : 12
                TapHandler {
                    onTapped: {
                        PowerProfiles.profile = PowerProfile.Performance;
                    }
                }

                Behavior on size {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
        // ===

        HoverHandler {
            onHoveredChanged: {
                root.expanded = hovered;
            }
        }
    }
}
