#!/bin/bash

while true; do
# Initialize variables
gpu_usage="N/A"
gpu_temp="N/A"
tool_tip="GPU"
class="normal"

# Check for NVIDIA (nvidia-smi)
if command -v nvidia-smi &> /dev/null; then
    info=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits)
    raw_usage=$(echo "$info" | awk -F', ' '{print $1}')
    raw_temp=$(echo "$info" | awk -F', ' '{print $2}')
    
    # Pad usage with zero if less than 10 (e.g., 5 -> 05)
    gpu_usage=$(printf "%02d" "$raw_usage")
    gpu_temp="$raw_temp"
    tool_tip="NVIDIA GPU"

# Check for AMD (sysfs)
elif [ -d "/sys/class/drm/card0/device" ]; then
    # Attempt to read usage
    if [ -f "/sys/class/drm/card0/device/gpu_busy_percent" ]; then
        raw_usage=$(cat /sys/class/drm/card0/device/gpu_busy_percent)
        # Format: Pad with zero
        gpu_usage=$(printf "%02d" "$raw_usage")
    fi

    # Attempt to read temperature
    temp_path=$(find /sys/class/drm/card0/device/hwmon/hwmon*/temp1_input 2>/dev/null | head -n1)
    if [ -n "$temp_path" ]; then
        raw_temp=$(cat "$temp_path")
        gpu_temp=$((raw_temp / 1000))
    fi
    tool_tip="AMD GPU"
fi

# Define critical class based on temperature
if [ "$gpu_temp" != "N/A" ] && [ "$gpu_temp" -gt 80 ]; then
    class="critical"
fi

# Output in JSON format
printf '{"text": "%s%% %s°C", "tooltip": "%s", "class": "%s"}\n' "$gpu_usage" "$gpu_temp" "$tool_tip" "$class"

sleep 1
done