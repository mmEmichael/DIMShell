import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string emoji: ""
    property string text: ""
    property bool expanded: false
    property bool disableHover: false

    Layout.alignment: Qt.AlignVCenter
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    RowLayout {
        id: row
        spacing: text.opacity > 0 ? 4 : 0

        Text {
            id: emojiText
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 16
            color: "white"
            text: root.emoji
        }

        Text {
            id: text
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 16
            color: "white"
            text: root.text

            opacity: root.expanded ? 1 : 0
            Layout.preferredWidth: opacity > 0 ? implicitWidth : 0
            clip: true

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Behavior on spacing {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }

    HoverHandler {
        enabled: !root.disableHover
        onHoveredChanged: root.expanded = !root.expanded
    }
}
