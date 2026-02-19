#!/usr/bin/env bash
set -u

CHECK="/home/kevin/.config/i3/scripts/set_game_mode.sh"

# run once at start
"$CHECK" >/dev/null 2>&1 || true

# Subscribe to i3 events and process them
i3-msg -t subscribe -m '["workspace","window"]' | while IFS= read -r event; do
    # Only trigger if it's a workspace change or window focus change
    if echo "$event" | grep -qE '(workspace|window)'; then
        "$CHECK" >> /dev/null 2>&1 || true
    fi
done
