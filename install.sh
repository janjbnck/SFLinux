#!/usr/bin/env bash
set -euo pipefail

user_dir="$HOME/.local/share/fonts/SFLinux"
system_dir="/usr/local/share/fonts/SFLinux"
user_conf_dir="${XDG_CONFIG_HOME:-$HOME/.config}/fontconfig/conf.d"
system_conf_dir="/etc/fonts/conf.d"
sudo=""
choice=""

case "${1:-}" in
    -u|--user) choice=1 ;;
    -s|--system) choice=2 ;;
    -h|--help) echo "Usage: install.sh [-u|--user] [-s|--system] [-h|--help]"; exit 0 ;;
    "") ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
esac

if [ -z "$choice" ]; then
    echo "1) Current user ($user_dir)"
    echo "2) System wide ($system_dir)"
    read -rp "Install for [1/2]: " choice
fi

case "$choice" in
    1) target="$user_dir"; conf_dir="$user_conf_dir" ;;
    2) target="$system_dir"; conf_dir="$system_conf_dir"; [ "$(id -u)" -eq 0 ] || sudo="sudo" ;;
    *) echo "Invalid choice" >&2; exit 1 ;;
esac

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl -fsSL https://github.com/janjbnck/SFLinux/archive/main.tar.gz | tar -xz -C "$tmp"
cat "$tmp"/*/Emoji/AppleColorEmoji.ttf.part* > "$tmp/AppleColorEmoji.ttf"

$sudo rm -rf "$target"
$sudo mkdir -p "$target"
find "$tmp" -type f \( -name '*.otf' -o -name '*.ttf' \) -exec $sudo install -m 644 -t "$target" {} +
$sudo mkdir -p "$conf_dir"
$sudo install -m 644 -t "$conf_dir" "$tmp"/*/Emoji/56-sflinux-emoji.conf
$sudo fc-cache -f

echo "Installed fonts to $target"
