#!/usr/bin/env bash
#
# Installs the SFLinux fonts for the current user or system wide.
#
# Usage:
#   ./install.sh            interactive, asks for the install scope
#   ./install.sh --user     install to ~/.local/share/fonts/SFLinux
#   ./install.sh --system   install to /usr/local/share/fonts/SFLinux
#
# When the script is not run from a clone of the repository, the fonts are
# downloaded from GitHub. Set SFLINUX_REF to install from another branch or tag.

set -euo pipefail

REPO="janjbnck/SFLinux"
REF="${SFLINUX_REF:-main}"
FONT_DIR_NAME="SFLinux"
USER_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/$FONT_DIR_NAME"
SYSTEM_DIR="/usr/local/share/fonts/$FONT_DIR_NAME"

info() { printf '\033[1;34m::\033[0m %s\n' "$*"; }
error() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
    sed -n '3,12p' "${BASH_SOURCE[0]:-}" 2>/dev/null | sed 's/^# \{0,1\}//' ||
        echo "Usage: install.sh [--user | --system]"
}

scope=""
while [ $# -gt 0 ]; do
    case "$1" in
        -u|--user) scope="user" ;;
        -s|--system) scope="system" ;;
        -h|--help) usage; exit 0 ;;
        *) error "unknown option: $1 (see --help)" ;;
    esac
    shift
done

# Ask for the scope. Reads from /dev/tty so it also works with "curl | bash".
if [ -z "$scope" ]; then
    if ! { : </dev/tty; } 2>/dev/null; then
        error "no terminal available, pass --user or --system"
    fi
    echo "Where should the fonts be installed?"
    echo "  1) Current user only ($USER_DIR)"
    echo "  2) System wide ($SYSTEM_DIR, requires root)"
    while [ -z "$scope" ]; do
        printf 'Choose [1/2]: '
        read -r answer </dev/tty
        case "$answer" in
            1|u|user) scope="user" ;;
            2|s|system) scope="system" ;;
            *) echo "Please enter 1 or 2." ;;
        esac
    done
fi

# Run privileged commands with sudo when installing system wide as non-root.
SUDO=""
if [ "$scope" = "system" ]; then
    TARGET="$SYSTEM_DIR"
    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 || error "sudo is required for a system wide install"
        SUDO="sudo"
    fi
else
    TARGET="$USER_DIR"
fi

# Use the local checkout if the script lives next to the font folders,
# otherwise download the repository archive.
SRC=""
script_path="${BASH_SOURCE[0]:-}"
if [ -n "$script_path" ] && [ -f "$script_path" ]; then
    script_dir="$(cd "$(dirname "$script_path")" && pwd)"
    if [ -d "$script_dir/SF Pro" ]; then
        SRC="$script_dir"
    fi
fi

if [ -z "$SRC" ]; then
    TMP="$(mktemp -d)"
    trap 'rm -rf "$TMP"' EXIT
    url="https://github.com/$REPO/archive/$REF.tar.gz"
    info "Downloading fonts from $url"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" | tar -xz -C "$TMP" --strip-components=1
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- "$url" | tar -xz -C "$TMP" --strip-components=1
    else
        error "curl or wget is required to download the fonts"
    fi
    SRC="$TMP"
fi

# Remove an older installation so renamed or deleted fonts do not linger.
if [ -d "$TARGET" ]; then
    info "Removing previous installation in $TARGET"
    $SUDO rm -rf "$TARGET"
fi

info "Installing fonts to $TARGET"
count=0
while IFS= read -r -d '' file; do
    rel="${file#"$SRC"/}"
    dest="$TARGET/$rel"
    $SUDO mkdir -p "$(dirname "$dest")"
    $SUDO install -m 644 "$file" "$dest"
    count=$((count + 1))
done < <(find "$SRC" -path "$SRC/.git" -prune -o -type f \( -iname '*.otf' -o -iname '*.ttf' \) -print0)

[ "$count" -gt 0 ] || error "no font files found in $SRC"
$SUDO find "$TARGET" -type d -exec chmod 755 {} +

if command -v fc-cache >/dev/null 2>&1; then
    info "Updating font cache"
    $SUDO fc-cache -f "$TARGET" >/dev/null
else
    info "fc-cache not found, log out and back in if the fonts do not show up"
fi

info "Installed $count font files to $TARGET"
