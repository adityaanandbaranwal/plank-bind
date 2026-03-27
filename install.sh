#!/bin/bash

set -euo pipefail

echo "Installing Plank Bind"

if command -v inotifywait >/dev/null; then
    echo "inotify-tools found: using inotifywait for fast detection"
else
    echo "inotify-tools not found: falling back to polling mode"
fi

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
WATCHER_PATH="$SCRIPT_DIR/bin/plank-bind-watcher.sh"

echo "Running initial setup..."
chmod +x "$SCRIPT_DIR"/bin/*.sh
bash "$SCRIPT_DIR/bin/update-plank-keybindings.sh" || {
    echo "Initial update skipped (Plank may not be setup yet)"
    echo "Make sure Plank is running and has pinned apps."
}

cat > "$AUTOSTART_DIR/plank-bind.desktop" << EOF
[Desktop Entry]
Type=Application
Exec=/bin/bash -c 'sleep 5 && cd "$SCRIPT_DIR" && "$WATCHER_PATH"'
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Terminal=false
Name=Plank Bind
Comment=Dynamic Keybindings for Plank Dock
EOF
echo "Autostart entry created successfully"

echo "Installation completed successfully"
echo "IMPORTANT NOTE: Don't forget to create Cinnamon shortcuts! (to be done only once)"
echo "Go to System Settings -> Keyboard -> Shortcuts -> Custom Shortcuts"
echo "Make sure your cinnamon shortcuts (Super + nummber) point to the absolute path of launch files:"
echo "/home/YOUR_USER_NAME/.cache/plank-bind/launch1.sh ... launch9.sh"
