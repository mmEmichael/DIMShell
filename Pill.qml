import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: pill

    implicitWidth: layout.implicitWidth + 16
    implicitHeight: layout.implicitHeight + 8

    width: implicitWidth
    height: implicitHeight

    radius: height / 3

    color: "black"

    property bool menuMode: false

    default property alias content: layout.data

    RowLayout {
        id: layout

        anchors.centerIn: parent
        spacing: 10
    }

    TapHandler {
        acceptedButtons: Qt.RightButton

        onTapped: {
            menuMode = !menuMode;
        }
    }

    Behavior on width {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }
}
