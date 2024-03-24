#!/bin/sh

_wallpapers_dir="$HOME/.config/wallpapers/"

# change to another wallpaper at random
_status=$(python3 -c """import os, random;\
dirs = os.listdir('$_wallpapers_dir');\
dirs.remove('$_status') if '$_status' in dirs else '';\
print(random.choice(dirs))""")

if [[ "$_start" == "1" ]]; then
    swww init --no-cache
fi

swww img --resize crop -t none "$_wallpapers_dir/$_status"
