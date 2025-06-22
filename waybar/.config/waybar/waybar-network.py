#!/usr/bin/env python3
import json
import psutil
import time
import sys


def format_speed(speed_bytes):
    """Formats speed in bytes to a ###.# B/s format, padded with leading zeros."""
    if speed_bytes >= 1024 * 1024:

        speed = f"{speed_bytes / (1024*1024):5.1f} MB/s"
    elif speed_bytes >= 1024:
        # Kilobytes per second
        speed = f"{speed_bytes / 1024:5.1f} KB/s"
    else:
        # Bytes per second
        speed = f"{speed_bytes:5.1f} B/s"
    return speed


def get_active_interface():
    """Finds the primary active network interface."""
    stats = psutil.net_if_stats()
    for iface in ["en", "eth", "wlan", "wlp", "wifi"]:
        for name, data in stats.items():
            if name.startswith(iface) and data.isup:
                return name
    for name, data in stats.items():
        if data.isup and name != "lo":
            return name
    return None


def main():
    """
    Calculates network speed and prints it as a JSON object for Waybar.
    """

    try:
        last_io = psutil.net_io_counters()
    except Exception as e:
        print(
            json.dumps(
                {"text": "⚠ Error", "tooltip": f"Initial psutil call failed: {e}"}
            ),
            flush=True,
        )
        sys.exit(1)

    time.sleep(1)  # Wait a second for the first measurement

    while True:
        try:
            # Get new counter values
            current_io = psutil.net_io_counters()

            # Calculate the difference in bytes
            bytes_sent = current_io.bytes_sent - last_io.bytes_sent
            bytes_recv = current_io.bytes_recv - last_io.bytes_recv

            # Format the speeds
            upload_speed = format_speed(bytes_sent)
            download_speed = format_speed(bytes_recv)

            # Get active interface information
            interface = get_active_interface()
            if not interface:
                output_data = {
                    "text": "⚠ Disconnected",
                    "tooltip": "No active network interface",
                }
            else:
                # Prepare the output text with icons
                text = f" {download_speed}  {upload_speed}"
                tooltip = f"Interface: {interface}"
                output_data = {"text": text, "tooltip": tooltip}

            # Print JSON for Waybar
            print(json.dumps(output_data), flush=True)

            # Update last values and wait for the next interval
            last_io = current_io
            time.sleep(1)

        except (KeyboardInterrupt, SystemExit):
            break
        except Exception as e:
            # Log errors without crashing the script
            print(json.dumps({"text": "⚠ Error", "tooltip": str(e)}), flush=True)
            time.sleep(1)


if __name__ == "__main__":
    main()
