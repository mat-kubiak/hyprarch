#!/bin/bash

echo "Hello! This script will install the whole hyprland ecosystem along with configuration."
echo "If you aren't sure what software it will install and whether you want it, please consult with the README"
# echo "Now, are you sure you want to continue? [y/n]"


# INTERNET CONNECTION
echo "Testing internet connection..."
curl -D- -o /dev/null -s http://www.google.com > /dev/null
if [[ $? == 0 ]]; then
  echo "Internet connected."
else
  echo "Internet not connected! Please try again!"
  exit 1
fi


# SYSTEM UPDATE
echo "Performing system update..."
sudo pacman -Syu


# YAY
echo "Installing Yay..."
sudo pacman -S git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
sudo rm -rf yay


# DISPLAY MANAGER
echo "Installing Display Manager..."
yay -S sddm-git


# WAYLAND
echo "Installing Wayland..."
sudo pacman -S wayland wlroots


# HYPRLAND
echo "Installing Desktop Environment..."
yay -S hyprland-git waybar-hyprland-git swww-git
sudo pacman -S wofi # couldn't find on aur
sudo pacman -S alacritty
# maybe add eww-wayland-git


# AUDIO
echo "Installing Audio Server and utilities..."
yay -S pipewire-git  pipewire-alsa-git pipewire-jack-git pipewire-pulse-git
yay -S wireplumber-git qjackctl-git pavucontrol-git


# FONTS
echo "Installing fonts and emoji..."
yay -S ttf-twemoji


# COLOR PICKER
echo "Installing color picker..."
sudo pacman -S hyprpicker wl-copy


# ADDITIONALS
echo "Installing additional software..."
sudo pacman -S thunar gvfs thunar-volman gvfs-mtp tumbler ffmpegthumbnailer # thunar
sudo pacman -S viewnior vlc # media viewers
sudo pacman -S ranger vim neovim # cli
sudo pacman -S firefox ark gparted keepassxc qbittorrent # other
# yay -S joplin-desktop anki


# STEAM
# echo "Installing steam ..."


# LIBRE OFFICE
# echo "Installing libre office"
# sudo pacman -S libreoffice

# DOT FILES
echo "Copying dotfiles..."
cp -r ./alacritty ~/.config/alacritty
cp -r ./eww ~/.config/eww
cp -r ./hypr ~/.config/hypr
cp -r ./waybar ~/.config/waybar
sudo cp -r ./wallpapers /usr/share/wallpapers