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
    except (subprocess.CalledProcessError, FileNotFoundError):
        return

    # Parse the selected entry to get just the interface name
    # e.g., "wlan0           (Wi-Fi)" -> "wlan0"
    if selected_entry:
        selected_iface = selected_entry.split()[0]
        if selected_iface in interfaces:
            # Check if it's a Wi-Fi interface
            if is_wifi(selected_iface):
                ssid = select_wifi_network(selected_iface)
                if ssid:
                    if connect_to_wifi(selected_iface, ssid):
                        disconnect_other_interfaces(selected_iface)
            else:
                # Wired connection
                try:
                    subprocess.run(
                        ["nmcli", "device", "connect", selected_iface],
                        check=True,  # Check for success
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL
                    )
                    disconnect_other_interfaces(selected_iface)
                except Exception:
                    pass

            with open(TEMP_FILE, "w") as f:
                f.write(selected_iface)

def disconnect_other_interfaces(keep_interface):
    """Disconnects all other network interfaces to ensure traffic routing."""
    interfaces = get_network_interfaces()
    for iface in interfaces:
        if iface != keep_interface and iface != "lo":
            try:
                subprocess.run(
                    ["nmcli", "device", "disconnect", iface],
                    check=False,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL
                )
            except Exception:
                pass

def is_wifi(interface):
    return os.path.exists(f"/sys/class/net/{interface}/wireless")

def get_wifi_networks(interface):
    """Returns a list of unique (SSID, BARS, SECURITY) tuples."""
    try:
        # Rescan first
        subprocess.run(["nmcli", "device", "wifi", "rescan", "ifname", interface], 
                       check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        
        result = subprocess.run(
            ["nmcli", "-t", "-f", "SSID,BARS,SECURITY", "device", "wifi", "list", "ifname", interface],
            capture_output=True,
            text=True,
            check=True
        )
        networks = []
        seen_ssids = set()
        for line in result.stdout.splitlines():
            # Handle escaped colons if necessary, but simple split usually works for standard SSIDs
            parts = line.split(":")
            if len(parts) >= 3:
                ssid = parts[0].replace(r"\:", ":")
                bars = parts[1]
                security = parts[2]
                if ssid and ssid not in seen_ssids:
                    networks.append((ssid, bars, security))
                    seen_ssids.add(ssid)
        return networks
    except Exception:
        return []

def select_wifi_network(interface):
    """Shows a menu of Wi-Fi networks and returns the selected SSID."""
    networks = get_wifi_networks(interface)
    if not networks:
        return None
        
    menu_entries = []
    for ssid, bars, security in networks:
        # Format: "SSID             ▂▄▆█ WPA2"
        menu_entries.append(f"{ssid:<25} {bars} {security}")
        
    menu_input = "\n".join(menu_entries).encode('utf-8')
    
    try:
        process = subprocess.run(
            MENU_COMMAND.split(),
            input=menu_input,
            capture_output=True,
            check=True
        )
        selected_entry = process.stdout.decode('utf-8').strip()
        if selected_entry:
            # Extract SSID (everything before the signal bars)
            # Find the signal bars by splitting? 
            # Or just take the first part? SSID can have spaces.
            # We know format is fixed width somewhat or assume delimiter.
            # Let's match against the list we generated.
            for ssid, bars, security in networks:
                # Reconstruct the entry string to match exactly
                entry_str = f"{ssid:<25} {bars} {security}"
                if selected_entry == entry_str.strip(): # fuzzel might strip?
                    return ssid
                if selected_entry == entry_str:
                    return ssid
            
            # Fallback parsing if exact match fails (e.g. fuzzel stripping)
            # Attempt to split by signal bars?
            # Or just return the part before the first large gap?
            # Let's try to match by finding the suffix
            for ssid, bars, security in networks:
                suffix = f" {bars} {security}"
                if selected_entry.endswith(suffix):
                     # Be careful about potential overlapping suffixes
                     return ssid
            
            # Simple fallback: split by multiple spaces?
            return selected_entry.split("  ")[0].strip()
            
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None
    return None

def prompt_for_password(ssid):
    """Prompts the user for a password using fuzzel."""
    try:
        # Check if fuzzel is the menu command to add --password
        cmd = MENU_COMMAND.split()
        if "fuzzel" in cmd[0]:
            cmd.extend(["-p", f"Password for {ssid}: ", "--password"])
        else:
             pass 
             
        # Pipe empty input to just show prompt
        process = subprocess.run(
            cmd,
            input=b"",
            capture_output=True,
            check=True
        )
        password = process.stdout.decode('utf-8').strip()
        return password
    except Exception:
        return None

def connect_to_wifi(interface, ssid):
    """Attempts to connect to a Wi-Fi network, prompting for password if needed."""
    # First try connecting without password (saved profile or open network)
    try:
        subprocess.run(
            ["nmcli", "device", "wifi", "connect", ssid, "ifname", interface],
            capture_output=True,
            check=True
        )
        return True
    except subprocess.CalledProcessError:
        # Connection failed, possibly due to missing password
        
        password = prompt_for_password(ssid)
        if password:
            try:
                # Delete existing connection profile to ensure clean slate
                subprocess.run(
                    ["nmcli", "connection", "delete", ssid],
                    check=False,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL
                )

                # Rescan before retry
                subprocess.run(
                    ["nmcli", "device", "wifi", "rescan", "ifname", interface],
                    check=False,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL
                )
                time.sleep(2) # Give it a moment to populate

                subprocess.run(
                    ["nmcli", "device", "wifi", "connect", ssid, "password", password, "ifname", interface],
                    capture_output=True,
                    check=True
                )
                return True
            except subprocess.CalledProcessError:
                pass 
    return False


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


def get_active_ssid(interface):
    """Returns the SSID of the connected Wi-Fi network or None."""
    try:
        result = subprocess.run(
            ["nmcli", "-t", "-f", "ACTIVE,SSID", "dev", "wifi", "list", "ifname", interface],
            capture_output=True,
            text=True,
            check=True
        )
        for line in result.stdout.splitlines():
            if line.startswith("yes:"):
                return line.split(":", 1)[1]
    except Exception:
        pass
    return None

def get_active_connection_name(interface):
    """Returns the active connection name for the interface (e.g. 'Wired connection 1')."""
    try:
        # Get active connections: NAME,DEVICE
        # We look for the line where DEVICE matches our interface
        result = subprocess.run(
            ["nmcli", "-t", "-f", "NAME,DEVICE,TYPE", "connection", "show", "--active"],
            capture_output=True,
            text=True,
            check=True
        )
        for line in result.stdout.splitlines():
            # Format: NAME:DEVICE:TYPE
            parts = line.split(":")
            if len(parts) >= 2:
                name = parts[0].replace(r"\:", ":")
                device = parts[1]
                if device == interface:
                    return name
    except Exception:
        pass
    return None


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
                output = {"text": "󰌙 Disconnected", "tooltip": "No active network interface", "class": "disconnected"}
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
                 output = {"text": "󰌙 Disconnected", "tooltip": f"Interface '{target_interface}' lost", "class": "disconnected"}
                 print(json.dumps(output), flush=True)
                 target_interface = None
                 time.sleep(2)
                 continue

            current_io = all_io[target_interface]
            bytes_sent = current_io.bytes_sent - last_io.bytes_sent
            bytes_recv = current_io.bytes_recv - last_io.bytes_recv
            upload_speed = format_speed(bytes_sent)
            download_speed = format_speed(bytes_recv)
            
            description = get_interface_description(target_interface)
            tooltip = f"Monitoring: {target_interface} ({description})"
            
            icon = "" # Default Plug icon
            css_class = "ethernet"
            
            if is_wifi(target_interface):
                icon = "" # Wi-Fi icon
                css_class = "wifi"
                ssid = get_active_ssid(target_interface)
                if ssid:
                    tooltip += f"\nSSID: {ssid}"
            else:
                # Wired or other: show active connection name
                conn_name = get_active_connection_name(target_interface)
                if conn_name:
                    tooltip += f"\nConnected to: {conn_name}"
            
            output = {
                "text": f" {download_speed}  {upload_speed}",
                "tooltip": tooltip,
                "class": css_class,
                "alt": icon
            }
            print(json.dumps(output), flush=True)

            last_io = current_io
            time.sleep(1)

        except (KeyboardInterrupt, SystemExit):
            break
        except Exception as e:
            error_output = {"text": "⚠ Error", "tooltip": str(e), "class": "error"}
            print(json.dumps(error_output), flush=True)
            time.sleep(1)

if __name__ == "__main__":
    main()