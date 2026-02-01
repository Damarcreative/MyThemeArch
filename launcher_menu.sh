#!/bin/bash

# Launcher Menu - Quick access to pinned apps with actions
# This provides a Windows-like "right-click on pinned app" experience

TINT2RC="$HOME/.config/openbox/themes/my-edit/tint2/tint2rc"
RELOAD_CMD="$HOME/.config/openbox/themes/my-edit/polybar/launch.sh"

# Get list of pinned apps
get_pinned_apps() {
    grep "^launcher_item_app = " "$TINT2RC" | cut -d '=' -f2 | sed 's/^[ \t]*//'
}

# Get app name from desktop file
get_app_name() {
    local desktop_file="$1"
    if [ -f "$desktop_file" ]; then
        grep "^Name=" "$desktop_file" | head -1 | cut -d= -f2
    else
        basename "$desktop_file" .desktop
    fi
}

# Get app icon from desktop file
get_app_icon() {
    local desktop_file="$1"
    if [ -f "$desktop_file" ]; then
        grep "^Icon=" "$desktop_file" | head -1 | cut -d= -f2
    fi
}

# Build list for yad
build_app_list() {
    local i=1
    while IFS= read -r desktop_path; do
        if [ -f "$desktop_path" ]; then
            local name=$(get_app_name "$desktop_path")
            echo "$i"
            echo "$name"
            echo "$desktop_path"
            ((i++))
        fi
    done < <(get_pinned_apps)
}

# Show app selector
SELECTED=$(build_app_list | yad --title="Pinned Apps" \
    --center --width=400 --height=350 \
    --list --column="#" --column="App Name" --column="Path" \
    --hide-column=3 \
    --print-column=3 \
    --button="Cancel:1" --button="Select:0")

RET=$?
if [ $RET -ne 0 ] || [ -z "$SELECTED" ]; then
    exit 0
fi

# Clean path
SELECTED=$(echo "$SELECTED" | tr -d '|')
APP_NAME=$(get_app_name "$SELECTED")

# Show action menu for selected app
ACTION=$(yad --title="$APP_NAME" \
    --center --width=220 --height=200 \
    --list --column="Icon" --column="Action" --column="Command" \
    --print-column=3 --hide-column=3 \
    --no-headers \
    "▶" "  Open" "open" \
    "🔲" "  Open New Window" "open_new" \
    "─" "─────────────" "sep" \
    "↑" "  Move Up" "move_up" \
    "↓" "  Move Down" "move_down" \
    "─" "─────────────" "sep2" \
    "✕" "  Unpin" "unpin" \
    --button="Cancel:1" --button="OK:0")

RET=$?
if [ $RET -ne 0 ]; then
    exit 0
fi

ACTION=$(echo "$ACTION" | tr -d '|')

case $ACTION in
    open|open_new)
        gtk-launch "$(basename "$SELECTED" .desktop)" &
        ;;
    unpin)
        # Remove from tint2rc
        SAFE_PATH=$(echo "$SELECTED" | sed 's/[\/&]/\\&/g')
        sed -i "\|^launcher_item_app = $SELECTED$|d" "$TINT2RC"
        $RELOAD_CMD
        yad --title="Success" --text="$APP_NAME unpinned!" --timeout=2 --no-buttons --center
        ;;
    move_up)
        # Get line number and move up
        LINE_NUM=$(grep -n "^launcher_item_app = $SELECTED$" "$TINT2RC" | cut -d: -f1)
        if [ -n "$LINE_NUM" ] && [ "$LINE_NUM" -gt 1 ]; then
            # Find previous launcher line
            PREV_LINE=$(head -n $((LINE_NUM-1)) "$TINT2RC" | grep -n "^launcher_item_app = " | tail -1 | cut -d: -f1)
            if [ -n "$PREV_LINE" ]; then
                # Swap lines using awk
                awk -v l1="$PREV_LINE" -v l2="$LINE_NUM" '
                    NR==l1 {line1=$0; next}
                    NR==l2 {print line1; print $0; next}
                    {print}
                ' "$TINT2RC" > "$TINT2RC.tmp" && mv "$TINT2RC.tmp" "$TINT2RC"
                $RELOAD_CMD
            fi
        fi
        ;;
    move_down)
        # Get line number and move down
        LINE_NUM=$(grep -n "^launcher_item_app = $SELECTED$" "$TINT2RC" | cut -d: -f1)
        TOTAL_LINES=$(wc -l < "$TINT2RC")
        if [ -n "$LINE_NUM" ] && [ "$LINE_NUM" -lt "$TOTAL_LINES" ]; then
            # Find next launcher line
            NEXT_LINE=$(tail -n +$((LINE_NUM+1)) "$TINT2RC" | grep -n "^launcher_item_app = " | head -1 | cut -d: -f1)
            if [ -n "$NEXT_LINE" ]; then
                NEXT_LINE=$((LINE_NUM + NEXT_LINE))
                # Swap lines using awk
                awk -v l1="$LINE_NUM" -v l2="$NEXT_LINE" '
                    NR==l1 {line1=$0; next}
                    NR==l2 {print $0; print line1; next}
                    {print}
                ' "$TINT2RC" > "$TINT2RC.tmp" && mv "$TINT2RC.tmp" "$TINT2RC"
                $RELOAD_CMD
            fi
        fi
        ;;
esac
