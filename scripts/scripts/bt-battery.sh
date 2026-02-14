/home/marco
marco@arch> bluetoothctl info E8:EE:CC:2F:22:F4 | grep Battery | awk '{print $4}' | tr -d '()'
50

/home/marco
marco@arch> bluetoothctl devices
Device F4:2B:7D:47:92:45 SoundCore 2
Device E8:EE:CC:2F:22:F4 Soundcore Space Q45
Device FC:41:16:E7:CE:8C Pixel 8a Bulga