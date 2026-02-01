# Modified Archcraft Openbox Theme

![Screenshot](example.png)

A customized Openbox theme for personal use, built on top of [ArchCraft](https://archcraft.io/) by [Aditya Shakya](https://github.com/adi1090x).

## Credits

Based on original work by:
- **Copyright (C) 2020-2025 Aditya Shakya** ([@adi1090x](https://github.com/adi1090x)) <adi1090x@gmail.com>
- Original theme from [ArchCraft Openbox Edition](https://archcraft.io/)

## Features

- **Smart Media Controls** - Auto-switches between MPD (local) and external players (browser, Spotify)
- **Polybar Top Bar** - Date, media controls, volume, network, battery, system tray
- **Tint2 Bottom Bar** - App launcher, pinned apps, running apps
- **Toggle Bottom Bar** - Hide/show taskbar with `settings.conf`
- **Pin App Manager** - GUI to manage pinned applications

## Prerequisites

```bash
sudo pacman -S playerctl yad xdotool wmctrl xprop mpc
```

## Setup

1. **Make scripts executable:**
```bash
chmod +x ~/.config/openbox/themes/my-edit/*.sh
chmod +x ~/.config/openbox/themes/my-edit/polybar/scripts/*.sh
```

2. **Apply theme:**
```bash
~/.config/openbox/themes/my-edit/apply.sh
```

## Configuration

### Toggle Bottom Bar

Edit `settings.conf`:
```bash
# Set to false to hide bottom bar (tint2)
# useful if you want to use your own dock (e.g. Plank, Latte)
SHOW_BOTTOM_BAR=false
```

Then apply:
```bash
./apply.sh
```

### Restart Bars

```bash
# Polybar only
~/.config/openbox/themes/my-edit/polybar/launch.sh

# Both bars
./apply.sh
```

## License

This is a personal modification for private use. Original scripts and themes are property of Aditya Shakya under ArchCraft.
