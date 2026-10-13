#!/usr/bin/env bash

PM_BOOTSTRAP_TOOLS=(fzf jq curl git pciutils unzip fontconfig)

declare -A PM_PKG_MAP=(
    [kitty]="kitty"
    [cava]="cava"
    [zbar]="zbar"
    [pavucontrol]="pavucontrol"
    [alsa-utils]="alsa-utils"
    [wl-clipboard]="wl-clipboard"
    [fd]="fd-find"
    [qt6-multimedia]="qt6-qtmultimedia"
    [qt6-5compat]="qt6-qt5compat"
    [ripgrep]="ripgrep"
    [cliphist]="cliphist"
    [jq]="jq"
    [socat]="socat"
    [inotify-tools]="inotify-tools"
    [pamixer]="pamixer"
    [brightnessctl]="brightnessctl"
    [ddcutil]="ddcutil"
    [acpi]="acpi"
    [iw]="iw"
    [bluez]="bluez"
    [bluez-utils]="bluez"
    [libnotify]="libnotify"
    [networkmanager]="NetworkManager"
    [lm_sensors]="lm_sensors"
    [bc]="bc"
    [matugen]="matugen"
    [pipewire]="pipewire"
    [wireplumber]="wireplumber"
    [pipewire-pulse]="pipewire-pulseaudio"
    [pipewire-alsa]="pipewire-alsa"
    [libpulse]="pulseaudio-libs"
    [python]="python3"
    [imagemagick]="ImageMagick"
    [wget]="wget"
    [file]="file"
    [git]="git"
    [psmisc]="psmisc"
    [ffmpeg]="ffmpeg-free|ffmpeg"
    [fastfetch]="fastfetch"
    [quickshell]="quickshell"
    [unzip]="unzip"
    [python-websockets]="python3-websockets"
    [python-jeepney]="python3-jeepney"
    [qt6-websockets]="qt6-qtwebsockets"
    [grim]="grim"
    [playerctl]="playerctl"
    [satty]="satty"
    [xdg-desktop-portal-gtk]="xdg-desktop-portal-gtk"
    [slurp]="slurp"
    [wmctrl]="wmctrl"
    [power-profiles-daemon]="power-profiles-daemon"
    [easyeffects]="easyeffects"
    [lsp-plugins-lv2]="lsp-plugins-lv2"
    [nautilus]="nautilus"
    [qt5-wayland]="qt5-qtwayland"
    [qt5-quickcontrols]="qt5-qtquickcontrols"
    [qt5-quickcontrols2]="qt5-qtquickcontrols2"
    [qt5-graphicaleffects]="qt5-qtgraphicaleffects"
    [qt6-wayland]="qt6-qtwayland"
    [qt5ct]="qt5ct"
    [qt6ct]="qt6ct"
    [adwaita-icon-theme]="adwaita-icon-theme"
    [gpu-screen-recorder]="gpu-screen-recorder"
    [wf-recorder]="wf-recorder"
    [adw-gtk-theme]="adw-gtk3-theme"
    [wl-gammarelay-rs]="wl-gammarelay-rs"
    [hyprland]="hyprland"
    [niri]="niri"
    [sway]="sway"
    [sddm]="sddm"
    [qt6-declarative]="qt6-qtdeclarative"
    [qt6-svg]="qt6-qtsvg"
)

declare -A PM_COPR_MAP=(
    [quickshell]="errornointernet/quickshell"
    [hyprland]="mineiro/hyprland"
    [satty]="mineiro/hyprland"
    [cliphist]="mecattaf/duoRPM"
    [matugen]="mecattaf/duoRPM"
    [wl-gammarelay-rs]="mecattaf/duoRPM"
    [gpu-screen-recorder]="arabianq/gpu-screen-recorder"
)

pm_prepare_repos() {
    true
}

pm_bootstrap_install() {
    sudo dnf install -y "$@"
}

pm_bootstrap_helper() {
    true
}

pm_full_upgrade() {
    sudo dnf makecache --refresh >/dev/null 2>&1 || true
}

pm_resolve_name() {
    echo "${PM_PKG_MAP[$1]:-$1}"
}

pm_missing_pkgs() {
    local pkg spec alt satisfied
    for pkg in "$@"; do
        spec="$(pm_resolve_name "$pkg")"
        satisfied=false
        while IFS= read -r alt; do
            if rpm -q --whatprovides "$alt" &>/dev/null; then
                satisfied=true
                break
            fi
        done < <(tr '|' '\n' <<< "$spec")
        [ "$satisfied" = true ] || echo "$pkg"
    done
}

pm_is_installed() {
    rpm -q "$1" &>/dev/null
}

pm_enable_copr() {
    local repo="$1"
    echo -e "\e[36m[ INFO ]\e[0m $(t "installer.deps.enabling_copr" "repo=$repo")"
    if ! dnf copr --help &>/dev/null; then
        if command -v dnf5 &>/dev/null; then
            sudo dnf install -y dnf5-plugins || return 1
        else
            sudo dnf install -y dnf-plugins-core || return 1
        fi
    fi
    sudo dnf copr enable -y "$repo"
}

pm_install_pkg() {
    local pkg="$1"
    local spec target
    spec="$(pm_resolve_name "$pkg")"
    target="${spec%%|*}"

    if [ -z "$(dnf repoquery --available --quiet "$target" 2>/dev/null | head -n 1)" ]; then
        local copr="${PM_COPR_MAP[$pkg]:-}"
        if [ -n "$copr" ]; then
            pm_enable_copr "$copr" || return 1
        fi
    fi

    sudo dnf install -y "$target"
}

pm_remove_pkg() {
    true
}

pm_remove_conflicting_pkg() {
    true
}
