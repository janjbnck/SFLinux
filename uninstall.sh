#!/usr/bin/env bash
set -euo pipefail

user_dir="$HOME/.local/share/fonts/SFLinux"
system_dir="/usr/local/share/fonts/SFLinux"
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

$sudo fc-cache -f
