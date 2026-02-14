#!/bin/bash
# Resize JPG images to a 1.26:1 aspect ratio
# Upscales only (never downscales), appends "_AR" to the filename.
# Usage:
#   ./resize.sh /path/to/folder
#   ./resize.sh image1.jpg image2.JPG ...

set -euo pipefail

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <folder> | <file1> [file2 ...]"
    exit 1
fi

# Collect image list
declare -a images=()

if [[ $# -eq 1 && -d "$1" ]]; then
    shopt -s nullglob
    images=("$1"/*.jpg "$1"/*.JPG)
    shopt -u nullglob
else
    for arg in "$@"; do
        if [[ -f "$arg" && "$arg" =~ \.(jpg|JPG)$ ]]; then
            images+=("$arg")
        else
            echo "Skipping: $arg (not a JPG file)"
        fi
    done
fi

if [[ ${#images[@]} -eq 0 ]]; then
    echo "No JPG images found."
    exit 0
fi

for img in "${images[@]}"; do
    dir=$(dirname "$img")
    base=$(basename "$img")
    base="${base%.*}"
    out="${dir}/${base}_AR.jpg"

    echo "Processing: $img → $out"

    ffmpeg -hide_banner -loglevel error -i "$img" \
        -vf "scale='iw*max(1,(1.26)/(iw/ih))':'ih*max(1,(iw/ih)/(1.26))',crop='ih*1.26:ih'" \
        -q:v 1 \
        -y "$out"
done

echo "Done."
