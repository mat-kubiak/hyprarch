#!/bin/bash

instl_pacman() {
  sudo pacman --noconfirm --logfile ./log -S $@
}

instl_yay() {
  yay --answerclean None --answerdiff None -S $@
}

echo "Testing internet connection..."
curl -D- -o /dev/null -s http://www.google.com > /dev/null
if [[ $? == 0 ]]; then
  echo "Internet connected."
else
  echo "Internet not connected! Please try again!"
  exit 1
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
  nano ./config.sh
fi


# SYSTEM UPDATE
echo "Performing system update..."
sudo pacman -Syu


# YAY
echo "Installing Yay..."
instl_pacman git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
sudo rm -rf yay


# GRAPHICAL SERVER
echo "Installing Wayland with Xorg compatibility..."
instl_pacman wayland wlroots xorg-server xorg-xwayland


# DISPLAY MANAGER
echo "Installing Display Manager..."
instl_pacman sddm
sudo systemctl enable sddm.service


# HYPRLAND
echo "Installing Desktop Environment..."
read -p "Do you have an NVIDIA card? [y/n] " -n 1 -r
hypr_pack=hyprland
echo " "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  hypr_pack=hyprland-nvidia-git
fi

instl_yay $hypr_pack waybar-hyprland-git swww-git grimshot
instl_pacman alacritty wofi dunst polkit-kde-agent xdg-desktop-portal-hyprland cliphist hyprpicker


# AUDIO
echo "Installing Audio Server and utilities..."
instl_yay pipewire-git pipewire-alsa-git pipewire-jack-git pipewire-pulse-git wireplumber-git
instl_pacman qjackctl pavucontrol
systemctl enable --user pipewire.service pipewire-pulse.service


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
bash ./config.sh


# DOT FILES
echo "Copying dotfiles..."
cp -r ./config/alacritty ~/.config/alacritty
cp -r ./config/eww ~/.config/eww
cp -r ./config/hypr ~/.config/hypr
cp -r ./config/waybar ~/.config/waybar
sudo cp -r ./wallpapers /usr/share/wallpapers
