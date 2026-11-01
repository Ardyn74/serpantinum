#!/usr/bin/env bash

PM_MODULES_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/pm"

detect_package_manager() {
    if command -v pacman &>/dev/null; then
        echo "pacman"
    else
        echo "Error: Only Arch Linux and CachyOS (pacman) are supported." >&2
        exit 1
    fi
}

PM_NAME="pacman"

PM_EXTRA_PKGS=()
PM_SDDM_EXTRA_PKGS=()
PM_SDDM_WAYLAND_DEFAULT=false
PM_SDDM_CURSOR_FIX=false
PM_AUDIO_BUILD_PKGS=()

source "$PM_MODULES_DIR/pacman.sh"
