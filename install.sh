#!/bin/bash

readonly _script_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
readonly _temp_dir="$_script_dir/temp"
readonly _help_page="HyprArch configuration install script.
\t-h - Display help page.
\t-d - Debug mode, won't install anything.
\t-e - Specify the config editor. Either nano (default) or vim.\n"

readonly _wht=$'\e[0m' _cyn=$'\e[1;36m' _grn=$'\e[1;32m' _mag=$'\e[1;35m' _yel=$'\e[1;33m' _red=$'\e[1;31m'  

_print_info()  { printf "%s\n" "${_cyn}[INFO]${_wht} $1"; }
_print_good()  { printf "%s\n" "${_grn}[GOOD]${_wht} $1"; }
_print_debug() { printf "%s\n" "${_mag}[DEBUG]${_wht} $1"; }
_print_warn()  { printf "%s\n" "${_yel}[WARNING]${_wht} $1"; }
_print_error() { printf "%s\n" "${_red}[ERROR]${_wht} $1"; }

# OPTIONS
while getopts ':hde:' OPTION; do
  case "$OPTION" in
    :)
    _print_error "Unrecognized parameter."
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
      _print_error "Choose either nano or vim as the editor."
      exit 1
    fi
    ;;
  esac
done


if [[ "$_debug" == "yes" ]]; then
  _instl_pacman()     { _print_debug "Pacman installed $@."; }
  _instl_yay()        { _print_debug "Yay installed $@."; }
  _enable_service()   { _print_debug "Systemd enabled $@."; }
  _copy_config()      { _print_debug "Copied config from folder $1."; }
  _copy_sudo()        { _print_debug "Sudo-copied folder $1 inside $3."; }
  _grant_executable() { _print_debug "Granted permission to execute $1."; }
else
  _instl_pacman()     { sudo pacman --noconfirm --logfile ./log -S $@; }
  _instl_yay()        { yay --answerclean None --answerdiff None -S $@; }
  _enable_service()   { sudo systemctl enable $@; }
  _copy_config()      { cp -r "$_script_dir/config/$1" -t "$HOME/.config"; }
  _copy_sudo()        { sudo cp -r "$1" "$2"; }
  _grant_executable() { chmod +x "$1"; }
fi


# INTERNET
if [[ ! $_debug == "yes" ]]; then
  _print_info "Testing internet connection..."
  curl -D- -o /dev/null -s http://www.google.com > /dev/null
  if [[ $? == 0 ]]; then
    _print_good "Internet connected."
  else
    _print_error "Internet not connected! Please try again!"
    exit 1
  fi
fi


# MENU
_menu_print="Hello! This script will install the whole hyprland ecosystem along with configuration.
If something goes wrong, look for the log file in the script's directory.
If you aren't sure what software the script will install and whether you want it, please consult with the README"
printf "$_menu_print\n"

read -p "Now, are you sure you want to continue? [y/n] " -n 1 -r
printf "\n"
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  printf "Script canceled.\n"
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

read -p "Do you want to configure the script and additional packages? [y/n] " -n 1 -r
printf "\n"
if [[ $REPLY =~ ^[Yy]$ ]]; then
  _instl_pacman "$_editor"
  if [[ "$_debug" == "yes" ]]; then
    _print_debug "Opened config file in $_editor."
  else
    eval "$_editor $_script_dir/config.ini"
  fi
fi

source <(grep = "$_script_dir/config.ini")

mkdir "$_temp_dir"

# SYSTEM UPDATE
_print_info "Performing system update..."
if [[ ! $_debug == "yes" ]]; then
  sudo pacman -Syu
else
  _print_debug "Pacman updated the system."
fi


# YAY
_print_info "Installing Yay..."
if [[ ! $_debug == "yes" ]]; then
  _instl_pacman git base-devel
  git clone https://aur.archlinux.org/yay.git "$_temp_dir/yay"
  cd "$_temp_dir/yay"
  makepkg -si
  cd "$_script_dir"
else
  _print_debug "Installed Yay."
fi


# GRAPHICAL SERVER
_print_info "Installing Wayland with Xorg compatibility..."
_instl_pacman wayland wlroots xorg-server xorg-xwayland


# DISPLAY MANAGER
_print_info "Installing Display Manager..."
_instl_pacman sddm
_enable_service sddm.service
_instl_pacman gst-libav phonon-qt5-gstreamer gst-plugins-good qt5-quickcontrols qt5-graphicaleffects qt5-multimedia


# HYPRLAND
_print_info "Installing Desktop Environment..."
if [[ $nvidia == "yes" ]]; then
  hypr_pack=hyprland-nvidia-git
else
  hypr_pack=hyprland
fi
_instl_yay $hypr_pack waybar-hyprland-git swww-git grimshot
_instl_pacman alacrit  rm -rf tempty wofi dunst polkit-kde-agent xdg-desktop-portal-hyprland cliphist hyprpicker


# AUDIO
_print_info "Installing Audio Server and utilities..."
_instl_yay pipewire-git pipewire-alsa-git pipewire-jack-git pipewire-pulse-git wireplumber-git
_instl_pacman qjackctl pavucontrol
_enable_service --user pipewire.service pipewire-pulse.service


# BLUETOOTH
if [[ $install_bluetooth_support == "yes" ]]; then
  _print_info "Installing Bluetooth support..."
  _instl_pacman bluez bluez-utils blueman
  _enable_service bluetooth.service
fi


# FONTS
_print_info "Installing fonts and emoji..."
_instl_yay ttf-twemoji ttf-jetbrains-mono-nerd


# ADDITIONALS
_print_info "Installing additional software..."
thunar_pack="thunar gvfs thunar-volman gvfs-mtp tumbler ffmpegthumbnailer webp-pixbuf-loader thunar-archive-plugin thunar-media-tags-plugin"
media_pack="viewnior gthumb vlc"
cli_pack="ranger htop alsa-utils"
gui_pack="firefox ark gparted nwg-look"
_instl_pacman $thunar_pack $media_pack $cli_pack $gui_pack

power_management="laptop-mode-tools auto-cpufreq"
_instl_yay $power_management


# STEAM
if [[ $_debug == "yes" ]]; then
  _print_debug "Installed Steam."
elif [[ $steam == "yes" ]]; then
  _print_info "Installing Steam..."
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
_print_info "Installing additional software from config..."
if [[ -z "$additional_pacman" ]]; then
  _instl_pacman "$additional_pacman"
fi
if [[ -z "$additional_yay" ]]; then
  _instl_yay "$additional_yay"
fi


# GTK THEME
if [[ $_debug == "yes" ]]; then
  _print_debug "Installed the GTK theme."
else
  _print_info "Installing a GTK theme..."
  mkdir "$HOME/.theme" "$HOME/.icons"

  # Global Theme
  git clone https://github.com/EliverLara/Kripton.git "$HOME/.theme"

  # Icon Theme
  mkdir temp
  git clone https://github.com/vinceliuice/Colloid-icon-theme "$_temp_dir/Colloid"
  bash temp/Colloid/install.sh -d "$HOME/.icons"

  # Cursor
  git clone https://github.com/ful1e5/XCursor-pro.git "$_temp_dir/XCursor-Pro"
  _instl_pacman yarn
  _instl_yay python-clickgen

  cd "$_temp_dir/XCursor-Pro" && yarn build
  cp -r "$_temp_dir/XCursor-Pro/themes/XCursor-Pro-Dark" -t "$HOME/.icons"
  cp -r "$_temp_dir/XCursor-Pro/themes/XCursor-Pro-Light" -t "$HOME/.icons"
  cp -r "$_temp_dir/XCursor-Pro/themes/XCursor-Pro-Red" -t "$HOME/.icons"
  cd "$_scipt_dir"

  _copy_config gtk-3.0
fi

# SDDM THEME
if [[ $_debug == "yes" ]]; then
  _print_debug "Installed the SDDM theme."
else
  _print_info "Installing the SDDM theme..."

  sudo git clone git@github.com:3ximus/aerial-sddm-theme.git /usr/share/sddm/themes
  sudo mkdir /etc/sddm.conf.d

  sudo cp $_script_dir/config/sddm/ /usr/lib/sddm/sddm.conf.d/default.conf /etc/sddm.conf.d/conf.conf
fi


# DOT FILES
_print_info "Copying configuration files..."
_copy_config alacritty
_copy_config eww
_copy_config hypr
_grant_executable "$HOME/.config/hypr/execute-script.sh"
_copy_config waybar
_copy_sudo "$_script_dir/wallpapers" /usr/share

_copy_sudo "$_script_dir/" /etc/sddm.conf.d

_print_good "Installation successful."
