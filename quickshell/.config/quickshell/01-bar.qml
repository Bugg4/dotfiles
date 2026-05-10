import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ShellRoot {
    // Calendar Terminal Trigger
    Process {
        id: calProcess
        command: ["alacritty", "-e", "sh", "-c", "cal; read"]
    }


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
            item: barBackground
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

        // Helper to format tooltips with styled keys
        function formatTooltip(text, isAudio) {
            if (!text) return "";
            var lines = text.split("\n");
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i];
                if (isAudio && i === 0 && line.indexOf(":") === -1) {
                    lines[i] = "<font color='#F59A4C'><b>" + line + "</b></font>";
                } else {
                    lines[i] = line.replace(/^([^:\n]+:)/, "<font color='#F59A4C'><b>$1</b></font>");
                }
            }
            return lines.join("<br>");
        }

        // Helper to capitalize first letter
        function capitalize(str) {
            if (!str) return "";
            return str.charAt(0).toUpperCase() + str.slice(1);
        }

        // Border + Background Rectangle
        Rectangle {
            id: barBackground
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
            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 20
                text: ""
                color: Colors.accent
                font.pixelSize: 24
                font.family: globals.iconFont
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

                        // Peek Popup (Uniform Style)
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
                            z: 100

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
                        timeHour.text = (new Date()).toLocaleString(Qt.locale("it_IT"), "HH:mm:ss");
                        timeText.text = panel.capitalize((new Date()).toLocaleString(Qt.locale("it_IT"), "dddd dd/MM/yy"));
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
                    property string netTooltip: ""

                    Process {
                        id: netProcess
                        running: true
                        command: ["python3", Quickshell.shellDir + "/network.py"]
                        stdout: SplitParser {
                            onRead: data => {
                                try {
                                    var parsed = JSON.parse(data);
                                    networkMonitor.netText = parsed.text || "󰌙 Disconnected";
                                    networkMonitor.netIcon = parsed.alt || "";
                                    networkMonitor.netClass = parsed.class || "disconnected";
                                    networkMonitor.netTooltip = parsed.tooltip || "";
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
                        id: netMouseArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            netSelectProcess.running = true;
                        }
                        onEntered: netRow.opacity = 0.8
                        onExited: netRow.opacity = 1.0
                    }

                    // Network Tooltip (Uniform Style)
                    Rectangle {
                        visible: netMouseArea.containsMouse && networkMonitor.netTooltip !== ""
                        anchors.bottom: parent.top
                        anchors.bottomMargin: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: netTooltipText.implicitWidth + 24
                        height: netTooltipText.implicitHeight + 16
                        color: Colors.base
                        border.color: Colors.accent
                        border.width: 1
                        radius: 8
                        z: 100

                        Text {
                            id: netTooltipText
                            anchors.centerIn: parent
                            text: panel.formatTooltip(networkMonitor.netTooltip, false)
                            textFormat: Text.StyledText
                            color: Colors.text
                            font.pixelSize: 12
                            font.family: globals.fontFamily
                            lineHeight: 1.2
                        }
                    }

                    Process {
                        id: netSelectProcess
                        command: ["python3", Quickshell.shellDir + "/network.py", "--select"]
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
                    id: audioContainer
                    width: audioWidget.implicitWidth
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter

                    property string btTooltip: ""

                    Row {
                        id: audioWidget
                        spacing: 8
                        anchors.centerIn: parent

                        property string volumeLevel: ""
                        property bool muted: false
                        property bool isToggling: false
                        property string btText: ""
                        property string btIcon: ""
                        property bool btConnected: false

                        Process {
                            id: volumeProcess
                            running: true
                            command: ["bash", "-c", "pactl subscribe | grep --line-buffered \"Event 'change' on sink\" | while read -r line; do pactl get-sink-volume @DEFAULT_SINK@ | grep -oE '[0-9]+%' | head -1; done"]
                            stdout: SplitParser {
                                onRead: data => {
                                    var vol = data.trim().replace('%', '');
                                    if (vol) {
                                        audioWidget.volumeLevel = vol;
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
                                        audioWidget.volumeLevel = vol;
                                    }
                                }
                            }
                        }

                        Process {
                            id: muteStatus
                            command: ["bash", "-c", "pactl get-sink-mute @DEFAULT_SINK@ | grep -oE 'yes|no'"]
                            stdout: SplitParser {
                                onRead: data => {
                                    audioWidget.muted = (data.trim() === "yes");
                                    if (audioWidget.isToggling)
                                        audioWidget.isToggling = false;
                                }
                            }
                        }

                        Timer {
                            id: muteStatusRefresh
                            interval: 150
                            repeat: false
                            onTriggered: {
                                muteStatus.running = true;
                                audioWidget.isToggling = false;
                            }
                        }

                        Process {
                            id: muteToggle
                            command: []
                        }

                        Process {
                            id: btProcess
                            running: true
                            command: ["python3", Quickshell.shellDir + "/bluetooth.py"]
                            stdout: SplitParser {
                                onRead: data => {
                                    try {
                                        var parsed = JSON.parse(data);
                                        audioWidget.btText = parsed.text || "";
                                        audioWidget.btIcon = parsed.alt || "";
                                        audioWidget.btConnected = parsed.connected || false;
                                        audioContainer.btTooltip = parsed.tooltip || "";
                                    } catch (e) {}
                                }
                            }
                        }

                        Process {
                            id: btSelectProcess
                            command: ["python3", Quickshell.shellDir + "/bluetooth.py", "--select"]
                        }

                        Component.onCompleted: {
                            initialVolume.running = true;
                            muteStatus.running = true;
                        }

                        // Volume Section
                        Item {
                            width: volRowInternal.implicitWidth
                            height: 40
                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                id: volRowInternal
                                spacing: 5
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    id: volumeIcon
                                    width: 28
                                    height: 28
                                    text: audioWidget.muted ? "󰖁" : "󰕾"
                                    color: Colors.accent
                                    font.pixelSize: 20
                                    font.family: globals.iconFont
                                    anchors.verticalCenter: parent.verticalCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Text {
                                    id: volumeText
                                    text: audioWidget.volumeLevel ? audioWidget.volumeLevel + "%" : "--"
                                    color: Colors.text
                                    font.pixelSize: 16
                                    font.family: globals.fontFamily
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: volMouseArea
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                onClicked: {
                                    if (mouse.button === Qt.RightButton) {
                                        if (audioWidget.isToggling)
                                            return;
                                        audioWidget.isToggling = true;
                                        muteToggle.command = ["bash", "-c", "pactl set-sink-mute @DEFAULT_SINK@ toggle"];
                                        muteToggle.running = true;
                                        audioWidget.muted = !audioWidget.muted;
                                        muteStatusRefresh.start();
                                    } else {
                                        btSelectProcess.running = true;
                                    }
                                }

                                onEntered: parent.opacity = 0.6
                                onExited: parent.opacity = 1.0
                            }
                        }

                        // Bluetooth Section
                        Item {
                            width: btRowInternal.implicitWidth
                            height: 40
                            visible: audioWidget.btConnected
                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                id: btRowInternal
                                spacing: 5
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: audioWidget.btIcon
                                    color: Colors.accent
                                    font.pixelSize: 20
                                    font.family: globals.iconFont
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: audioWidget.btText
                                    color: Colors.text
                                    font.pixelSize: 16
                                    font.family: globals.fontFamily
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: btMouseArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: btSelectProcess.running = true
                                hoverEnabled: true
                                onEntered: parent.opacity = 0.6
                                onExited: parent.opacity = 1.0
                            }
                        }
                    }

                    // Audio Tooltip (Uniform Style)
                    Rectangle {
                        visible: (volMouseArea.containsMouse || btMouseArea.containsMouse) && audioContainer.btTooltip !== ""
                        anchors.bottom: parent.top
                        anchors.bottomMargin: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: btTooltipText.implicitWidth + 24
                        height: btTooltipText.implicitHeight + 16
                        color: Colors.base
                        border.color: Colors.accent
                        border.width: 1
                        radius: 8
                        z: 100

                        Text {
                            id: btTooltipText
                            anchors.centerIn: parent
                            text: panel.formatTooltip(audioContainer.btTooltip, true)
                            textFormat: Text.StyledText
                            color: Colors.text
                            font.pixelSize: 12
                            font.family: globals.fontFamily
                            lineHeight: 1.2
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

                // Clock Area (Date + Time)
                Item {
                    id: clockArea
                    width: clockRow.implicitWidth
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        id: clockRow
                        spacing: 15
                        anchors.verticalCenter: parent.verticalCenter

                        // Date
                        Text {
                            id: timeText
                            text: panel.capitalize((new Date()).toLocaleString(Qt.locale("it_IT"), "dddd dd/MM/yy"))
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
                                text: (new Date()).toLocaleString(Qt.locale("it_IT"), "HH:mm:ss")
                                color: Colors.text
                                font.pixelSize: 16
                                font.family: globals.fontFamily
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("Clock clicked, spawning calendar terminal");
                            calProcess.running = true;
                        }
                        hoverEnabled: true
                        onEntered: clockArea.opacity = 0.8
                        onExited: clockArea.opacity = 1.0
                    }
                }
            }
        }
    }
}
