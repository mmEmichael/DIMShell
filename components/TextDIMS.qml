import QtQuick

Item {
    id: root

    property string text: ""
    property var color: "white"

    implicitHeight: text.implicitHeight
    implicitWidth: text.implicitWidth

    Text {
        id: text
        text: root.text
        color: root.color
        font.pixelSize: 16
        font.family: "JetBrainsMono Nerd Font Mono"
    }
}
