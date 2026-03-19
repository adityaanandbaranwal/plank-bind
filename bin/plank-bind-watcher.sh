#!/bin/bash

set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
CONFIG_FILE="$XDG_CONFIG_HOME/plank-bind.conf"

LOG_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/plank-bind.log"
mkdir -p "$(dirname "$LOG_FILE")"
exec >> "$LOG_FILE" 2>&1

# Load config if exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

PLANK_DIR="${PLANK_DIR:-$XDG_CONFIG_HOME/plank/dock1/launchers}"

# fetches script directory absolute path and update-plank-keybindings script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_SCRIPT="$SCRIPT_DIR/update-plank-keybindings.sh"

echo "Watching Plank dock for changes..."

while true; do
    inotifywait -qq -e create -e delete -e modify -e moved_to -e moved_from "$PLANK_DIR" || {
        echo "inotify failed, retrying..."
        sleep 2
        continue
    }
    
    sleep 1  # debounce
    echo "Dock changed. Updating..."
    
    bash "$UPDATE_SCRIPT" || echo "Update script failed"
done