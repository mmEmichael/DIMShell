import QtQuick

Item {
    id: root

    property string text: ""

    implicitHeight: text.implicitHeight
    implicitWidth: text.implicitWidth

    Text {
        id: text
        text: root.text
        color: "white"
        font.pixelSize: 16
        font.family: "JetBrainsMono Nerd Font Mono"
    }
}
