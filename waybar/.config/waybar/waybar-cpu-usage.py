#!/usr/bin/env python3
import json
import subprocess
import sys
import os

def get_cpu_model():
    try:
        with open('/proc/cpuinfo', 'r') as f:
            for line in f:
                if "model name" in line:
                    return line.split(':')[1].strip()
    except:
        return "Unknown CPU"
    return "Unknown CPU"

def get_cpu_temp():
    try:
        # Try k10temp (AMD) Tctl first
        sensors = subprocess.check_output(['sensors'], text=True)
        
        # Look for Tccd1 or Tccd2 (Actual Die Temp) first, then Tctl
        lines = sensors.splitlines()
        
        # Priority list of labels to look for
        priorities = ["Tccd1:", "Tccd2:", "Tdie:", "Tctl:"]
        
        for label in priorities:
            for line in lines:
                if label in line:
                     parts = line.split()
                     for part in parts:
                         if part.startswith('+') and part.endswith('°C'):
                             return part.replace('+', '').replace('°C', '')
        
        # Fallback to any temp1
        for line in lines:
             if "temp1:" in line:
                 parts = line.split()
                 for part in parts:
                     if part.startswith('+') and part.endswith('°C'):
                         return part.replace('+', '').replace('°C', '')

    except Exception:
        return "N/A"
    return "N/A"

def get_cpu_usage_and_cores():
    usage_data = {}
    try:
        # Get usage for all cores
        # mpstat -P ALL 1 1
        # The output might be localized (commas instead of dots)
        
        # Run mpstat for 1 second interval, 1 count to get current usage
        result = subprocess.run(['mpstat', '-P', 'ALL', '1', '1'], capture_output=True, text=True)
        lines = result.stdout.strip().splitlines()
        
        # We need to find the "Average:" block or the second report block
        # The first block is since boot, second is the 1-second interval
        
        relevant_lines = []
        capture = False
        
        # Check if "Average:" exists
        has_average = any("Average:" in line for line in lines)
        
        if has_average:
            for line in lines:
                if "Average:" in line and "CPU" in line:
                    capture = True
                    continue # Skip header
                if capture and line.strip():
                     relevant_lines.append(line)
        else:
             # If no Average (some versions?), use the last set of CPU lines
             # Find the last "CPU" header index
             last_header_idx = -1
             for i, line in enumerate(lines):
                  if "CPU" in line and "%idle" in line:
                      last_header_idx = i
             
             if last_header_idx != -1:
                 for line in lines[last_header_idx+1:]:
                      if line.strip():
                          relevant_lines.append(line)

        formatted_usage = {}
        
        for line in relevant_lines:
            parts = line.split()
            # Average:     all    ...
            # Average:       0    ...
            
            # Find the CPU identifier column. It's usually the column after AM/PM or Average:
            # But simpler: if line has 'all', it's total. If it has a number, it's a core.
            
            cpu_id = None
            idle_val = None
            
            # Identify CPU column index dynamically
            # It is the column that contains 'all' or digits
            
            # Standard `mpstat 1 1` line:
            # 06:08:47 PM  CPU    %usr   ...   %idle
            # 06:08:48 PM  all    0.50   ...   99.50
            # Average:     all    0.50   ...   99.50

            idx_cpu = -1
            for k, part in enumerate(parts):
                 if part == "all" or part.isdigit():
                      idx_cpu = k
                      break
            
            if idx_cpu == -1: continue
            
            cpu_name = parts[idx_cpu]
            
            # %idle is the last column
            idle_str = parts[-1].replace(',', '.')
            
            try:
                idle = float(idle_str)
                usage = 100.0 - idle
                formatted_usage[cpu_name] = usage
            except ValueError:
                continue
                
        return formatted_usage

    except Exception as e:
        return {}

def main():
    model = get_cpu_model()
    usage_data = get_cpu_usage_and_cores()
    temp = get_cpu_temp()
    
    total_usage = usage_data.get('all', 0.0)
    
    # Format Tooltip
    tooltip = f"CPU Model: {model}\n"
    tooltip += f"Temperature: {temp}°C\n"
    tooltip += "----------------\n"
    
    # Sort cores numerically
    cores = []
    for k in usage_data.keys():
        if k.isdigit():
            cores.append(int(k))
    cores.sort()
    
    for core in cores:
        usg = usage_data.get(str(core), 0.0)
        # Bar graph for tooltip?
        # usg_bar = "█" * int(usg / 10) + "░" * (10 - int(usg / 10))
        tooltip += f"Core {core:<2}: {usg:5.1f}%\n"
        
    css_class = "normal"
    try:
        t_val = float(temp)
        if t_val > 80:
            css_class = "critical"
        elif t_val > 60:
            css_class = "warning"
    except:
        pass
    
    # Remove trailing newline from tooltip
    tooltip = tooltip.strip()

    try:
        temp_val = float(temp)
        temp_str = f"{temp_val:.0f}"
    except:
        temp_str = temp

    output = {
        "text": f"{total_usage:02.0f}% {temp_str}°C",
        "tooltip": tooltip,
        "class": css_class
    }
    
    print(json.dumps(output))

if __name__ == "__main__":
    main()
