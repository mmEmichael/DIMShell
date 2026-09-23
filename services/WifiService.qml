// WifiPuller.qml
import QtQuick
import Quickshell.Io

Item {
    id: puller

    property bool wifiEnabled: false
    property string ssid: ""
    property int signal: 0
    property bool isConnected: false
    property bool isConnecting: false
    property var networks: []

    // --- Текущее состояние ---
    Process {
        id: stateProc

        // Разделяем на две команды явно
        command: ["bash", "-c", "nmcli -t -f SSID,SIGNAL,ACTIVE dev wifi 2>/dev/null; " + "echo '###'; " + "nmcli -t -f WIFI radio 2>/dev/null"]

        stdout: StdioCollector {
            onStreamFinished: {
                const raw = text.trim();
                if (!raw)
                    return;
                const parts = raw.split("###");
                const listPart = (parts[0] || "").trim();
                const radioPart = (parts[1] || "").trim();
                puller.wifiEnabled = (radioPart === "enabled");

                const result = [];
                let activeSsid = "";
                let activeSignal = 0;

                const lines = listPart.split("\n").filter(l => l.length > 0);
                for (const line of lines) {
                    // Формат: SSID:SIGNAL:ACTIVE
                    // ВАЖНО: SSID может быть пустым (скрытые сети) и может содержать ':'
                    // Разбираем с конца: последние два поля — SIGNAL и ACTIVE
                    const cols = line.split(":");
                    if (cols.length < 3)
                        continue;
                    const active = cols[cols.length - 1] === "yes";
                    const sig = parseInt(cols[cols.length - 2]) || 0;
                    const ssidName = cols.slice(0, cols.length - 2).join(":");
                    if (!ssidName)
                        continue;

                    // Пропускаем дубли (одна сеть может встретиться несколько раз)
                    if (result.some(n => n.ssid === ssidName))
                        continue;
                    result.push({
                        ssid: ssidName,
                        signal: sig,
                        active: active
                    });

                    if (active) {
                        activeSsid = ssidName;
                        activeSignal = sig;
                    }
                }

                result.sort((a, b) => b.signal - a.signal);

                puller.networks = result;
                puller.ssid = activeSsid;
                puller.signal = activeSignal;
                puller.isConnected = activeSsid.length > 0;

                console.log("WIFI networks:", JSON.stringify(result));
            }
        }
    }

    // --- Подключение к выбранной сети ---
    Process {
        id: connectProc
        property string targetSsid: ""
        command: ["bash", "-c", "nmcli dev wifi connect " + "'" + targetSsid.replace(/'/g, "'\\''") + "' 2>&1 || true"]

        onRunningChanged: {
            if (!running) {
                puller.isConnecting = false;
                stateProc.running = true;
            }
        }
    }

    function connectTo(ssidName) {
        if (!ssidName)
            return;
        puller.isConnecting = true;
        connectProc.targetSsid = ssidName;
        connectProc.running = true;
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: stateProc.running = true
    }
}
