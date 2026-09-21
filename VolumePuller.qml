import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: puller

    // Глобальное свойство громкости (0-100)
    property int volume: 50
    // Флаг отключенного звука (Mute)
    property bool isMuted: false

    // Функция, которую мы будем вызывать из виджета для установки громкости
    function setVolume(newValue) {
        let volumeValue = newValue / 100;
        Quickshell.execDetached({
            command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", volumeValue.toFixed(2)]
        });
        // Сразу обновляем локальное значение, чтобы интерфейс не дергался в ожидании таймера
        puller.volume = newValue;
    }

    Process {
        id: volumeGetProc
        // Команда возвращает строку вида "Volume: 0.50" или "Volume: 0.50 [MUTED]"
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]

        stdout: StdioCollector {
            onStreamFinished: {
                let output = text.trim();
                if (!output)
                    return;

                // Проверяем статус Mute
                puller.isMuted = output.includes("[MUTED]");

                // Извлекаем числовое значение громкости
                let match = output.match(/Volume:\s+([0-9.]+)/);
                if (match && match[1]) {
                    let volFloat = parseFloat(match[1]);
                    let volInt = Math.round(volFloat * 100);

                    // Обновляем свойство, только если оно реально изменилось извне
                    if (volInt !== puller.volume) {
                        puller.volume = volInt;
                    }
                }
            }
        }
    }

    Timer {
        id: timer
        interval: 1000 // Опрашиваем систему раз в секунду
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: volumeGetProc.running = true
    }
}
