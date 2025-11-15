#!/bin/sh

# for layout in ~/.config/i3/layouts/*; do
#   i3-msg "workspace chat ; append_layout $layout"
# done

i3-msg "workspace chat ; append_layout ~/.config/i3/layouts/workspace-chat.json"
(discord &)
(steam &)
(bluebubbles &)
