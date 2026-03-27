# Plank Bind

A lightweight Linux utility that enables Windows-style Super + Number app launching for the Cinnamon desktop using Plank.

---

## Overview

Plank Bind dynamically maps your dock items to keyboard shortcuts (e.g. `Super + 1`, `Super + 2`, ...) based on their position in Plank's launchers directory (default: `~/.config/plank/dock1/launchers`)

* `Super + 1` → First dock item
* `Super + 2` → Second dock item
* `Super + 3` → Third dock item
* ...

Whenever you **pin or unpin apps** in Plank, the keybindings automatically update — no manual reconfiguration needed.

---

## Features

* **Dynamic Keybinding Generation**
  Automatically creates launcher scripts based on current dock apps.

* **Real-time Updates**
  Uses filesystem monitoring (*inotify and polling fallback*) to detect dock changes instantly.

* **Configurable**
  Supports custom Plank directories and maximum key limits.

* **Logging Support**
  All operations are logged for debugging and transparency.

* **Easy Install & Uninstall**
  Comes with clean setup and removal scripts.

---
## Tech Stack
* Bash Scripting
* Linux utilities
  * inotifywait (from inotify-tools)
  * gtk-launch

---
## Installation

```bash
git clone https://github.com/your-username/plank-bind.git
cd plank-bind
chmod +x install.sh
./install.sh
```

### Dependency (Optional)

For faster, event-based updates, install `inotify-tools` package if not already installed:

```bash
sudo apt install inotify-tools
```

### Requirements
- Ensure Plank is added to startup applications.
- Steps:
  1. Open System Settings → Startup Applications
  2. Click + at the bottom
  3. Select Plank

---

##  One-Time Setup

### Cinnamon Shortcuts

Go to:

System Settings → Keyboard → Shortcuts → Custom Shortcuts

Add the following:

| Shortcut    | Command                                             |
| ----------- | --------------------------------------------------- |
| `Super + 1` | `/home/YOUR_USER_NAME/.cache/plank-bind/launch1.sh` |
| `Super + 2` | `/home/YOUR_USER_NAME/.cache/plank-bind/launch2.sh` |
| `Super + 3` | `/home/YOUR_USER_NAME/.cache/plank-bind/launch3.sh` |
| ...         | ...                                                 |

⚠️ Disable any existing `Super + number` shortcuts to avoid conflicts.

### Apply Setup

For first-time setup, it is recommended to restart your system (or log out and log back in).

This is because Plank may not immediately persist dock changes to disk within the same session. Since Plank Bind relies on filesystem changes to detect updates, keybindings may not update correctly until Plank is initialized in a fresh session.

After restarting, all changes to pinned apps will be detected and keybindings will update as expected.

---

## How It Works

1. Plank stores dock items as `.dockitem` files.
2. A background watcher (via autostart `.desktop` entry) monitors the dock directory
3. On detecting changes:
   * Old launcher scripts are removed
   * New scripts are generated based on current dock items (`launch1.sh`, `launch2.sh`, ...)
   * Each launch script launches the corresponding app using `gtk-launch` 
4. Cinnamon shortcuts point to these generated scripts.

---

## Configuration

Config file location:

```
~/.config/plank-bind.conf
```

Example:

```bash
MAX_KEYS=9
# Custom Plank directory (Optional) :
# PLANK_DIR="$HOME/.config/plank/dock1/launchers"
```

---

## Limitations

* Dock order is inferred from filesystem ordering (not Plank’s internal config).
* Cinnamon shortcuts must be set manually (only once).

---

## Uninstall

```bash
chmod +x uninstall.sh
./uninstall.sh
```
