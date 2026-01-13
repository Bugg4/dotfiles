#!/usr/bin/env python3
import json
import psutil
import time
import sys
import subprocess
import os

# --- Configuration ---
MENU_COMMAND = "fuzzel -d"
TEMP_FILE = "/tmp/waybar_network_selected_interface.tmp"
# ---------------------


def format_speed(speed_bytes):
    """Formats speed in bytes to a ###.# B/s format, padded with leading spaces."""
    if speed_bytes >= 1024 * 1024:
        speed = f"{speed_bytes / (1024*1024):5.1f} MB/s"
    elif speed_bytes >= 1024:
        speed = f"{speed_bytes / 1024:5.1f} KB/s"
    else:
        speed = f"{speed_bytes:5.1f}  B/s"
    return speed


def get_interface_description(interface):
    """Gets a human-readable description for a network interface."""
    sys_path = f"/sys/class/net/{interface}"
    
    # Check if it's a Wi-Fi device (most reliable check)
    if os.path.exists(f"{sys_path}/wireless"):
        return "Wi-Fi"
        
    # Check the device's underlying bus (PCI, USB, etc.)
    try:
        device_path = os.path.realpath(f"{sys_path}/device")
        if "/pci" in device_path:
            return "Wired Ethernet"
        if "/usb" in device_path:
            # This covers USB tethering, USB Wi-Fi/Ethernet adapters
            return "USB Connection"
    except FileNotFoundError:
        # Virtual devices (like VPNs, bridges) don't have a 'device' link
        pass
        
    # Fallback for virtual devices or other types
    if interface.startswith("tun") or interface.startswith("tap"):
        return "VPN/Virtual"
    if interface.startswith("veth") or interface.startswith("br"):
        return "Virtual/Bridge"
        
    return "Unknown"


def get_network_interfaces():
    """Returns a list of all non-loopback network interface names."""
    return [iface for iface in psutil.net_if_addrs().keys() if iface != "lo"]


def select_interface():
    """Shows a menu with descriptive names to select an interface."""
    interfaces = get_network_interfaces()
    if not interfaces:
        return

    # Create a list of descriptive entries for the menu
    menu_entries = []
    for iface in interfaces:
        desc = get_interface_description(iface)
        menu_entries.append(f"{iface:<15} ({desc})")

    menu_input = "\n".join(menu_entries).encode('utf-8')

    try:
        process = subprocess.run(
            MENU_COMMAND.split(),
            input=menu_input,
            capture_output=True,
            check=True
        )
        selected_entry = process.stdout.decode('utf-8').strip()

        # Parse the selected entry to get just the interface name
        # e.g., "wlan0           (Wi-Fi)" -> "wlan0"
        if selected_entry:
            selected_iface = selected_entry.split()[0]
            if selected_iface in interfaces:
                with open(TEMP_FILE, "w") as f:
                    f.write(selected_iface)
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass


def find_best_interface():
    """Finds the primary active network interface (the fallback method)."""
    stats = psutil.net_if_stats()
    for prefix in ["en", "eth", "wl", "wlan"]:
        for name, data in stats.items():
            if name.startswith(prefix) and data.isup:
                return name
    for name, data in stats.items():
        if data.isup and name != "lo":
            return name
    return None


def get_target_interface():
    """Determines which interface to monitor, prioritizing user's choice."""
    if os.path.exists(TEMP_FILE):
        with open(TEMP_FILE, "r") as f:
            interface = f.read().strip()
        stats = psutil.net_if_stats()
        if interface in stats and stats[interface].isup:
            return interface
        else:
            os.remove(TEMP_FILE)
    return find_best_interface()


def main():
    """Main function: handles either interface selection or network monitoring."""
    if len(sys.argv) > 1 and sys.argv[1] == '--select':
        select_interface()
        sys.exit(0)

    target_interface = None
    last_io = None

    while True:
        try:
            current_target = get_target_interface()

            if not current_target:
                output = {"text": "󰌙 Disconnected", "tooltip": "No active network interface"}
                print(json.dumps(output), flush=True)
                time.sleep(2)
                continue

            if current_target != target_interface:
                target_interface = current_target
                all_io = psutil.net_io_counters(pernic=True)
                if target_interface in all_io:
                    last_io = all_io[target_interface]
                else:
                    target_interface = None
                    continue
                time.sleep(1)

            all_io = psutil.net_io_counters(pernic=True)

            if target_interface not in all_io:
                 output = {"text": "󰌙 Disconnected", "tooltip": f"Interface '{target_interface}' lost"}
                 print(json.dumps(output), flush=True)
                 target_interface = None
                 time.sleep(2)
                 continue

            current_io = all_io[target_interface]
            bytes_sent = current_io.bytes_sent - last_io.bytes_sent
            bytes_recv = current_io.bytes_recv - last_io.bytes_recv
            upload_speed = format_speed(bytes_sent)
            download_speed = format_speed(bytes_recv)
            
            output = {
                "text": f" {download_speed}  {upload_speed}",
                "tooltip": f"Monitoring: {target_interface} ({get_interface_description(target_interface)})"
            }
            print(json.dumps(output), flush=True)

            last_io = current_io
            time.sleep(1)

        except (KeyboardInterrupt, SystemExit):
            break
        except Exception as e:
            error_output = {"text": "⚠ Error", "tooltip": str(e)}
            print(json.dumps(error_output), flush=True)
            time.sleep(1)

if __name__ == "__main__":
    main()