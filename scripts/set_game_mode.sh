#!/usr/bin/env bash

#!/usr/bin/env bash
set -euo pipefail

# Get current workspace name
WS=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name')

if [[ "$WS" == game* ]]; then
    i3-msg 'mode "gaming"'
    notify-send -t 1000 "Mode: $WS"
else
    i3-msg 'mode "default"'
fi



