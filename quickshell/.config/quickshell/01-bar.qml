import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

ShellRoot {
    PanelWindow {
        id: panel
        anchors {
            bottom: true
            left: true
            right: true
        }
        margins {
            left: 10
            right: 10
            bottom: 10
            top: 0
        }
        implicitHeight: 150
        exclusiveZone: 40
        color: Colors.transparent

        mask: Region {
            item: barContainer
        }

        QtObject {
            id: globals
            readonly property string fontFamily: "Inter"
            readonly property string iconFont: "JetBrainsMono Nerd Font"
        }

        function getIcon(cls) {
            const icons = {
                "Brave-browser": "󰈹",
                "Alacritty": "󰆍",
                "code-oss": "󰨞",
                "discord": "󰙯",
                "Spotify": "",
                "thunar": "󰉋",
                "pavucontrol": "󰓃"
            };
            return icons[cls] || "󰖲";
        }

        // Border + Background Rectangle
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 40
            color: Colors.base
            border.color: Colors.accent
            border.width: 1
            radius: 10
        }

        Item {
            id: barContainer
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 40

            // Logo
            Image {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 20
                source: "arch-accent.svg"
                width: 24
                height: 24
            }

            // Separator after logo
            Rectangle {
                id: logoSeparator
                anchors.left: parent.left
                anchors.leftMargin: 54
                anchors.verticalCenter: parent.verticalCenter
                width: 2
                height: parent.height - 10
                color: Colors.separator
            }

            // Media Controls Container (properly sized to center controls)
            Item {
                id: mediaControlsContainer
                anchors.left: logoSeparator.right
                anchors.verticalCenter: parent.verticalCenter
                width: 130
                height: parent.height

                property var currentPlayer: Mpris.players.values[0] || null

                Row {
                    spacing: 24
                    anchors.centerIn: parent
                    visible: mediaControlsContainer.currentPlayer !== null

                    // Previous button
                    Text {
                        text: "󰒮"
                        color: Colors.accent
                        font.pixelSize: 20
                        font.family: globals.iconFont
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                        opacity: mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.canGoPrevious ? 1.0 : 0.5

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.canGoPrevious) {
                                    mediaControlsContainer.currentPlayer.previous();
                                }
                            }
                            hoverEnabled: true
                            onEntered: if (mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.canGoPrevious)
                                parent.opacity = 0.8
                            onExited: parent.opacity = mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.canGoPrevious ? 1.0 : 0.5
                        }
                    }

                    // Play/Pause button
                    Text {
                        text: mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                        color: Colors.accent
                        font.pixelSize: 20
                        font.family: globals.iconFont
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (mediaControlsContainer.currentPlayer) {
                                    if (mediaControlsContainer.currentPlayer.playbackState === MprisPlaybackState.Playing) {
                                        if (mediaControlsContainer.currentPlayer.canPause) {
                                            mediaControlsContainer.currentPlayer.pause();
                                        }
                                    } else {
                                        if (mediaControlsContainer.currentPlayer.canPlay) {
                                            mediaControlsContainer.currentPlayer.play();
                                        }
                                    }
                                }
                            }
                            hoverEnabled: true
                            onEntered: parent.opacity = 0.8
                            onExited: parent.opacity = 1.0
                        }
                    }

                    // Next button
                    Text {
                        text: "󰒭"
                        color: Colors.accent
                        font.pixelSize: 20
                        font.family: globals.iconFont
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                        opacity: mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.canGoNext ? 1.0 : 0.5

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.canGoNext) {
                                    mediaControlsContainer.currentPlayer.next();
                                }
                            }
                            hoverEnabled: true
                            onEntered: if (mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.canGoNext)
                                parent.opacity = 0.8
                            onExited: parent.opacity = mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.canGoNext ? 1.0 : 0.5
                        }
                    }
                }
            }

            // Separator after media controls
            Rectangle {
                id: mediaControlsSeparator
                anchors.left: mediaControlsContainer.right
                anchors.verticalCenter: parent.verticalCenter
                width: 2
                height: parent.height - 10
                color: Colors.separator
                visible: mediaControlsContainer.currentPlayer !== null
            }

            // Media Info (song text)
            Item {
                id: mediaInfo
                anchors.left: mediaControlsSeparator.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                width: parent.width / 3 - 20
                height: parent.height

                property var currentPlayer: Mpris.players.values[0] || null

                // Function to truncate text
                function truncateText(text, maxLength) {
                    if (text.length <= maxLength)
                        return text;
                    return text.substring(0, maxLength) + "...";
                }

                Row {
                    spacing: 10
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 5

                    Text {
                        text: "󰎈"
                        color: Colors.accent
                        font.pixelSize: 20
                        font.family: globals.iconFont
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        text: {
                            if (mediaInfo.currentPlayer && mediaInfo.currentPlayer.metadata) {
                                var artist = mediaInfo.currentPlayer.metadata["xesam:artist"] || "";
                                var title = mediaInfo.currentPlayer.metadata["xesam:title"] || "";

                                if (Array.isArray(artist)) {
                                    artist = artist.join(", ");
                                }

                                var fullText = "";
                                if (artist && title) {
                                    fullText = artist + " - " + title;
                                }
                                return mediaInfo.truncateText(fullText, 50);
                            }
                            return "No media playing";
                        }
                        color: Colors.text
                        font.pixelSize: 16
                        font.family: globals.fontFamily
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Workspaces
            Row {
                id: workspaces
                anchors.centerIn: parent
                anchors.leftMargin: 0
                spacing: 12

                Repeater {
                    model: 5 // Number of workspaces

                    Rectangle {
                        width: (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === (index + 1)) ? 40 : 20
                        height: 20
                        radius: 10
                        color: (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === (index + 1)) ? Colors.accent : Colors.separator

                        // Smooth animation for width changes
                        Behavior on width {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }

                        // Smooth animation for color changes
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }

                        MouseArea {
                            id: wsMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Hyprland.dispatch("workspace " + (index + 1))
                        }

                        // Peek Popup
                        Rectangle {
                            visible: wsMouseArea.containsMouse
                            anchors.bottom: parent.top
                            anchors.bottomMargin: 12
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: Math.max(120, peekCol.implicitWidth + 24)
                            height: peekCol.implicitHeight + 16
                            color: Colors.base
                            border.color: Colors.accent
                            border.width: 1
                            radius: 8
                            opacity: visible ? 1.0 : 0.0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 150
                                }
                            }

                            Column {
                                id: peekCol
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    text: "Workspace " + (index + 1)
                                    color: Colors.accent
                                    font.bold: true
                                    font.pixelSize: 12
                                    font.family: globals.fontFamily
                                }

                                Repeater {
                                    model: Hyprland.toplevels.values.filter(t => t.workspace && t.workspace.id === (index + 1))

                                    Row {
                                        spacing: 8
                                        Text {
                                            text: panel.getIcon(modelData.class)
                                            color: Colors.accent
                                            font.pixelSize: 14
                                            font.family: globals.iconFont
                                        }
                                        Text {
                                            text: modelData.title.length > 20 ? modelData.title.substring(0, 20) + "..." : modelData.title
                                            color: Colors.text
                                            font.pixelSize: 12
                                            font.family: globals.fontFamily
                                        }
                                    }
                                }

                                // Show message if empty
                                Text {
                                    visible: Hyprland.toplevels.values.filter(t => t.workspace && t.workspace.id === (index + 1)).length === 0
                                    text: "Empty"
                                    color: Colors.separator
                                    font.pixelSize: 11
                                    font.family: globals.fontFamily
                                    font.italic: true
                                }
                            }
                        }
                    }
                }
            }

            // Right Side Widgets (Audio, Date, Time)
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                spacing: 15

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: {
                        timeHour.text = Qt.formatDateTime(new Date(), "h:mm:ss");
                        timeText.text = Qt.formatDateTime(new Date(), "dddd dd/MM/yy");
                    }
                }

                // Network
                Item {
                    id: networkMonitor
                    width: netRow.implicitWidth + 20
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter

                    property string netText: "󰌙 Disconnected"
                    property string netIcon: ""
                    property string netClass: "disconnected"

                    Process {
                        id: netProcess
                        running: true
                        command: ["python3", "~/.config/quickshell/network.py"]
                        stdout: SplitParser {
                            onRead: data => {
                                try {
                                    var parsed = JSON.parse(data);
                                    networkMonitor.netText = parsed.text || "󰌙 Disconnected";
                                    networkMonitor.netIcon = parsed.alt || "";
                                    networkMonitor.netClass = parsed.class || "disconnected";
                                } catch (e) {}
                            }
                        }
                    }

                    Row {
                        id: netRow
                        spacing: 8
                        anchors.centerIn: parent

                        Text {
                            text: networkMonitor.netIcon
                            color: Colors.accent
                            font.pixelSize: 20
                            font.family: globals.iconFont
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: networkMonitor.netText
                            color: Colors.text
                            font.pixelSize: 14
                            font.family: "Mono"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            netSelectProcess.running = true;
                        }
                        onEntered: parent.opacity = 0.8
                        onExited: parent.opacity = 1.0
                    }

                    Process {
                        id: netSelectProcess
                        command: ["python3", "~/.config/quickshell/network.py", "--select"]
                    }
                }

                // Separator
                Rectangle {
                    width: 2
                    height: 30
                    color: Colors.separator
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Audio (Volume)
                Item {
                    id: volume
                    width: 80
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter

                    property string volumeLevel: ""
                    property bool muted: false
                    property bool isToggling: false

                    Process {
                        id: volumeProcess
                        running: true
                        command: ["bash", "-c", "pactl subscribe | grep --line-buffered \"Event 'change' on sink\" | while read -r line; do pactl get-sink-volume @DEFAULT_SINK@ | grep -oE '[0-9]+%' | head -1; done"]
                        stdout: SplitParser {
                            onRead: data => {
                                var vol = data.trim().replace('%', '');
                                if (vol) {
                                    volume.volumeLevel = vol;
                                }
                            }
                        }
                    }

                    Process {
                        id: initialVolume
                        command: ["bash", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oE '[0-9]+%' | head -1"]
                        stdout: SplitParser {
                            onRead: data => {
                                var vol = data.trim().replace('%', '');
                                if (vol) {
                                    volume.volumeLevel = vol;
                                }
                            }
                        }
                    }

                    Process {
                        id: muteStatus
                        command: ["bash", "-c", "pactl get-sink-mute @DEFAULT_SINK@ | grep -oE 'yes|no'"]
                        stdout: SplitParser {
                            onRead: data => {
                                volume.muted = (data.trim() === "yes");
                                if (volume.isToggling)
                                    volume.isToggling = false;
                            }
                        }
                    }

                    Component.onCompleted: {
                        initialVolume.running = true;
                        muteStatus.running = true;
                    }

                    Row {
                        spacing: 5
                        anchors.centerIn: parent
                        clip: false

                        Text {
                            id: volumeIcon
                            width: 28
                            height: 28
                            text: volume.muted ? "󰖁" : "󰕾"
                            color: Colors.accent
                            font.pixelSize: 20
                            font.family: globals.iconFont
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                onClicked: {
                                    if (volume.isToggling)
                                        return;
                                    volume.isToggling = true;
                                    muteToggle.command = ["bash", "-c", "pactl set-sink-mute @DEFAULT_SINK@ toggle"];
                                    muteToggle.running = true;
                                    volume.muted = !volume.muted;
                                    muteStatusRefresh.start();
                                }

                                onEntered: parent.opacity = 0.6
                                onExited: parent.opacity = 1.0

                                Timer {
                                    id: muteStatusRefresh
                                    interval: 150
                                    repeat: false
                                    onTriggered: {
                                        muteStatus.running = true;
                                        volume.isToggling = false;
                                    }
                                }

                                Process {
                                    id: muteToggle
                                    command: []
                                }
                            }
                        }

                        Text {
                            id: volumeText
                            text: volume.volumeLevel ? volume.volumeLevel + "%" : "--"
                            color: Colors.text
                            font.pixelSize: 16
                            font.family: globals.fontFamily
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // Separator
                Rectangle {
                    width: 2
                    height: 30
                    color: Colors.separator
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Date
                Text {
                    id: timeText
                    text: Qt.formatDateTime(new Date(), "dddd dd/MM/yy")
                    color: Colors.text
                    font.pixelSize: 16
                    font.family: globals.fontFamily
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Separator
                Rectangle {
                    width: 2
                    height: 30
                    color: Colors.separator
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Time
                Row {
                    spacing: 10
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: "󰥔"
                        color: Colors.accent
                        font.pixelSize: 20
                        font.family: globals.iconFont
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: timeHour
                        text: Qt.formatDateTime(new Date(), "h:mma")
                        color: Colors.text
                        font.pixelSize: 16
                        font.family: globals.fontFamily
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
