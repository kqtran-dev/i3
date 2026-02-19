#!/bin/bash
i3-msg workspace $1
current_ws=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).name' | cut -d"\"" -f2)
if [ "$current_ws" == 'g' ]
then
    i3-msg mode 'gaming'
else
    i3-msg mode 'default'
fi
