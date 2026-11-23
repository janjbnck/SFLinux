#!/usr/bin/env bash
set -euo pipefail

user_dir="$HOME/.local/share/fonts/SFLinux"
system_dir="/usr/local/share/fonts/SFLinux"
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
    1) target="$user_dir" ;;
    2) target="$system_dir"; [ "$(id -u)" -eq 0 ] || sudo="sudo" ;;
    *) echo "Invalid choice" >&2; exit 1 ;;
esac

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl -fsSL https://github.com/janjbnck/SFLinux/archive/main.tar.gz | tar -xz -C "$tmp"

$sudo rm -rf "$target"
$sudo mkdir -p "$target"
find "$tmp" -type f \( -name '*.otf' -o -name '*.ttf' \) -exec $sudo install -m 644 -t "$target" {} +
$sudo fc-cache -f

echo "Installed fonts to $target"
