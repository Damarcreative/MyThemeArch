#!/bin/bash

# Enhanced Window Actions Menu
# Windows-like context menu for running/active apps
# Appears at cursor position like a real context menu

# Small delay to ensure the clicked window is focused
sleep 0.05

# Get mouse position for popup placement
eval $(xdotool getmouselocation --shell 2>/dev/null)
MOUSE_X=$X
MOUSE_Y=$Y

# Get the active window ID
ACTIVE_WID=$(xdotool getactivewindow 2>/dev/null)

# Fallback: if no active window, try window under cursor
if [ -z "$ACTIVE_WID" ]; then
    ACTIVE_WID=$WINDOW
fi

if [ -z "$ACTIVE_WID" ] || [ "$ACTIVE_WID" = "0" ]; then
    notify-send "Window Actions" "No active window found!" 2>/dev/null
    exit 1
fi

# Get app class/name for the title
APP_CLASS=$(xprop -id "$ACTIVE_WID" WM_CLASS 2>/dev/null | cut -d'"' -f2)

# If app class is empty or is tint2, exit silently
if [ -z "$APP_CLASS" ] || [ "$APP_CLASS" = "tint2" ] || [ "$APP_CLASS" = "Tint2" ]; then
    exit 0
fi

# Check window states
WINDOW_STATE=$(xprop -id "$ACTIVE_WID" _NET_WM_STATE 2>/dev/null)
IS_ABOVE=$(echo "$WINDOW_STATE" | grep -c "_NET_WM_STATE_ABOVE")
IS_MAXIMIZED=$(echo "$WINDOW_STATE" | grep -c "_NET_WM_STATE_MAXIMIZED")

# Dynamic labels
[ "$IS_ABOVE" -gt 0 ] && ABOVE_LABEL="✓ Always on Top" || ABOVE_LABEL="  Always on Top"
[ "$IS_MAXIMIZED" -gt 0 ] && MAX_LABEL="  Restore" || MAX_LABEL="  Maximize"

# Show popup menu at cursor position using yad
ACTION=$(yad --title="" \
    --geometry=180x240+${MOUSE_X}+$((MOUSE_Y - 250)) \
    --undecorated --skip-taskbar --on-top \
    --list --column="Action" --column="Cmd" \
    --print-column=2 --hide-column=2 \
    --no-headers --no-buttons \
    --dclick-action="echo %s" \
    "▶ Open New Window" "new_window" \
    "───────────────" "sep" \
    "$ABOVE_LABEL" "toggle_above" \
    "$MAX_LABEL" "toggle_maximize" \
    "  Minimize" "iconify" \
    "───────────────" "sep" \
    "  Move" "move" \
    "  Resize" "resize" \
    "───────────────" "sep" \
    "✕ Close" "close" \
    2>/dev/null)

# Clean the action
ACTION=$(echo "$ACTION" | tr -d '|' | head -1)

[ -z "$ACTION" ] && exit 0

case $ACTION in
    new_window)
        DESKTOP_FILE=$(find /usr/share/applications ~/.local/share/applications -iname "*${APP_CLASS}*.desktop" 2>/dev/null | head -1)
        if [ -n "$DESKTOP_FILE" ]; then
            gtk-launch "$(basename "$DESKTOP_FILE" .desktop)" &
        else
            "${APP_CLASS,,}" 2>/dev/null &
        fi
        ;;
    close)
        xdotool windowclose "$ACTIVE_WID"
        ;;
    toggle_maximize)
        wmctrl -ir "$ACTIVE_WID" -b toggle,maximized_vert,maximized_horz
        ;;
    iconify)
        xdotool windowminimize "$ACTIVE_WID"
        ;;
    toggle_above)
        wmctrl -ir "$ACTIVE_WID" -b toggle,above
        ;;
    move)
        xdotool key Alt+F7
        ;;
    resize)
        xdotool key Alt+F8
        ;;
esac
