#!/bin/sh

_touchpad_device="elan1200:00-04f3:309f-touchpad"

if [[ "$_start" == "0" ]]; then _toggle_status; fi

if [[ "$_status" == "1" ]]; then
    hyprctl keyword "device:$_touchpad_device:enabled" true > /dev/null
else
    hyprctl keyword "device:$_touchpad_device:enabled" false > /dev/null
fi
