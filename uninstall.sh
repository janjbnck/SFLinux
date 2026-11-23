#!/usr/bin/env bash
#
# Removes the SFLinux fonts installed by install.sh.
#
# Looks for the font folder in the user and system font directories and
# deletes every installation it finds. Root access is requested via sudo
# only when a system wide installation exists.

set -euo pipefail

FONT_DIR_NAME="SFLinux"
CANDIDATES=(
    "${XDG_DATA_HOME:-$HOME/.local/share}/fonts/$FONT_DIR_NAME"
    "$HOME/.fonts/$FONT_DIR_NAME"
    "/usr/local/share/fonts/$FONT_DIR_NAME"
    "/usr/share/fonts/$FONT_DIR_NAME"
)

info() { printf '\033[1;34m::\033[0m %s\n' "$*"; }
error() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

found=()
for dir in "${CANDIDATES[@]}"; do
    [ -d "$dir" ] && found+=("$dir")
done

if [ "${#found[@]}" -eq 0 ]; then
    info "No SFLinux fonts found, nothing to remove"
    exit 0
fi

for dir in "${found[@]}"; do
    SUDO=""
    if [ ! -w "$(dirname "$dir")" ] && [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 || error "sudo is required to remove $dir"
        SUDO="sudo"
    fi
    info "Removing $dir"
    $SUDO rm -rf "$dir"
    if command -v fc-cache >/dev/null 2>&1; then
        $SUDO fc-cache -f "$(dirname "$dir")" >/dev/null 2>&1 || true
    fi
done

info "SFLinux fonts removed"
