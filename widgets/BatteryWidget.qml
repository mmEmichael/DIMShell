import QtQuick
import QtQuick.Layouts

import "../components"

Item {
    id: root

    property int percentage: 50
    property bool isCharging: false
    property bool isFull: false

    implicitWidth: textWidget.implicitWidth
    implicitHeight: textWidget.implicitHeight

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

    TextWidget {
        id: textWidget

        emoji: root.getBatteryEmoji(root.percentage, root.isCharging, root.isFull)
        text: root.percentage
    }
}
