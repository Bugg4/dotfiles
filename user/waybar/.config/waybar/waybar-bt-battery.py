#!/usr/bin/env python3
import json
import time
import sys
import subprocess
import os
import re

# --- Configuration ---
MENU_COMMAND = "fuzzel -d"
TEMP_FILE = "/tmp/waybar_bluetooth_selected_device.tmp"
# ---------------------


def get_bluetooth_devices():
    """
    Returns a list of tuples (mac, name) for all paired devices.
    Parses 'bluetoothctl devices' output.
    """
    try:
        result = subprocess.run(
            ["bluetoothctl", "devices"], capture_output=True, text=True, check=True
        )
        devices = []
        # Output format: Device <MAC> <Name...>
        for line in result.stdout.strip().split("\n"):
            parts = line.split(maxsplit=2)
            if len(parts) >= 3 and parts[0] == "Device":
                mac = parts[1]
                name = parts[2]
                devices.append((mac, name))
        return devices
    except (subprocess.CalledProcessError, FileNotFoundError):
        return []


def select_device():
    """
    Shows a menu to select a bluetooth device using MENU_COMMAND.
    Saves the selected MAC to TEMP_FILE.
    """
    devices = get_bluetooth_devices()
    if not devices:
        return

    # Create menu entries in format: "Name (MAC)"
    menu_entries = []
    for mac, name in devices:
        menu_entries.append(f"{name} ({mac})")

    menu_input = "\n".join(menu_entries).encode("utf-8")

    try:
        process = subprocess.run(
            MENU_COMMAND.split(), input=menu_input, capture_output=True, check=True
        )
        selected_entry = process.stdout.decode("utf-8").strip()

        # Parse "Name (MAC)" to extract just the MAC address
        # We assume the format ends with (MAC). We use rsplit to handle names with parens.
        if selected_entry and "(" in selected_entry:
            mac = selected_entry.rsplit("(", 1)[1].strip(")")

            # Basic validation to ensure we grabbed a MAC
            if len(mac.split(":")) == 6:
                with open(TEMP_FILE, "w") as f:
                    f.write(mac)

    except (subprocess.CalledProcessError, FileNotFoundError):
        pass


def get_target_device_mac():
    """Reads the selected MAC address from temp file."""
    if os.path.exists(TEMP_FILE):
        with open(TEMP_FILE, "r") as f:
            return f.read().strip()
    return None


def get_device_info(mac):
    """
    Gets alias and battery percentage for the MAC using bluetoothctl info.
    Returns (alias, battery_percent_int, is_connected_bool)
    """
    try:
        result = subprocess.run(
            ["bluetoothctl", "info", mac], capture_output=True, text=True, check=True
        )
        output = result.stdout

        # Check connection status
        connected = "Connected: yes" in output

        # Get Alias (preferred over Name for display)
        alias_match = re.search(r"Alias:\s*(.*)", output)
        alias = alias_match.group(1) if alias_match else mac

        # Get Battery Percentage
        # Matches: "Battery Percentage: 0x64 (100)" -> Captures "100"
        battery = None
        batt_match = re.search(r"Battery Percentage:.*\((.*)\)", output)
        if batt_match:
            try:
                battery = int(batt_match.group(1))
            except ValueError:
                pass

        return alias, battery, connected
    except subprocess.CalledProcessError:
        return None, None, False


def get_battery_icon(percent):
    """Returns a battery icon based on percentage."""
    if percent is None:
        return ""
    if percent >= 90:
        return ""
    if percent >= 60:
        return ""
    if percent >= 40:
        return ""
    if percent >= 10:
        return ""
    return ""


def main():
    # Handle interface selection argument
    if len(sys.argv) > 1 and sys.argv[1] == "--select":
        select_device()
        sys.exit(0)

    # Main monitoring loop
    while True:
        try:
            target_mac = get_target_device_mac()

            if not target_mac:
                output = {
                    "text": " Select",
                    "tooltip": "No device selected. Click to choose a Bluetooth device.",
                }
                print(json.dumps(output), flush=True)
                time.sleep(3)
                continue

            alias, battery, connected = get_device_info(target_mac)

            if alias is None:
                # Command failed (bluetooth service likely down)
                output = {"text": "⚠ Error", "tooltip": "Could not query bluetoothctl"}
            elif not connected:
                output = {
                    "text": " Disconnected",
                    "class": "disconnected",
                    "tooltip": f"{alias}\nMAC: {target_mac}\nStatus: Disconnected",
                }
            elif battery is not None:
                icon = get_battery_icon(battery)
                output = {
                    "text": f"{icon} {battery}%",
                    "class": "connected",
                    "tooltip": f"{alias}\nMAC: {target_mac}\nBattery: {battery}%",
                }
            else:
                # Connected but device not reporting battery (yet)
                output = {
                    "text": f" {alias}",
                    "class": "connected",
                    "tooltip": f"{alias}\nMAC: {target_mac}\nNo battery data available",
                }

            print(json.dumps(output), flush=True)

            # Update every 3 seconds
            time.sleep(3)

        except (KeyboardInterrupt, SystemExit):
            break
        except Exception as e:
            error_output = {"text": "⚠ Error", "tooltip": str(e)}
            print(json.dumps(error_output), flush=True)
            time.sleep(3)


if __name__ == "__main__":
    main()
