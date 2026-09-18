// components/ClockIsland.qml

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick.Layouts


Item {
    id: clockIsland

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

        width: clockIsland.mode === "clock" ? 96 : 240
        height: 32

        radius: height / 3
        color: "#000000"

        // Плавное изменение ширины при смене режима.
        Behavior on width {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        // === ЧАСЫ ===
        Text {
            id: timeText
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            horizontalAlignment: Text.AlignHCenter

            text: Qt.formatDateTime(systemClock.date, "HH:mm")

            color: "white"
            font.pixelSize: 16

            // Плавное исчезновение/появление часов.
            opacity: clockIsland.mode === "clock" ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }

        // === СТРОКА Звук ===
        RowLayout {
            id: volumeContent

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter

            spacing: 12

            // Плавное появление/исчезновение контента громкости.
            opacity: clockIsland.mode === "volume" ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
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

                    width: parent.width * (Pipewire.defaultAudioSink?.audio?.volume ?? 0)

                    // Плавное изменение заливки.
                    Behavior on width {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
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
