// components/ClockIsland.qml

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire


Item {
    id: clockIsland

    // Желаемые размеры. Реальные размеры задаются внутри Rectangle.
    implicitWidth: 96
    implicitHeight: 32

    // === СОСТОЯНИЕ ===
    // Управляет тем, раскрыт островок или нет.
    // Снаружи к нему можно обратиться как clock.isExpanded
    property bool isExpanded: false

    // === ИСТОЧНИК ВРЕМЕНИ ===
    // SystemClock — встроенный компонент Quickshell.
    // Он сам обновляется с нужной точностью.
    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio ?? null
        function onVolumeChanged() {
            clockIsland.isExpanded = true;
            autoCollapseTimer.restart();
        }
    }

    Timer {
        id: autoCollapseTimer
        interval: 2500
        repeat: false
        onTriggered: {
            clockIsland.isExpanded = false;
        }
    }

    // === ФОН (ТАБЛЕТКА) ===
    Rectangle {
        id: island

        // Центрируем по горизонтали, прижимаем к верху.
        anchors.horizontalCenter: parent.horizontalCenter
        // anchors.top: parent.top

        // Размеры зависят от состояния.
        width: clockIsland.isExpanded ? 288 : 96
        height: clockIsland.isExpanded ? 32 : 32

        radius: height / 3
        color: "#000000"

        // Плавная анимация ширины.
        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        // Плавная анимация высоты.
        Behavior on height {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        // === ЧАСЫ ===
        Text {
            id: timeText

            // В свернутом состоянии — по центру.
            // В раскрытом — сдвигаем влево, чтобы освободить место для иконок.
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: clockIsland.isExpanded ? 20 : 0

            // Ширина: в свернутом состоянии занимает всю таблетку (для центрирования),
            // в раскрытом — фиксированная (70px).
            width: clockIsland.isExpanded ? 70 : parent.width

            horizontalAlignment: Text.AlignHCenter

            // Qt.formatDateTime — удобный способ форматирования даты.
            // systemClock.date — текущее время.
            text: Qt.formatDateTime(systemClock.date, "HH:mm")

            color: "white"
            font.pixelSize: 16

            // Анимация ширины (чтобы текст плавно смещался).
            Behavior on width {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            // Анимация отступа слева.
            Behavior on anchors.leftMargin {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }
        }

        // === СТРОКА С ИКОНКАМИ (Wi-Fi, Звук, Батарея) ===
        Row {
            id: statusRow

            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter

            spacing: 18

            // Видимость зависит от состояния.
            opacity: clockIsland.isExpanded ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }

            // Иконки. Пока это просто символы шрифта Nerd Fonts.
            // Позже мы заменим их на реальные данные.
            Text {
                text: "󰤨"  // Wi-Fi
                color: "white"
                font.pixelSize: 18
            }

            // Text {
            //     text: "󰕾"  // Громкость
            //     color: "white"
            //     font.pixelSize: 18
            // }

            Item {
                id: volumeIndicator
                width: 60
                height: 6
                anchors.verticalCenter: parent.verticalCenter

                // Фон полосы (серая подложка).
                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: "#333333"
                }

                // Заливка (белая часть, показывающая громкость).
                Rectangle {
                    id: volumeFill
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    radius: height / 2
                    color: "white"

                    // Ширина заливки зависит от громкости.
                    width: parent.width * (Pipewire.defaultAudioSink?.audio?.volume ?? 0)

                    Behavior on width {
                        NumberAnimation { duration: 100 }
                    }
                }
            }

            Text {
                text: "󰁹"  // Батарея
                color: "white"
                font.pixelSize: 18
            }
        }

        // === ОБРАБОТКА КЛИКА ===
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                clockIsland.isExpanded = !clockIsland.isExpanded;
                if (clockIsland.isExpanded) {
                    autoCollapseTimer.restart();
                }
            }
        }
    }
}
