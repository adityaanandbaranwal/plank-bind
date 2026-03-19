#!/bin/bash

set -euo pipefail


# XDG Paths - 
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

CONFIG_FILE="$XDG_CONFIG_HOME/plank-bind.conf"
LOG_FILE="$XDG_CACHE_HOME/plank-bind.log"
TARGET_DIR="$XDG_CACHE_HOME/plank-bind"

mkdir -p "$TARGET_DIR"
mkdir -p "$(dirname "$LOG_FILE")"


# Logging setup for basic journalling and debugging
exec >> "$LOG_FILE" 2>&1

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "---- Running update script ----"


# Load config (optional)
if [ -f "$CONFIG_FILE" ]; then
    log "Loading config from $CONFIG_FILE"
    source "$CONFIG_FILE"
fi

# Use defaults (if not set in config)
MAX_KEYS="${MAX_KEYS:-9}"
PLANK_DIR="${PLANK_DIR:-$XDG_CONFIG_HOME/plank/dock1/launchers}"


# Validate Plank directory
if [ ! -d "$PLANK_DIR" ]; then
    log "ERROR: Plank directory not found at $PLANK_DIR"
    exit 1
fi


# Clean old scripts
rm -f "$TARGET_DIR"/launch*.sh


# Generate new scripts
index=1

while IFS= read -r file; do
    [ "$index" -gt "$MAX_KEYS" ] && break

    full_path="$PLANK_DIR/$file"
    [ -f "$full_path" ] || continue

    # safety check for corrupted .dockitem file
    desktop_line=$(grep "^Launcher=" "$full_path" 2>/dev/null || true)
    if [ -z "$desktop_line" ]; then
        log "Skipping invalid file: $file"
        continue
    fi

    desktop_file=$(basename "$(echo "$desktop_line" | sed 's|Launcher=file://||')")
    app_name="${desktop_file%.desktop}"

    # safety check for empty app name
    if [ -z "$app_name" ]; then
        log "Skipping file with empty app: $file"
        continue
    fi

    script="$TARGET_DIR/launch${index}.sh"

    cat > "$script" <<EOF
#!/bin/bash
gtk-launch "$app_name"
EOF

    chmod +x "$script"

    log "Created launch${index}.sh → $app_name"

    ((index++))
done < <(find "$PLANK_DIR" -maxdepth 1 -type f -printf "%f\n" | sort)

log "Update complete"