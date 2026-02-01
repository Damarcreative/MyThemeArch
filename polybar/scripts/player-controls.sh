#!/bin/bash

# Smart Player Controls Script for Polybar
# Shows MPD controls by default, switches to playerctl when external player is active

# Colors
GREEN="#98C379"
YELLOW="#E5C07A"
BLUE="#61AFEF"
MAGENTA="#C678DD"

# Check if any external player (non-mpd) is playing
EXTERNAL_STATUS=$(playerctl -a status 2>/dev/null | grep -v "No players found" | grep -v "^$" | head -1)
MPD_STATUS=$(mpc status 2>/dev/null | grep -E "\[playing\]|\[paused\]")

# Priority: External player > MPD
if [[ -n "$EXTERNAL_STATUS" && "$EXTERNAL_STATUS" != "Stopped" ]]; then
    # External player is active (browser, Spotify, etc.)
    STATUS=$(playerctl status 2>/dev/null)
    
    if [ "$STATUS" = "Playing" ]; then
        TOGGLE="%{F${YELLOW}}󰏤%{F-}"
    else
        TOGGLE="%{F${GREEN}}󰐊%{F-}"
    fi
    
    PREV="%{A1:playerctl previous:}%{F${BLUE}}󰒮%{F-}%{A}"
    NEXT="%{A1:playerctl next:}%{F${BLUE}}󰒭%{F-}%{A}"
    PLAY_PAUSE="%{A1:playerctl play-pause:}${TOGGLE}%{A}"
    
    echo "${PREV} ${PLAY_PAUSE} ${NEXT}"
    
elif [[ -n "$MPD_STATUS" ]] || mpc status &>/dev/null; then
    # MPD is available - show MPD controls
    if echo "$MPD_STATUS" | grep -q "\[playing\]"; then
        TOGGLE="%{F${YELLOW}}󰏤%{F-}"
    else
        TOGGLE="%{F${MAGENTA}}󰐊%{F-}"
    fi
    
    PREV="%{A1:mpc prev:}%{F${MAGENTA}}󰒮%{F-}%{A}"
    NEXT="%{A1:mpc next:}%{F${MAGENTA}}󰒭%{F-}%{A}"
    PLAY_PAUSE="%{A1:mpc toggle:}${TOGGLE}%{A}"
    
    echo "${PREV} ${PLAY_PAUSE} ${NEXT}"
else
    # No player available
    echo ""
fi
