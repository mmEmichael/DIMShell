import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property bool controllMode: false

    anchors.horizontalCenter: parent.horizontalCenter

    implicitHeight: 30
    implicitWidth: 90

    default property alias content: row.data

    Rectangle {
        id: rectangle
        anchors.margins: 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors {
            top: parent.top
        }
        color: "black"

        implicitHeight: row.implicitHeight + 10
        implicitWidth: row.implicitWidth + 10
        radius: 10

        RowLayout {
            id: row
            anchors.centerIn: rectangle
            spacing: 4
        }

        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: {
                root.controllMode = !root.controllMode;
            }
        }

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutCubic
            }
        }
        Behavior on implicitWidth {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutCubic
            }
        }
    }
}
