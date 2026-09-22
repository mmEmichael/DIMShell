pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import "widgets"
import "components"

ShellRoot {
    id: root

    property var laptopScreen: null
    property var barScreen: null

    function updateScreen() {
        let laptop = null;

        for (const screen of Quickshell.screens) {
            if (screen.name === "eDP-1") {
                laptop = screen;
                break;
            }
        }

        laptopScreen = laptop;

        let newScreen = null;

        if (laptop !== null) {
            newScreen = laptop;
        } else if (Quickshell.screens.length > 0) {
            newScreen = Quickshell.screens[0];
        }

        if (barScreen === newScreen)
            return;

        barLoader.active = false;

        barScreen = newScreen;

        barLoader.active = barScreen !== null;
    }

    Component.onCompleted: updateScreen()

    Connections {
        target: Quickshell

        function onScreensChanged() {
            root.updateScreen();
        }
    }

    Loader {
        id: barLoader

        active: root.barScreen !== null

        sourceComponent: PanelWindow {
            id: bar

            screen: root.barScreen

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 35
            exclusiveZone: 18

            color: "transparent"

            focusable: true

            BatteryPuller {
                id: batPuller
            }

            VolumePuller {
                id: globalVolume

                onVolumeChangedExternally: {
                    if (pill.mode !== "ControllCenter") {
                        pill.mode = "Volume";
                        volumeWidget.expanded = true;
                        pill.restartResetTimer();
                    }
                }
            }

            Pill {
                id: pill
                anchors.centerIn: parent

                Clock {
                    visible: pill.mode === "Clock"
                }

                Volume {
                    id: volumeWidget
                    visible: pill.mode === "ControllCenter" || pill.mode === "Volume"

                    volume: globalVolume.volume

                    onVolumeChangedByUi: val => globalVolume.setVolume(val)
                }

                BatteryWidget {
                    visible: pill.mode === "ControllCenter" || pill.mode === "Battery" || batPuller.isLow

                    isCharging: batPuller.isCharging
                    percentage: batPuller.percentage
                }
            }
        }
    }
}
