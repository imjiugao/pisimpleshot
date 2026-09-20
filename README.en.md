[中文](README.md) | **English**

# PisimpleShot — a one-click screenshot tray icon for Raspberry Pi

A camera icon that lives in the panel tray at the top-right of Raspberry Pi OS
(labwc / wf-panel-pi desktop) and takes screenshots in one click.

## Features

| Action | Effect |
|---|---|
| **Left click** the tray icon | Instant full-screen screenshot: saved to `~/Pictures/Screenshots/` and copied to the clipboard |
| **Right click** the tray icon | Menu: Full-screen shot / Region shot… (drag to select, Esc to cancel) / Full-screen shot after 3 seconds / Open screenshots folder / Quit |
| **Middle click** the tray icon | Shortcut for "Region shot" |

Every successful shot gives a non-intrusive confirmation: **the tray icon briefly
turns into a green-check version (3 seconds), and hovering it shows the saved
path** — no popup, no focus stealing, nothing in the taskbar.

## Configuration

The config file lives at `~/.config/PisimpleShot/config.ini` and is created on
first run:

```ini
[PisimpleShot]
feedback = icon
```

| Option | Values | Meaning |
|---|---|---|
| `feedback` | `icon` (default) | After a shot, the tray icon shows a green check for 3 seconds; hovering reveals the saved path |
| | `window` | Legacy popup notification (steals focus) |
| | `none` | No feedback at all |

- Changes take effect **immediately** — no restart needed
- Popups reporting a *failed* shot are not affected by this setting and always show
- The legacy `show_popup` (true/false) key is still honoured: `false` equals `none`

## Install

```bash
cd pisimpleshot
./install.sh
```

The script checks dependencies and reports anything missing → copies the program
and icons into `~/.local` → creates the application-menu entry and the autostart
entry → starts the tray icon right away.

After installing, PisimpleShot **starts automatically on every boot** — no manual
step required.

## Uninstall

```bash
./uninstall.sh
```

Removes the program, the icons, the menu entry and the autostart entry. Your
existing screenshots in `~/Pictures/Screenshots/` are kept.

## Starting it manually / after quitting

- Main menu → Accessories → **PisimpleShot 快速截图**
- Or from a terminal: `~/.local/bin/pisimpleshot &`

The program is single-instance: launching it again does not create a second icon.

## Files

```
pisimpleshot/
├── install.sh              # installer
├── uninstall.sh            # uninstaller
├── src/pisimpleshot        # main program (Python 3 + PyGObject, single file)
└── icons/
    ├── pisimpleshot.svg         # tray / application icon (vector)
    ├── pisimpleshot.png         # 48px bitmap (source for the tray pixel icon)
    ├── pisimpleshot-success.svg # success feedback icon (green check, vector)
    └── pisimpleshot-success.png # success feedback icon, 48px bitmap
```

> The icon file names must match `ICON_NAME` in the code and `Icon=` in the
> desktop entry exactly — **all lowercase**. Any case mismatch makes the icon
> theme lookup fail and leaves an empty gap in the tray.

## Dependencies

All of these ship with the desktop edition of Raspberry Pi OS:

| Dependency | Used for | If missing |
|---|---|---|
| `python3-gi` / GTK3 | the program itself | won't run (required) |
| `grim` | Wayland screenshots | can't take screenshots (required) |
| `slurp` | region selection | region shot unavailable |
| `wl-clipboard` | copying to the clipboard | only clipboard copying is lost |
| `pcmanfm` | "Open screenshots folder" | only that menu item is lost |

## Implementation notes

The Raspberry Pi OS Bookworm+ panel (wf-panel-pi) shows tray icons through the
org.kde.StatusNotifierItem protocol. PisimpleShot exports that interface directly
with PyGObject/Gio:

- the icon is provided as raw pixels (`IconPixmap`), which avoids the panel's
  theme cache making the icon disappear;
- the right-click menu is served over `com.canonical.dbusmenu`, with layout nodes
  in the `(ia{sv}av)` form (children as an array of variants) and every method
  reply wrapped in a tuple — both are key to interoperating with libdbusmenu
  clients;
- after quitting or uninstalling, restart the panel or log back in to clear any
  leftover icon.
