pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    // Общие свойства (как в примерах)
    property string emoji: ""
    property var model: []
    property int currentIndex: 0
    property bool expanded: false
    property bool disableHover: false

    // Компактные размеры
    property int itemWidth: 40
    property int itemHeight: 20
    property int visibleItems: 3
    property int fontSize: 14

    // Чувствительность колёсика
    property int wheelSensitivity: 3

    // Визуальный выбор
    property int selectedIndex: -1

    signal itemClicked(int index)
    signal currentIndexChangedByUi(int index)
    signal itemSelected(int index)

    property int _wheelAccum: 0

    implicitWidth: row.implicitWidth
    implicitHeight: itemHeight

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: listContainer.width > 0 ? 4 : 0

        // Эмодзи всегда видно, оно же — "якорь" развёрнутого состояния
        Text {
            id: emojiText
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 16
            color: "white"
            text: root.emoji
        }

        // Контейнер списка: ширина анимируется между 0 и полной
        Item {
            id: listContainer
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: root.expanded ? root.itemWidth * root.visibleItems : 0
            Layout.preferredHeight: root.itemHeight
            clip: true
            opacity: root.expanded ? 1.0 : 0.0

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.InOutQuad
                }
            }

            ListView {
                id: listView
                anchors.fill: parent
                orientation: ListView.Horizontal
                model: root.model
                interactive: false
                currentIndex: root.currentIndex

                preferredHighlightBegin: (width - root.itemWidth) / 2
                preferredHighlightEnd: (width + root.itemWidth) / 2
                highlightRangeMode: ListView.StrictlyEnforceRange
                highlightMoveDuration: 200
                snapMode: ListView.SnapToItem

                onCurrentIndexChanged: {
                    if (root.currentIndex !== currentIndex) {
                        root.currentIndex = currentIndex;
                        root.currentIndexChangedByUi(currentIndex);
                    }
                }

                delegate: Item {
                    id: delegateItem

                    required property int index
                    required property var modelData

                    width: root.itemWidth
                    height: root.itemHeight

                    readonly property real dist: {
                        const centerX = listView.width / 2;
                        const itemCenterX = x + width / 2 - listView.contentX;
                        return Math.min(1.0, Math.abs(itemCenterX - centerX) / (listView.width / 2));
                    }

                    readonly property bool isSelected: root.selectedIndex === delegateItem.index

                    // Текст с тенью-обводкой
                    Item {
                        id: textStack
                        anchors.centerIn: parent
                        width: textItem.implicitWidth
                        height: textItem.implicitHeight

                        Repeater {
                            model: [
                                {
                                    dx: -1,
                                    dy: 0
                                },
                                {
                                    dx: 1,
                                    dy: 0
                                },
                                {
                                    dx: 0,
                                    dy: -1
                                },
                                {
                                    dx: 0,
                                    dy: 1
                                }
                            ]
                            Text {
                                required property var modelData
                                text: textItem.text
                                font: textItem.font
                                color: "black"
                                opacity: 0.85
                                x: textItem.x + modelData.dx
                                y: textItem.y + modelData.dy
                            }
                        }

                        Text {
                            id: textItem
                            anchors.centerIn: parent
                            text: delegateItem.modelData
                            color: "white"
                            font.pixelSize: root.fontSize
                        }
                    }

                    opacity: 1.0 - delegateItem.dist * 0.6
                    scale: 1.0 - delegateItem.dist * 0.3
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }
                    }

                    // Точка-индикатор выбора
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -3
                        width: 4
                        height: 4
                        radius: 2
                        color: "white"
                        opacity: delegateItem.isSelected ? 1.0 : 0.0
                        scale: delegateItem.isSelected ? 1.0 : 0.3
                        visible: opacity > 0.01

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.InOutQuad
                            }
                        }
                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    // Hover — только подсветка курсора (без побочек)
                    HoverHandler {
                        enabled: !root.disableHover && root.expanded
                        cursorShape: Qt.PointingHandCursor
                    }

                    // Клик/тап по элементу
                    TapHandler {
                        enabled: root.expanded
                        acceptedButtons: Qt.LeftButton
                        gesturePolicy: TapHandler.ReleaseWithinBounds
                        onTapped: {
                            listView.currentIndex = delegateItem.index;
                            root.currentIndex = delegateItem.index;
                            root.selectedIndex = delegateItem.index;
                            root.itemSelected(delegateItem.index);
                            root.itemClicked(delegateItem.index);
                        }
                    }
                }
            }

            // Прокрутка колёсиком — вешаем на контейнер списка
            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                enabled: root.expanded
                onWheel: event => {
                    if (!root.model || root.model.length === 0)
                        return;
                    root._wheelAccum += event.angleDelta.y;
                    const step = 120 * Math.max(1, root.wheelSensitivity);

                    while (Math.abs(root._wheelAccum) >= step) {
                        const dir = root._wheelAccum > 0 ? -1 : 1;
                        root._wheelAccum -= (root._wheelAccum > 0 ? step : -step);

                        const newIndex = root.currentIndex + dir;
                        if (newIndex < 0 || newIndex >= root.model.length) {
                            root._wheelAccum = 0;
                            break;
                        }

                        listView.currentIndex = newIndex;
                        root.currentIndex = newIndex;
                        root.currentIndexChangedByUi(newIndex);
                    }
                }
            }
        }
    }

    // Разворачивание/сворачивание по наведению (как в textWidget/sliderWidget)
    HoverHandler {
        id: hoverToggle
        enabled: !root.disableHover
        onHoveredChanged: root.expanded = hovered
    }
}
