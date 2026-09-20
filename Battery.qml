import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

Item {
    id: batteryWidget

    Layout.alignment: Qt.AlignVCenter
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    readonly property var battery: UPower.displayDevice
    property int percentage: battery.percentage ? Math.round(battery.percentage * 100) : 0
    property bool isCharging: battery.state === UPowerDeviceState.Charging
    property bool isFull: battery.state === UPowerDeviceState.FullyCharged
    property bool expanded: false

    function getBatteryEmoji(percent, charging, full) {
        if (charging)
            return "⚡";
        if (full)
            return "🔋";
        if (percent <= 10)
            return "🪫";
        if (percent <= 25)
            return "🪫";
        return "🔋";
    }

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: percentText.opacity > 0 ? 4 : 0

        Behavior on spacing {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        Text {
            id: emojiText
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 16
            color: "white"
            text: batteryWidget.getBatteryEmoji(batteryWidget.percentage, batteryWidget.isCharging, batteryWidget.isFull)
        }

        Text {
            id: percentText
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 16
            color: "white"
            text: batteryWidget.percentage

            opacity: batteryWidget.expanded ? 1 : 0
            Layout.preferredWidth: opacity > 0 ? implicitWidth : 0
            clip: true

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    TapHandler {
        onTapped: batteryWidget.expanded = !batteryWidget.expanded
    }
}
