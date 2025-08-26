#!/usr/bin/env python3
import json
import psutil
import time
import sys
import subprocess
import os

# --- Configuration ---
# Set the command for your preferred application launcher.
# 'wofi -d' is a good choice for Wayland (Sway, Hyprland).
# 'rofi -dmenu' is a common choice for X11.
MENU_COMMAND = "wofi -d"

# Temporary file to store the user's chosen interface.
# Using /tmp/ ensures it's cleared on reboot.
TEMP_FILE = "/tmp/waybar_network_selected_interface.tmp"
# ---------------------


def format_speed(speed_bytes):
    """Formats speed in bytes to a ###.# B/s format, padded with leading spaces."""
    if speed_bytes >= 1024 * 1024:
        # Megabytes per second
        speed = f"{speed_bytes / (1024*1024):5.1f} MB/s"
    elif speed_bytes >= 1024:
        # Kilobytes per second
        speed = f"{speed_bytes / 1024:5.1f} KB/s"
    else:
        # Bytes per second
        speed = f"{speed_bytes:5.1f}  B/s"
    return speed


def get_network_interfaces():
    """Returns a list of all non-loopback network interface names."""
    # We get all interfaces and filter out the 'lo' (loopback) device.
    return [iface for iface in psutil.net_if_addrs().keys() if iface != "lo"]


def select_interface():
    """Shows a menu to select an interface and saves the choice."""
    interfaces = get_network_interfaces()
    if not interfaces:
        return  # No interfaces to choose from

    # Format for the menu: one interface per line.
    menu_input = "\n".join(interfaces).encode("utf-8")

    try:
        # Run the menu command and pass the list of interfaces to it.
        process = subprocess.run(
            MENU_COMMAND.split(), input=menu_input, capture_output=True, check=True
        )
        selected = process.stdout.decode("utf-8").strip()

        # If the user made a valid selection, save it to the temp file.
        if selected in interfaces:
            with open(TEMP_FILE, "w") as f:
                f.write(selected)
    except (subprocess.CalledProcessError, FileNotFoundError):
        # This happens if the user cancels (e.g., presses Esc) or
        # if the MENU_COMMAND is not found. We can safely ignore it.
        pass


def find_best_interface():
    """Finds the primary active network interface (the fallback method)."""
    stats = psutil.net_if_stats()
    # Prioritize common wired and wireless prefixes.
    for prefix in ["en", "eth", "wl", "wlan"]:
        for name, data in stats.items():
            if name.startswith(prefix) and data.isup:
                return name
    # If no common ones are found, return the first one that is up and not loopback.
    for name, data in stats.items():
        if data.isup and name != "lo":
            return name
    return None


def get_target_interface():
    """Determines which interface to monitor, prioritizing user's choice."""
    # 1. Check if the user has previously selected an interface.
    if os.path.exists(TEMP_FILE):
        with open(TEMP_FILE, "r") as f:
            interface = f.read().strip()
        # 2. Validate that the selected interface still exists and is active.
        stats = psutil.net_if_stats()
        if interface in stats and stats[interface].isup:
            return interface
        else:
            # If it's not valid anymore, remove the temp file.
            os.remove(TEMP_FILE)

    # 3. If no valid selection exists, fall back to automatic detection.
    return find_best_interface()


def main():
    """
    Main function: handles either interface selection or network monitoring.
    """
    # If the script is run with '--select', show the menu and exit.
    if len(sys.argv) > 1 and sys.argv[1] == "--select":
        select_interface()
        sys.exit(0)

    # --- Main monitoring loop ---
    target_interface = None
    last_io = None

    while True:
        try:
            current_target = get_target_interface()

            if not current_target:
                output = {
                    "text": "󰌙 Disconnected",
                    "tooltip": "No active network interface",
                }
                print(json.dumps(output), flush=True)
                time.sleep(2)  # Check less frequently when disconnected
                continue

            # If the interface changes (e.g., user selects a new one or switches from WiFi to Ethernet)
            # or if this is the first run, we need to reset our baseline.
            if current_target != target_interface:
                target_interface = current_target
                all_io = psutil.net_io_counters(pernic=True)
                if target_interface in all_io:
                    last_io = all_io[target_interface]
                else:  # Interface disappeared between checks
                    target_interface = None
                    continue
                time.sleep(
                    1
                )  # Wait a second before the first measurement on the new interface

            all_io = psutil.net_io_counters(pernic=True)

            # Handle case where the monitored interface suddenly disappears
            if target_interface not in all_io:
                output = {
                    "text": "󰌙 Disconnected",
                    "tooltip": f"Interface '{target_interface}' lost",
                }
                print(json.dumps(output), flush=True)
                target_interface = None  # Force re-detection next loop
                time.sleep(2)
                continue

            current_io = all_io[target_interface]

            # Calculate the difference in bytes over 1 second
            bytes_sent = current_io.bytes_sent - last_io.bytes_sent
            bytes_recv = current_io.bytes_recv - last_io.bytes_recv

            # Format speeds and create the output for Waybar
            upload_speed = format_speed(bytes_sent)
            download_speed = format_speed(bytes_recv)

            output = {
                "text": f" {download_speed}  {upload_speed}",
                "tooltip": f"Monitoring: {target_interface}",
            }
            print(json.dumps(output), flush=True)

            # Update state for the next iteration
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
