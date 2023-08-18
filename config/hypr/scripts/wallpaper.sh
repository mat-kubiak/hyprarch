#!/bin/sh

_wallpapers_dir="/usr/share/wallpapers"

if [[ "$_start" == "1" ]]; then
    swww init
fi

swww img "$_wallpapers_dir/$_status"