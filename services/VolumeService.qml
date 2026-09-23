import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: puller

    property int volume: 0
    property bool isMuted: false

    // true только когда изменение пришло извне UI
    signal volumeChangedExternally(int volume)
    signal muteChangedExternally(bool muted)

    readonly property var sink: Pipewire.defaultAudioSink

    PwObjectTracker {
        objects: [puller.sink]
    }

    function setVolume(value) {
        if (!sink || !sink.audio)
            return;
        sink.audio.volume = value / 100;
    }

    function setMuted(muted) {
        if (!sink || !sink.audio)
            return;
        sink.audio.muted = muted;
    }

    Connections {
        target: puller.sink?.audio ?? null

        function onVolumeChanged() {
            if (!puller.sink?.audio)
                return;
            const newVolume = Math.round(puller.sink.audio.volume * 100);

            if (newVolume === puller.volume)
                return;
            puller.volume = newVolume;
            puller.volumeChangedExternally(newVolume);
        }

        function onMutedChanged() {
            if (!puller.sink?.audio)
                return;
            const newMuted = puller.sink.audio.muted;

            if (newMuted === puller.isMuted)
                return;
            puller.isMuted = newMuted;
            puller.muteChangedExternally(newMuted);
        }
    }

    Connections {
        target: Pipewire

        function onDefaultAudioSinkChanged() {
            if (!puller.sink?.audio)
                return;
            puller.volume = Math.round(puller.sink.audio.volume * 100);
            puller.isMuted = puller.sink.audio.muted;
        }
    }

    Component.onCompleted: {
        if (sink?.audio) {
            volume = Math.round(sink.audio.volume * 100);
            isMuted = sink.audio.muted;
        }
    }
}
