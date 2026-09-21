import QtQuick
import QtQuick.Layouts

Item {
    id: batteryWidget

    Layout.alignment: Qt.AlignVCenter
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    property int percentage: 50
    property bool isCharging: false
    property bool isFull: false
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

    // TapHandler {
    //     onTapped: batteryWidget.expanded = !batteryWidget.expanded
    // }
    HoverHandler {
        onHoveredChanged: batteryWidget.expanded = !batteryWidget.expanded
    }
}
