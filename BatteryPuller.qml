import QtQuick
import Quickshell.Io

Item {
    id: puller

    // Глобальные свойства, которые мы будем читать из Shell.qml
    property int percentage: 0
    property bool isCharging: false
    property bool isFull: false
    property bool isLow: false

    Process {
        id: batteryProc
        command: ["bash", "-c", "BAT=$(ls /sys/class/power_supply/ | grep -E '^BAT[0-9]' | head -n 1); if [ -n \"$BAT\" ]; then echo \"$(cat /sys/class/power_supply/$BAT/capacity) $(cat /sys/class/power_supply/$BAT/status)\"; fi"]

        // НАСТРОЙКА ЧТЕНИЯ ВЫВОДА:
        // Подключаем StdioCollector, чтобы собирать данные из stdout
        stdout: StdioCollector {
            // Срабатывает, когда bash-скрипт завершил выполнение и закрыл поток
            onStreamFinished: {
                let output = text.trim(); // text — встроенное свойство StdioCollector
                if (!output)
                    return;

                let parts = output.split(" ");
                let percent = parseInt(parts[0]);
                let status = parts[1]; // Charging, Discharging, Full, etc.

                if (!isNaN(percent)) {
                    puller.percentage = percent;
                    puller.isCharging = (status === "Charging");
                    puller.isFull = (status === "Full" || percent === 100);
                    puller.isLow = (status !== "Charging" && percent < 20);
                }
            }
        }
    }

    Timer {
        id: timer
        interval: 10000 // опрос каждые 10 секунд
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: batteryProc.running = true
    }
}
