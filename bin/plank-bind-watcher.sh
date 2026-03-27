#!/bin/bash

set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

CONFIG_FILE="$XDG_CONFIG_HOME/plank-bind.conf"
LOG_FILE="$XDG_CACHE_HOME/plank-bind.log"

mkdir -p "$(dirname "$LOG_FILE")"
exec >> "$LOG_FILE" 2>&1

echo "---- Watcher started at $(date) ----"

# Load config
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Detect Plank directory
PLANK_BASE="$XDG_CONFIG_HOME/plank"

while true; do
    PLANK_DIR=$(find "$PLANK_BASE" -type d -name launchers 2>/dev/null | head -n 1 || true)

    if [ -n "${PLANK_DIR:-}" ]; then
        break
    fi

    echo "Waiting for Plank..."
    sleep 2
done

echo "Using PLANK_DIR: $PLANK_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_SCRIPT="$SCRIPT_DIR/update-plank-keybindings.sh"

# State tracking (for polling)
PREV_STATE=""

get_state() {
    ls "$PLANK_DIR" 2>/dev/null | sort || true
}

PREV_STATE=$(get_state)

echo "Initial state captured"


if command -v inotifywait >/dev/null; then
    USE_INOTIFY=true
    echo "Using inotify for fast detection"
else
    USE_INOTIFY=false
fi


while true; do

    if $USE_INOTIFY; then
        if inotifywait -qq -t 2 \
            -e create -e delete -e modify -e moved_to -e moved_from -e close_write \
            "$PLANK_DIR" 2>/dev/null; then
            
            echo "Event detected via inotify"
            sleep 1.5

            bash "$UPDATE_SCRIPT" || echo "Update failed"

            PREV_STATE=$(get_state)
            continue
        fi
    fi

    # Polling fallback (also primary if no inotify)
    CURRENT_STATE=$(get_state)

    if [ "$CURRENT_STATE" != "$PREV_STATE" ]; then
        echo "Change detected via polling"

        bash "$UPDATE_SCRIPT" || echo "Update failed"

        PREV_STATE="$CURRENT_STATE"
    fi

    sleep 2
done