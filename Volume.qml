import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: volumeWidget

    property int volume: 0
    property bool expanded: false

    signal volumeChangedByUi(int value)

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    RowLayout {
        id: row

        spacing: volumeSlider.opacity > 0 ? 4 : 0

        Text {
            text: {
                if (volumeWidget.volume === 0)
                    return "🔇";

                if (volumeWidget.volume < 40)
                    return "🔈";

                return "🔊";
            }

            font.pointSize: 14
            color: "white"
        }

        Slider {
            id: volumeSlider

            implicitWidth: 50

            from: 0
            to: 100
            stepSize: 2

            value: volumeWidget.volume

            opacity: volumeWidget.expanded ? 1 : 0

            Layout.preferredWidth: opacity > 0 ? implicitWidth : 0

            onMoved: {
                volumeWidget.volumeChangedByUi(Math.round(value));
            }

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

                    radius: 2
                    color: "#ffffff"
                }
            }

            handle: Item {
                implicitWidth: 0
                implicitHeight: 0
            }

            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

                onWheel: event => {
                    const delta = event.angleDelta.y > 0 ? volumeSlider.stepSize : -volumeSlider.stepSize;

                    const newValue = Math.max(volumeSlider.from, Math.min(volumeSlider.to, volumeSlider.value + delta));

                    if (newValue !== volumeSlider.value) {
                        volumeSlider.value = newValue;
                        volumeWidget.volumeChangedByUi(newValue);
                    }
                }
            }

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
        onHoveredChanged: {
            volumeWidget.expanded = hovered;
        }
    }

    // Если громкость изменилась снаружи,
    // например аппаратными клавишами,
    // синхронизируем Slider.
    onVolumeChanged: {
        if (!volumeSlider.pressed)
            volumeSlider.value = volume;
    }
}
