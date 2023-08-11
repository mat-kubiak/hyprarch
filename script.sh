#!/bin/bash

_instl_pacman() {
  if [[ "$_debug" == "yes" ]]; then
    echo "[PACMAN] Installed $@"
  else
    sudo pacman --noconfirm --logfile ./log -S $@
  fi
}

_instl_yay() {
  if [[ "$_debug" == "yes" ]]; then
    echo "[YAY] Installed $@"
  else
    yay --answerclean None --answerdiff None -S $@
  fi
}

_enable_service() {
  if [[ "$_debug" == "yes" ]]; then
    echo "[SYSTEMCTL] Enabled $@"
  else
    sudo systemctl enable $@
  fi
}

_copy_files() {
  if [[ "$_debug" == "yes" ]]; then
    echo "[DEBUG] Copied files from $1 to $2"
  else
    sudo cp -r "$1" "$2"
    sudo chmod -R +w "$2"
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
thunar_pack="thunar gvfs thunar-volman gvfs-mtp tumbler ffmpegthumbnailer"
media_pack="viewnior vlc"
cli_pack="ranger htop alsa-utils vim neovim"
gui_pack="firefox ark gparted"
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


# DOT FILES
echo "Copying configuration files..."
_copy_files ./config/alacritty ~/.config/alacritty
_copy_files ./config/eww       ~/.config/eww
_copy_files ./config/hypr      ~/.config/hypr
_copy_files ./config/waybar    ~/.config/waybar
_copy_files ./wallpapers       /usr/share/wallpapers
