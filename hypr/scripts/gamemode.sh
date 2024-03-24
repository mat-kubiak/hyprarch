#!/usr/bin/env sh

if [[ "$_start" == "0" ]]; then _toggle_status; fi

if [[ "$_status" == "1" ]]; then
    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:drop_shadow 0;\
        keyword decoration:blur 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0"
else
    hyprctl reload
fi
