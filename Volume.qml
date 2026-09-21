import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: volumeWidget
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    property bool expanded: false

    // Свойство синхронизируется с Shell.qml
    property int volume: 50

    // Сигнал, который сообщает Shell.qml, что пользователь изменил громкость на панели
    signal volumeChangedByUi(int newVal)

    // Следим за изменениями громкости из системы (например, от горячих клавиш)
    onVolumeChanged: {
        // Обновляем ползунок, только если пользователь его сам не держит
        if (!volumeSlider.pressed) {
            volumeSlider.value = volume;
        }
    }

    RowLayout {
        id: row
        spacing: volumeSlider.opacity > 0 ? 4 : 0

        Behavior on spacing {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        Text {
            text: volumeWidget.volume === 0 ? "🔇" : (volumeWidget.volume < 40 ? "🔈" : "🔊")
            font.pointSize: 14
            color: "white"
        }

        Slider {
            id: volumeSlider

            // В развернутом состоянии ширина будет 120 пикселей
            implicitWidth: 50
            opacity: volumeWidget.expanded ? 1 : 0
            Layout.preferredWidth: opacity > 0 ? implicitWidth : 0

            from: 0
            to: 100
            value: volumeWidget.volume // Начальное значение берется из пуллера
            stepSize: 2 // Шаг в 2% удобнее для регулировки

            // Срабатывает при перетаскивании мышкой
            onMoved: {
                volumeWidget.volumeChangedByUi(Math.round(value));
            }

            // --- СТИЛИЗАЦИЯ (Белый тонкий минимализм) ---
            background: Rectangle {
                x: volumeSlider.leftPadding
                y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                implicitWidth: 200
                implicitHeight: 4
                width: volumeSlider.availableWidth
                height: implicitHeight
                radius: 2
                color: Qt.alpha("#ffffff", 0.3)

                Rectangle {
                    width: volumeSlider.visualPosition * parent.width
                    height: parent.height
                    color: "#ffffff"
                    radius: 2
                }
            }

            handle: Item {
                implicitWidth: 0
                implicitHeight: 0
            }

            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: event => {
                    let delta = event.angleDelta.y > 0 ? volumeSlider.stepSize : -volumeSlider.stepSize;
                    let newValue = Math.max(volumeSlider.from, Math.min(volumeSlider.to, volumeSlider.value + delta));

                    if (newValue !== volumeSlider.value) {
                        volumeSlider.value = newValue;
                        // Отправляем новое значение через сигнал пуллеру
                        volumeWidget.volumeChangedByUi(newValue);
                    }
                }
            }

            // --- АНИМАЦИИ ---
            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    HoverHandler {
        // Исправлено зацикливание при наведении
        onHoveredChanged: volumeWidget.expanded = hovered
    }
}
