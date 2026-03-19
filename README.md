# Plank Bind

A lightweight Linux utility that enables Windows-style Super + Number app launching for the Cinnamon desktop using Plank.

---

## Overview

Plank Bind dynamically maps your dock applications to keyboard shortcuts:

* `Super + 1` → First app in dock
* `Super + 2` → Second app
* `Super + 3` → Third app
* ...

Whenever you **add, remove, or reorder apps in Plank**, the keybindings automatically update — no manual reconfiguration needed.

---

## Features

* **Dynamic Keybinding Generation**
  Automatically creates launcher scripts based on current dock apps.

* **Real-time Updates**
  Uses filesystem monitoring (`inotify`) to detect dock changes instantly.

* **Configurable**
  Supports custom Plank directories and max key limits.

* **Crash-safe Design**
  Avoids modifying Cinnamon’s internal keybinding schema.

* **Logging Support**
  All operations are logged for debugging and transparency.

* **Easy Install & Uninstall**
  Comes with clean setup and removal scripts.

---

## Installation

```bash
git clone https://github.com/your-username/plank-bind.git
cd plank-bind
chmod +x install.sh
./install.sh
```

### Dependency

```bash
sudo apt install inotify-tools
```

---

##  One-Time Setup (Cinnamon Shortcuts)

Go to:

System Settings → Keyboard → Shortcuts → Custom Shortcuts

Add the following:

| Shortcut  | Command                          |
| --------- | -------------------------------- |
| Super + 1 | `~/.cache/plank-bind/launch1.sh` |
| Super + 2 | `~/.cache/plank-bind/launch2.sh` |
| Super + 3 | `~/.cache/plank-bind/launch3.sh` |
| ...       | ...                              |

⚠️ Disable any existing `Super + number` shortcuts to avoid conflicts.

---

## How It Works

1. Plank stores dock items as `.dockitem` files.
2. A watcher script monitors changes in the dock directory.
3. On change:

   * Old launcher scripts are removed
   * New scripts are generated based on current dock apps
4. Keyboard shortcuts point to these generated scripts.

---

## Configuration

Config file location:

```
~/.config/plank-bind.conf
```

Example:

```bash
MAX_KEYS=9
# PLANK_DIR="$HOME/.config/plank/dock1/launchers"
```

---

## Limitations

* Dock order is inferred from filesystem ordering (not Plank’s internal config).
* Cinnamon keybindings must be set manually (only once).

---

## Uninstall

```bash
chmod +x uninstall.sh
./uninstall.sh
```
