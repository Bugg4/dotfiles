#!/usr/bin/env python3

import json
import subprocess
import os
import sys
import shutil
from concurrent.futures import ThreadPoolExecutor

# Configuration
CACHE_DIR = "/tmp/rofi-window-thumbs"

def get_hyprland_data():
    try:
        monitors = json.loads(subprocess.check_output(["hyprctl", "monitors", "-j"]))
        clients = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"]))
        return monitors, clients
    except Exception as e:
        sys.stderr.write(f"Error getting Hyprland data: {e}\n")
        sys.exit(1)

def take_screenshot(client, active_workspace_ids):
    address = client["address"]
    workspace_id = client["workspace"]["id"]
    
    # Only screenshot if on an active workspace
    if workspace_id not in active_workspace_ids:
        return client, None

    # Construct geometry: X,Y WxH
    at = client["at"]
    size = client["size"]
    # Adjust for potential negative coordinates or off-screen (though active workspace implies visible)
    # Grim expects specific format.
    # Note: hyprctl returns [x, y] and [w, h]
    geometry = f"{at[0]},{at[1]} {size[0]}x{size[1]}"
    
    filename = os.path.join(CACHE_DIR, f"{address}.png")
    
    try:
        # grim -g "GEOM" -l 0 output.png
        # -l 0 for no compression (fastest)
        subprocess.run(["grim", "-g", geometry, "-l", "0", filename], 
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return client, filename
    except subprocess.CalledProcessError:
        return client, None

def main():
    # If arguments are provided, it means a selection was made
    if len(sys.argv) > 1:
        selected = sys.argv[1]
        # The selection format is usually "Title\0..." or just the string passed.
        # But for script mode, the *value* passed is the line.
        # Rofi passes the *info* field if set?
        # If we use -format 'i s', we get info?
        # Actually rofi script mode implies:
        # 1. No args: List options.
        # 2. Arg provided: entry selected.
        
        # We need to extract the address. We can store address in specific hidden field or just parse.
        # But simpler: use the ROFI_INFO environment variable or just the last arguments if using -dmenu loop?
        # Wait, if used as a mode: `rofi -modi "window:script.py" -show window`
        # When user selects, the script is called with the selection as argument.
        # I can try to embed the address in the string or use the `\0info\x1f` feature.
        # Rofi passes the `info` data to the script as the argument `ROFI_INFO` env var is not standard for script mode execution, 
        # but the argument passed *is* the info if valid?
        # Actually, for script mode, the argument is the *text* of the selected row.
        # Unless we use `\0info\x1f<data>`, then `<data>` is what is passed?
        # Let's verify: `man rofi-script`.
        # "If the entry has the info field set, this value is passed to the script."
        # So yes, I can pass address in info.
        
        address = os.environ.get("ROFI_INFO")
        if not address:
            # Fallback if environment variable not set (older rofi versions)
            # Try to parse or just assume arg is address if I formatted it so?
            # But "ROFI_INFO" is the standard way.
            # If explicit arg is passed, it might be the text.
            # I will assume ROFI_INFO is populated.
            if sys.argv[1]:
                # Debug or fallback
                pass
            return

        # Activate window
        subprocess.run(["hyprctl", "dispatch", "focuswindow", f"address:{address}"])
        sys.exit(0)

    # Ensure cache dir exists
    if os.path.exists(CACHE_DIR):
        # Optional: clean up old files? Or just overwrite.
        # Overwrite is faster than checking.
        pass
    else:
        os.makedirs(CACHE_DIR)

    monitors, clients = get_hyprland_data()
    
    # Identify active workspaces
    active_workspace_ids = set()
    for m in monitors:
        if m["activeWorkspace"]:
            active_workspace_ids.add(m["activeWorkspace"]["id"])

    # Prepare for parallel execution
    # Filter clients to reasonable ones (mapped?)
    valid_clients = [c for c in clients if c["mapped"] and c["pid"] > 0]
    
    
    # We want to output lines for rofi immediately or batch?
    # Parallel is best.
    
    results = []
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = {executor.submit(take_screenshot, c, active_workspace_ids): c for c in valid_clients}
        for future in futures:
            client, icon_path = future.result()
            
            # Format: 'Title'
            # Icon: 'icon_path' or default app icon
            # Info: 'address'
            
            title = client["title"]
            clazz = client["class"]
            address = client["address"]
            
            # Escape Pango markup in title/class if necessary
            # Simple sanitization
            title = title.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
            clazz = clazz.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
            
            display_str = f"{title} <span color='#666' size='small'>({clazz})</span>"
            
            icon_part = ""
            if icon_path:
                icon_part = f"\0icon\x1f{icon_path}"
            else:
                # Fallback to class name effectively (rofi looks up icon by name)
                # Client class often works as icon name
                icon_part = f"\0icon\x1f{client['class']}"

            info_part = f"\x1finfo\x1f{address}"
            
            line = f"{display_str}{icon_part}{info_part}"
            results.append(line)

    # Print all results
    for line in results:
        print(line)

if __name__ == "__main__":
    main()
