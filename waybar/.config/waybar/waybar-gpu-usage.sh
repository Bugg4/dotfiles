#!/bin/bash

# Initialize variables
gpu_usage="N/A"
gpu_temp="N/A"
tool_tip="GPU"
class="normal"

# Check for NVIDIA (nvidia-smi)
if command -v nvidia-smi &> /dev/null; then
    # query usage and temperature
    info=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits)
    gpu_usage=$(echo "$info" | awk -F', ' '{print $1}')
    gpu_temp=$(echo "$info" | awk -F', ' '{print $2}')
    tool_tip="NVIDIA GPU"

# Check for AMD (sysfs)
elif [ -d "/sys/class/drm/card0/device" ]; then
    # Attempt to read usage (gpu_busy_percent is common for modern AMD drivers)
    if [ -f "/sys/class/drm/card0/device/gpu_busy_percent" ]; then
        gpu_usage=$(cat /sys/class/drm/card0/device/gpu_busy_percent)
    fi

    # Attempt to read temperature (requires finding the correct hwmon)
    # This finds the first hwmon with a temp1_input file inside the GPU device directory
    temp_path=$(find /sys/class/drm/card0/device/hwmon/hwmon*/temp1_input 2>/dev/null | head -n1)
    
    if [ -n "$temp_path" ]; then
        raw_temp=$(cat "$temp_path")
        # Divide by 1000 to get degrees Celsius
        gpu_temp=$((raw_temp / 1000))
    fi
    tool_tip="AMD GPU"
fi

# Define icons or critical classes based on temperature
if [ "$gpu_temp" != "N/A" ] && [ "$gpu_temp" -gt 80 ]; then
    class="critical"
fi

# Output in JSON format for Waybar
# printf creates a formatted JSON string
printf '{"text": "%s%% %s°C", "tooltip": "%s", "class": "%s"}\n' "$gpu_usage" "$gpu_temp" "$tool_tip" "$class"