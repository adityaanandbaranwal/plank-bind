#!/bin/bash

set -euo pipefail

echo "Uninstalling Plank Bind..."

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

CONFIG_FILE="$XDG_CONFIG_HOME/plank-bind.conf"
AUTOSTART_FILE="$XDG_CONFIG_HOME/autostart/plank-bind.desktop"
CACHE_DIR="$XDG_CACHE_HOME/plank-bind"
LOG_FILE="$XDG_CACHE_HOME/plank-bind.log"


# Remove autostart entry
if [ -f "$AUTOSTART_FILE" ]; then
    rm "$AUTOSTART_FILE"
    echo "Removed autostart entry"
fi


# Remove generated scripts
if [ -d "$CACHE_DIR" ]; then
    rm -rf "$CACHE_DIR"
    echo "Removed generated scripts"
fi

# Stop running watcher process
if pgrep -f plank-bind-watcher.sh > /dev/null; then
    pkill -f plank-bind-watcher.sh 2>/dev/null || true
    echo "Stopped running watcher process"
fi

# Remove log file
if [ -f "$LOG_FILE" ]; then
    rm "$LOG_FILE"
    echo "Removed log file"
fi

# Ask before removing config
if [ -f "$CONFIG_FILE" ]; then
    read -p "Remove config file? (y/N): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        rm "$CONFIG_FILE"
        echo "Removed config file"
    else
        echo "Config file preserved"
    fi
fi

echo "Plank Bind uninstalled successfully"
echo "NOTE: Cinnamon keybindings must be removed manually if needed"