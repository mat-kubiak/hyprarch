#!/bin/bash

_help_page="HyprArch configuration install script.
\t-h - Display help page.
\t-d - Debug mode, won't install anything.
\t-e - Specify the config editor. Either nano (default) or vim.\n"

# OPTIONS
while getopts ':hde:' OPTION; do
  case "$OPTION" in
    :)
    printf "[ERROR] Unrecognized parameter.\n"
    exit 1
    ;;
    h)
    printf "$_help_page"
    exit 0
    ;;
    d)
    _debug=yes
    ;;
    e)
    _editor="$OPTARG"
    if [[ ! "$_editor" == @(nano|vim) ]]; then
      printf "[ERROR] Choose either nano or vim as the editor.\n"
      exit 1
    fi
    ;;
  esac
done


if [[ "$_debug" == "yes" ]]; then
  _instl_pacman()     { echo "[PACMAN] Installed $@"; }
  _instl_yay()        { echo "[YAY] Installed $@"; }
  _enable_service()   { echo "[SYSTEMCTL] Enabled $@"; }
  _copy_config()      { echo "[DEBUG] Copied config from folder $1"; }
  _copy_sudo()        { echo "[DEBUG] Sudo-copied folder $1 inside $3"; }
  _grant_executable() { echo "[DEBUG] Granted permission to execute $1"; }
else
  _instl_pacman()     { sudo pacman --noconfirm --logfile ./log -S $@; }
  _instl_yay()        { yay --answerclean None --answerdiff None -S $@; }
  _enable_service()   { sudo systemctl enable $@; }
  _copy_config()      { cp -r "./config/$1" -t "$HOME/.config"; }
  _copy_sudo()        { sudo cp -r "$1" "$2"; }
  _grant_executable() { chmod +x "$1"; }
fi


# INTERNET
if [[ ! $_debug == "yes" ]]; then
  echo "Testing internet connection..."
  curl -D- -o /dev/null -s http://www.google.com > /dev/null
  if [[ $? == 0 ]]; then
    echo "Internet connected."
  else
    echo "Internet not connected! Please try again!"
    exit 1
  fi
fi


# MENU
echo " "
echo "Hello! This script will install the whole hyprland ecosystem along with configuration."
echo "If something goes wrong, look for the log file in the script's directory."
echo "If you aren't sure what software the script will install and whether you want it, please consult with the README"

read -p "Now, are you sure you want to continue? [y/n] " -n 1 -r
echo " "
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Script canceled."
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

read -p "Do you want to configure the script and additional packages? [y/n] " -n 1 -r
echo " "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  _instl_pacman "$_editor"
  if [[ "$_debug" == "yes" ]]; then
    printf "[DEBUG] Opened config file in $_editor.\n"
  else
    eval "$_editor config.ini"
  fi
fi

source <(grep = config.ini)


# SYSTEM UPDATE
echo "Performing system update..."
if [[ ! $_debug == "yes" ]]; then
  sudo pacman -Syu
else
  echo "[PACMAN] Updated System"
fi


# YAY
echo "Installing Yay..."
if [[ ! $_debug == "yes" ]]; then
  _instl_pacman git base-devel
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si
  cd ..
  sudo rm -rf yay
else
  echo "[DEBUG] Installed Yay"
fi


# GRAPHICAL SERVER
echo "Installing Wayland with Xorg compatibility..."
_instl_pacman wayland wlroots xorg-server xorg-xwayland


# DISPLAY MANAGER
echo "Installing Display Manager..."
_instl_pacman sddm
_enable_service sddm.service


# HYPRLAND
echo "Installing Desktop Environment..."
if [[ $nvidia == "yes" ]]; then
  hypr_pack=hyprland-nvidia-git
else
  hypr_pack=hyprland
fi
_instl_yay $hypr_pack waybar-hyprland-git swww-git grimshot
_instl_pacman alacritty wofi dunst polkit-kde-agent xdg-desktop-portal-hyprland cliphist hyprpicker


# AUDIO
echo "Installing Audio Server and utilities..."
_instl_yay pipewire-git pipewire-alsa-git pipewire-jack-git pipewire-pulse-git wireplumber-git
_instl_pacman qjackctl pavucontrol
_enable_service --user pipewire.service pipewire-pulse.service


# BLUETOOTH
if [[ $install_bluetooth_support == "yes" ]]; then
  echo "Installing Bluetooth support..."
  _instl_pacman bluez bluez-utils blueman
  _enable_service bluetooth.service
fi


# FONTS
echo "Installing fonts and emoji..."
_instl_yay ttf-twemoji ttf-jetbrains-mono-nerd


# ADDITIONALS
echo "Installing additional software..."
thunar_pack="thunar gvfs thunar-volman gvfs-mtp tumbler ffmpegthumbnailer webp-pixbuf-loader thunar-archive-plugin thunar-media-tags-plugin"
media_pack="viewnior gthumb vlc"
cli_pack="ranger htop alsa-utils"
gui_pack="firefox ark gparted nwg-look"
_instl_pacman $thunar_pack $media_pack $cli_pack $gui_pack


# STEAM
if [[ $_debug == "yes" ]]; then
  echo "[DEBUG] Installed Steam"
elif [[ $steam == "yes" ]]; then
  echo "Installing Steam..."
  # uncomments the multilib section in /etc/pacman.conf
  sudo sed -zi 's/#\s*\[multilib\]\n#\s*Include = /\[multilib\]\nInclude = /g' /etc/pacman.conf
  _instl_pacman steam

  # for FMOD to work with pipewire
  ln -s /bin/true pulseaudio
fi


# WEBCORD
if [[ $webcord == "yes" ]]; then
  _instl_yay webcord
fi


# FROM CONFIG
echo "Installing additional software from config..."
if [[ -z "$additional_pacman" ]]; then
  _instl_pacman "$additional_pacman"
fi
if [[ -z "$additional_yay" ]]; then
  _instl_yay "$additional_yay"
fi


# GTK THEME
if [[ $_debug == "yes" ]]; then
  echo "[DEBUG] Installed the GTK theme"
else
  echo "Installing a GTK theme..."
  mkdir "$HOME/.theme" "$HOME/.icons"

  # Global Theme
  git clone https://github.com/EliverLara/Kripton.git "$HOME/.theme"

  # Icon Theme
  mkdir temp
  git clone https://github.com/vinceliuice/Colloid-icon-theme temp/Colloid
  bash temp/Colloid/install.sh -d "$HOME/.icons"

  # Cursor
  git clone https://github.com/ful1e5/XCursor-pro.git temp/XCursor-Pro
  _instl_pacman yarn
  _instl_yay python-clickgen
  cd temp/XCursor-Pro && yarn build
  cp -r "themes/XCursor-Pro-Dark" -t "$HOME/.icons"
  cp -r themes/XCursor-Pro-Light -t "$HOME/.icons"
  cp -r themes/XCursor-Pro-Red -t "$HOME/.icons"
  cd ../..

  _copy_config gtk-3.0
  rm -rf temp
fi


# DOT FILES
echo "Copying configuration files..."
_copy_config alacritty
_copy_config eww
_copy_config hypr
_grant_executable "$HOME/.config/hypr/execute-script.sh"
_copy_config waybar
_copy_sudo ./wallpapers /usr/share
