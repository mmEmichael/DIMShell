import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    property string emoji: ""
    property int value: 0
    property bool expanded: false
    property bool disableHover: false

    signal valueChangedByUi(int value)

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    RowLayout {
        id: row
        spacing: slider.opacity > 0 ? 4 : 0

        Text {
            id: emojiText
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 16
            color: "white"
            text: root.emoji
        }

        Slider {
            id: slider

            implicitWidth: 50

            from: 0
            to: 100
            stepSize: 2

            value: root.value

            opacity: root.expanded ? 1 : 0

            Layout.preferredWidth: opacity > 0 ? implicitWidth : 0

            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2

                implicitWidth: 200
                implicitHeight: 4

                width: slider.availableWidth
                height: implicitHeight

                radius: 2
                color: Qt.alpha("#ffffff", 0.3)

                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height

                    radius: 2
                    color: "#ffffff"
                }
            }

            handle: Item {
                implicitWidth: 0
                implicitHeight: 0
            }

            onMoved: {
                root.valueChangedByUi(Math.round(value));
            }

            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

                onWheel: event => {
                    const delta = event.angleDelta.y > 0 ? slider.stepSize : -slider.stepSize;

                    const newValue = Math.max(slider.from, Math.min(slider.to, slider.value + delta));

                    if (newValue !== slider.value) {
                        slider.value = newValue;
                        root.valueChangedByUi(newValue);
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
        enabled: !root.disableHover
        onHoveredChanged: {
            root.expanded = hovered;
        }
    }
}
