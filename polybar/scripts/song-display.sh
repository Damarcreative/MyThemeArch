#!/bin/bash

# Smart Song Display Script for Polybar
# Shows MPD song by default, switches to playerctl when external player is active
# Max 32 characters including "..."

# Check if any external player (non-mpd) is active
EXTERNAL_STATUS=$(playerctl -a status 2>/dev/null | grep -v "No players found" | grep -v "^$" | head -1)

if [[ -n "$EXTERNAL_STATUS" && "$EXTERNAL_STATUS" != "Stopped" ]]; then
    # External player - get song from playerctl
    SONG=$(playerctl metadata --format '{{title}}' 2>/dev/null)
    if [[ -n "$SONG" ]]; then
        if [[ ${#SONG} -gt 29 ]]; then
            echo "${SONG:0:29}..."
        else
            echo "$SONG"
        fi
    fi
else
    # MPD - get song from mpc
    SONG=$(mpc current 2>/dev/null)
    if [[ -n "$SONG" ]]; then
        if [[ ${#SONG} -gt 29 ]]; then
            echo "${SONG:0:29}..."
        else
            echo "$SONG"
        fi
    fi
fi
