#!/bin/bash

# Apply Settings Script
# Reads settings.conf and applies the configuration

SETTINGS_FILE="$HOME/.config/openbox/themes/my-edit/settings.conf"
POLYBAR_CONFIG="$HOME/.config/openbox/themes/my-edit/polybar/config.ini"
TINT2RC="$HOME/.config/openbox/themes/my-edit/tint2/tint2rc"
THEME_BASH="$HOME/.config/openbox/themes/my-edit/theme.bash"

# Load settings
source "$SETTINGS_FILE"

# Apply bottom bar setting
if [ "$SHOW_BOTTOM_BAR" = "true" ]; then
    # Show bottom bar
    # Ensure pinsettings in modules-right
    if ! grep -q "pinsettings sysmenu" "$POLYBAR_CONFIG"; then
        sed -i 's/battery dot sysmenu/battery dot pinsettings sysmenu/' "$POLYBAR_CONFIG"
    fi
    # Set bottom margin to 24
    sed -i "s/^ob_margin_b='0'/ob_margin_b='24'/" "$THEME_BASH"
    # Start tint2 if not running
    if ! pgrep -x tint2 > /dev/null; then
        tint2 -c "$TINT2RC" &>/dev/null &
    fi
else
    # Hide bottom bar
    # Remove pinsettings from modules-right
    sed -i 's/battery dot pinsettings sysmenu/battery dot sysmenu/' "$POLYBAR_CONFIG"
    # Set bottom margin to 0
    sed -i "s/^ob_margin_b='24'/ob_margin_b='0'/" "$THEME_BASH"
    # Kill tint2
    killall -q tint2
fi

# Restart polybar
~/.config/openbox/themes/my-edit/polybar/launch.sh

# Reconfigure openbox to apply margin changes
openbox --reconfigure

echo "Settings applied!"
