// WifiWidget.qml
import QtQuick
import QtQuick.Layouts
import "../components"

Item {
    id: root

    // Данные из пуллера (wifiEnabled вместо enabled)
    property bool wifiEnabled: false
    property string ssid: ""
    property int signal: 0
    property bool isConnected: false
    property var networks: []

    signal networkSelected(string ssid)

    implicitWidth: textWidget.implicitWidth
    implicitHeight: textWidget.implicitHeight

    readonly property int activeIndex: {
        if (!isConnected)
            return -1;
        for (let i = 0; i < networks.length; i++)
            if (networks[i].ssid === ssid)
                return i;
        return -1;
    }

    readonly property var ssidList: networks.map(n => n.ssid)

    function getWifiEmoji(en, conn, sig) {
        if (!en)
            return "📵";
        if (!conn)
            return "📶";
        if (sig >= 75)
            return "📶";
        if (sig >= 40)
            return "📶";
        return "📶";
    }

    ScrollListWidget {
        id: textWidget

        emoji: root.getWifiEmoji(root.wifiEnabled, root.isConnected, root.signal)
        model: root.ssidList
        currentIndex: root.activeIndex >= 0 ? root.activeIndex : 0
        selectedIndex: root.activeIndex

        // Под длинные имена сетей
        itemWidth: 110
        visibleItems: 3
        fontSize: 13
        wheelSensitivity: 3

        onItemClicked: index => {
            const net = root.networks[index];
            if (net)
                root.networkSelected(net.ssid);
        }
    }
}
