import Quickshell
import QtQuick

Text {
    id: clockText

    // Создаем объект системных часов
    SystemClock {
        id: clock
        precision: SystemClock.Seconds // Обновление раз в секунду
    }

    // Форматируем дату и время через Qt.formatDateTime
    text: Qt.formatDateTime(clock.date, "hh:mm")
    font.pixelSize: 16
    color: "white"
}
