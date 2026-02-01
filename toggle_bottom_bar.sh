#!/bin/bash

# Toggle Bottom Bar Script
# Toggles tint2 visibility and adjusts polybar accordingly

SETTINGS_FILE="$HOME/.config/openbox/themes/my-edit/settings.conf"
POLYBAR_CONFIG="$HOME/.config/openbox/themes/my-edit/polybar/config.ini"
TINT2RC="$HOME/.config/openbox/themes/my-edit/tint2/tint2rc"

# Load current settings
source "$SETTINGS_FILE"

# Toggle the value
if [ "$SHOW_BOTTOM_BAR" = "true" ]; then
    NEW_VALUE="false"
else
    NEW_VALUE="true"
fi

# Update settings file
sed -i "s/^SHOW_BOTTOM_BAR=.*/SHOW_BOTTOM_BAR=$NEW_VALUE/" "$SETTINGS_FILE"

# Apply changes
if [ "$NEW_VALUE" = "true" ]; then
    # Show bottom bar
    # Show pinsettings in modules-right
    sed -i 's/battery dot sysmenu/battery dot pinsettings sysmenu/' "$POLYBAR_CONFIG"
    # Start tint2
    tint2 -c "$TINT2RC" &>/dev/null &
    notify-send "Bottom Bar" "Enabled" -t 1500
else
    # Hide bottom bar
    # Remove pinsettings from modules-right
    sed -i 's/battery dot pinsettings sysmenu/battery dot sysmenu/' "$POLYBAR_CONFIG"
    # Kill tint2
    killall -q tint2
    notify-send "Bottom Bar" "Disabled" -t 1500
fi

# Restart polybar
~/.config/openbox/themes/my-edit/polybar/launch.sh
