#!/usr/bin/env bash
set -euo pipefail

user_dir="$HOME/.local/share/fonts/SFLinux"
system_dir="/usr/local/share/fonts/SFLinux"
user_conf="${XDG_CONFIG_HOME:-$HOME/.config}/fontconfig/conf.d/56-sflinux-emoji.conf"
system_conf="/etc/fonts/conf.d/56-sflinux-emoji.conf"
sudo=""
[ "$(id -u)" -eq 0 ] || sudo="sudo"

if [ -d "$user_dir" ]; then
    rm -rf "$user_dir"
    echo "Removed $user_dir"
fi

if [ -d "$system_dir" ]; then
    $sudo rm -rf "$system_dir"
    echo "Removed $system_dir"
fi

if [ -f "$user_conf" ]; then
    rm -f "$user_conf"
    echo "Removed $user_conf"
fi

if [ -f "$system_conf" ]; then
    $sudo rm -f "$system_conf"
    echo "Removed $system_conf"
fi

$sudo fc-cache -f
