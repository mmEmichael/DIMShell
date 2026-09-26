import QtQuick

Item {
    id: root

    property string icon: ""
    property string color: "white"
    property int size: 16

    implicitHeight: text.implicitHeight
    implicitWidth: text.implicitWidth

    Text {
        id: text
        text: root.icon
        color: root.color
        font.pixelSize: root.size
        font.family: "JetBrainsMono Nerd Font"
    }
}
