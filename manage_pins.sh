#!/bin/bash

# Bar Settings Manager
# Manages pinned apps in tint2 taskbar

TINT2RC="$HOME/.config/openbox/themes/my-edit/tint2/tint2rc"
PENDING_RELOAD=0

# Get app path only
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

# Apply changes (reload bars)
apply_changes() {
    if [ "$PENDING_RELOAD" -eq 1 ]; then
        killall -q tint2
        tint2 -c "$TINT2RC" &>/dev/null &
        PENDING_RELOAD=0
    fi
}

# Function to show main menu
show_main_menu() {
    while true; do
        ACTION=$(yad --title="Bar Settings" \
            --center --width=300 --height=180 \
            --window-icon="preferences-system" \
            --text="<b>Taskbar Settings</b>\nManage pinned apps" \
            --list --column="Action" --column="Cmd" \
            --print-column=2 --hide-column=2 \
            --no-headers \
            "Add Pinned App" "ADD" \
            "Remove Pinned App" "REMOVE" \
            "Apply and Reload Bars" "RELOAD" \
            --button="Close:1" --button="Select:0" 2>/dev/null)
        
        RET=$?
        ACTION=$(echo "$ACTION" | tr -d '|')
        
        if [ $RET -ne 0 ]; then
            apply_changes
            exit 0
        fi
        
        case $ACTION in
            ADD) add_app ;;
            REMOVE) remove_app ;;
            RELOAD) 
                PENDING_RELOAD=1
                apply_changes
                ;;
        esac
    done
}

# Function to add an app
add_app() {
    APP_PATH=$(yad --title="Select Application" \
        --center --width=600 --height=500 \
        --file --file-filter="Desktop Files | *.desktop" \
        --filename="/usr/share/applications/" 2>/dev/null)
    
    if [ -n "$APP_PATH" ]; then
        if grep -q "launcher_item_app = $APP_PATH" "$TINT2RC"; then
            yad --title="Error" --text="App is already pinned!" --button="OK" --center 2>/dev/null
        else
            sed -i "/launcher_tooltip = 1/a launcher_item_app = $APP_PATH" "$TINT2RC"
            PENDING_RELOAD=1
            yad --title="Success" --text="App added! Click 'Apply and Reload' to see changes." --timeout=2 --no-buttons --center 2>/dev/null
        fi
    fi
}

# Function to remove an app
remove_app() {
    local list_data=""
    while IFS= read -r line; do
        if [ -f "$line" ]; then
            local name=$(get_app_name "$line")
            list_data="${list_data}${name}\n${line}\n"
        fi
    done < <(get_pinned_apps)
    
    SELECTED=$(echo -e "$list_data" | yad --title="Remove Pinned App" \
        --center --width=400 --height=320 \
        --list --column="App Name" --column="Path" \
        --hide-column=2 \
        --print-column=2 \
        --button="Cancel:1" --button="Remove:0" 2>/dev/null)
    
    SELECTED=$(echo "$SELECTED" | tr -d '|')
    
    if [ -n "$SELECTED" ]; then
        sed -i "\|^launcher_item_app = ${SELECTED}$|d" "$TINT2RC"
        PENDING_RELOAD=1
        yad --title="Removed" --text="App removed! Click 'Apply and Reload' to see changes." --timeout=2 --no-buttons --center 2>/dev/null
    fi
}

# Start
show_main_menu
