// components/ClockIsland.qml

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick.Layouts


Item {
    id: clockIsland

    // Желаемые размеры. Реальные размеры задаются внутри Rectangle.
    implicitWidth: 96
    implicitHeight: 32

    // === СОСТОЯНИЕ ===
    property string mode: "clock"

    // === ИСТОЧНИК ВРЕМЕНИ ===
    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    // === Источник уровня громкости ===
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio ?? null
        function onVolumeChanged() {
            clockIsland.mode = "volume";
            autoCollapseTimer.restart();
        }
    }

    // === Таймер сброса состояния ===
    Timer {
        id: autoCollapseTimer
        interval: 2500
        repeat: false
        onTriggered: {
            clockIsland.mode = "clock";
        }
    }

    // === ФОН (ТАБЛЕТКА) ===
    Rectangle {
        id: island

        anchors.horizontalCenter: parent.horizontalCenter


        // Размеры зависят от состояния.
        width: clockIsland.mode === "clock" ? 96 : 240
        height: 32

        radius: height / 3
        color: "#000000"

        // Плавная анимация ширины.
        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        // === ЧАСЫ ===
        Text {
            id: timeText
            visible: clockIsland.mode === "clock"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            horizontalAlignment: Text.AlignHCenter

            // Qt.formatDateTime — удобный способ форматирования даты.
            // systemClock.date — текущее время.
            text: Qt.formatDateTime(systemClock.date, "HH:mm")

            color: "white"
            font.pixelSize: 16
        }

        // === СТРОКА Звук ===
        RowLayout {
            id: volumeContent
            visible: clockIsland.mode === "volume"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter

            // Видимость зависит от состояния.
            opacity: visible ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }

            Text {
                text: "󰕾"
                color: "white"
                font.pixelSize: 16
                Layout.alignment: Qt.AlignVCenter
            }

            Item {
                id: volumeIndicator
                Layout.fillWidth: true
                Layout.preferredHeight: 6

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
        }

        // === ОБРАБОТКА КЛИКА ===
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                clockIsland.mode = clockIsland.mode === "clock" ? "volume" : "clock";
                if (clockIsland.mode !== "clock") {
                    autoCollapseTimer.restart();
                }
            }
        }
    }
}
