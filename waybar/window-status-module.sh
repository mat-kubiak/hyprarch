#!/bin/bash
_props=$(hyprctl -j activewindow)
_maximized=$(echo $_props | jq -r '.fullscreen')
_floating=$(echo $_props | jq -r '.floating')
_xwayland=$(echo $_props | jq -r '.xwayland')

_out=""
if [[ "$_maximized" == "true" ]]; then
	_out="${_out}M"
else
	_out="${_out} "
fi

if [[ "$_floating" == "true" ]]; then
	_out="${_out}F"
else
	_out="${_out} "
fi

if [[ "$_xwayland" == "true" ]]; then
	_out="${_out}X"
else
	_out="${_out} "
fi

echo $_out
