#!/bin/bash

instl_pacman() {
  if [[ "$_debug" == "yes" ]]; then
    echo "[PACMAN] Installed $@"
  else
    echo "lol"
    # sudo pacman --noconfirm --logfile ./log -S $@
  fi
}

instl_yay() {
  if [[ "$_debug" == "yes" ]]; then
    echo "[YAY] Installed $@"
  else
    echo "lol"
    # yay --answerclean None --answerdiff None -S $@
  fi
}

enable_service() {
  if [[ "$_debug" == "yes" ]]; then
    echo "[SYSTEMCTL] Enabled $@"
  else
    echo "lol"
    # sudo systemctl enable $@
  fi
}


# OPTIONS
while getopts 'hd' OPTION; do
  case "$OPTION" in
    h)
    echo "HyprArch configuration install script"
    echo " -h - display help page"
    echo " -d - debug mode, won't install anything"
    exit 0
    ;;
    d)
    _debug=yes
    ;;
  esac
done


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
  nano ./config.ini
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
  instl_pacman git base-devel
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
instl_pacman wayland wlroots xorg-server xorg-xwayland


# DISPLAY MANAGER
echo "Installing Display Manager..."
instl_pacman sddm
enable_service sddm.service


# HYPRLAND
echo "Installing Desktop Environment..."
if [[ $nvidia == "yes" ]]; then
  hypr_pack=hyprland-nvidia-git
else
  hypr_pack=hyprland
fi
instl_yay $hypr_pack waybar-hyprland-git swww-git grimshot
instl_pacman alacritty wofi dunst polkit-kde-agent xdg-desktop-portal-hyprland cliphist hyprpicker


# AUDIO
echo "Installing Audio Server and utilities..."
instl_yay pipewire-git pipewire-alsa-git pipewire-jack-git pipewire-pulse-git wireplumber-git
instl_pacman qjackctl pavucontrol
enable_service --user pipewire.service pipewire-pulse.service


# FONTS
echo "Installing fonts and emoji..."
instl_yay ttf-twemoji ttf-jetbrains-mono-nerd


# ADDITIONALS
echo "Installing additional software..."
thunar_pack="thunar gvfs thunar-volman gvfs-mtp tumbler ffmpegthumbnailer"
media_pack="viewnior vlc"
cli_pack="ranger htop alsa-utils vim neovim"
gui_pack="firefox ark gparted"
instl_pacman $thunar_pack $media_pack $cli_pack $gui_pack


# DOT FILES
echo "Copying configuration files..."
if [[ ! $_debug == "yes" ]]; then
  cp -r ./config/alacritty ~/.config/alacritty
  cp -r ./config/eww ~/.config/eww
  cp -r ./config/hypr ~/.config/hypr
  cp -r ./config/waybar ~/.config/waybar
  sudo cp -r ./wallpapers /usr/share/wallpapers
else
  echo "[DEBUG] Copied Configuration Files"
fi
