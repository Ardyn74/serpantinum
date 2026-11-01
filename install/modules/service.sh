#!/usr/bin/env bash

detect_init_system() {
    echo "systemd"
}

enable_system_service() {
    local svc="$1"
    sudo systemctl enable --now "$svc.service" 2>/dev/null || sudo systemctl enable -f "$svc.service" 2>/dev/null || sudo systemctl enable "$svc.service" 2>/dev/null || true
}

disable_system_service() {
    local svc="$1"
    sudo systemctl disable --now "$svc.service" 2>/dev/null || sudo systemctl disable "$svc.service" 2>/dev/null || sudo systemctl disable "$svc" 2>/dev/null || true
}

enable_user_service() {
    local svc="$1"
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user enable --now "$svc.service" 2>/dev/null || systemctl --user enable "$svc.service" 2>/dev/null || true
}

setup_services() {
    local init_sys="systemd"

    systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null || true
    systemctl --user start pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null || true

    enable_system_service "NetworkManager" "$init_sys"
    enable_system_service "power-profiles-daemon" "$init_sys"
}
