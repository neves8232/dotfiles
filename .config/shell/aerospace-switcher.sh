#!/bin/bash
aerospace layout floating

selected=$(aerospace list-windows --all --format '%{window-id} %{workspace} %{window-title}' | fzf --exact)
if [ -n "$selected" ]; then
  window_id=$(echo "$selected" | awk '{print $1}')
  workspace=$(echo "$selected" | awk '{print $2}')

  aerospace move-node-to-workspace "$workspace"

  aerospace workspace "$workspace"
  aerospace focus --window-id "$window_id"
fi
