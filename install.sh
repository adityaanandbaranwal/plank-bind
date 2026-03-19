#!/bin/bash

set -euo pipefail

command -v inotifywait >/dev/null || {
    echo "Please install inotify-tools"
    exit 1
}

echo "Installing Plank Bind"

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_FILE="$CONFIG_DIR/plank-bind.conf"

mkdir -p "$CONFIG_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
    cp config/plank-bind-config.conf "$CONFIG_FILE"
    echo "Config file created at $CONFIG_FILE"
fi

AUTOSTART_DIR="$CONFIG_DIR/autostart"
mkdir -p "$AUTOSTART_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WATCHER_PATH="$SCRIPT_DIR/bin/plank-watcher.sh"

chmod +x "$SCRIPT_DIR"/bin/*.sh
bash "$SCRIPT_DIR/bin/update-plank-scripts.sh"

cat > "$AUTOSTART_DIR/plank-bind.desktop" << EOF
[Desktop Entry]
Type=Application
Exec="$WATCHER_PATH"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Plank Bind
Comment=Dynamic Keybindings for Plank Dock
EOF

echo "Autostart entry created successfully"
echo "Running initial setup..."
bash bin/update-plank-keybindings.sh

echo "Installation completed successfully"
echo "IMPORTANT NOTE: Don't forget to create Cinnamon shortcuts! (to be done only once)"
echo "Go to System Settings -> Keyboard -> Shortcuts"
echo "Make sure your cinnamon shortcuts (Super + nummber) point to:"
echo "~/.cache/plank-bind/launch1.sh ... launch9.sh"