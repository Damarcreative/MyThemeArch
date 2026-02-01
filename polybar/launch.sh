#!/usr/bin/env bash

## Copyright (C) 2020-2025 Aditya Shakya <adi1090x@gmail.com>

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CARD="$(light -L | grep 'backlight' | head -n1 | cut -d'/' -f3)"
INTERFACE="$(ip link | awk '/state UP/ {print $2}' | tr -d :)"
BAT="$(acpi -b)"
RFILE="$DIR/.module"

# Fix backlight and network modules
fix_modules() {
	if [[ -z "$CARD" ]]; then
		sed -i -e 's/backlight/bna/g' "$DIR"/config.ini
	elif [[ "$CARD" != *"intel_"* ]]; then
		sed -i -e 's/backlight/brightness/g' "$DIR"/config.ini
	fi

	if [[ -z "$BAT" ]]; then
		sed -i -e 's/battery/btna/g' "$DIR"/config.ini
	fi

	if [[ "$INTERFACE" == e* ]]; then
		sed -i -e 's/network/ethernet/g' "$DIR"/config.ini
	fi
}

# Launch the bar
launch_bar() {
	# Terminate already running bar instances
	killall -q polybar

	# Wait until the processes have been shut down
	while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

	# Launch the bar
	for mon in $(polybar --list-monitors | cut -d":" -f1); do
		MONITOR=$mon polybar -q main -c "$DIR"/config.ini &
	done
	
	# Check settings for bottom bar
	SETTINGS_FILE="$HOME/.config/openbox/themes/my-edit/settings.conf"
	if [[ -f "$SETTINGS_FILE" ]]; then
		source "$SETTINGS_FILE"
	fi
	
	# Launch tint2 only if SHOW_BOTTOM_BAR is true or not set
	killall -q tint2
	if [[ "$SHOW_BOTTOM_BAR" != "false" ]]; then
		tint2 -c "$HOME/.config/openbox/themes/my-edit/tint2/tint2rc" &
	fi
}

# Execute functions
if [[ ! -f "$RFILE" ]]; then
	fix_modules
	touch "$RFILE"
fi	
launch_bar
