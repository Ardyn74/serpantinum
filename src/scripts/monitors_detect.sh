#!/usr/bin/env bash

# Monitor Detection - Specialized for Niri on CachyOS / Arch Linux
VERBOSE=0
if [[ "${1:-}" == "--verbose" ]]; then
    VERBOSE=1
fi

detect_niri() {
    command -v niri &>/dev/null || return 1
    local out=""
    if [ "$VERBOSE" -eq 1 ]; then
        if command -v jq &>/dev/null; then
            out=$(niri msg --json outputs 2>/dev/null | jq -r 'to_entries[]? | .value | (if (.current_mode | type) == "number" then .modes[.current_mode] else .current_mode end) as $m | select($m != null) | "\(.name)|\($m.width)x\($m.height)|\((($m.refresh_rate // 60000) / 1000 * 100 | round) / 100)"' 2>/dev/null)
        fi
        if [ -z "$out" ]; then
            out=$(niri msg outputs 2>/dev/null | awk '/^Output /{match($0, /\(([^)]+)\)$/, m); name=m[1]} /Current mode:/{match($0, /([0-9]+x[0-9]+)[[:space:]]*@[[:space:]]*([0-9.]+)/, a); if (name && a[1]) { printf "%s|%s|%.2f\n", name, a[1], a[2]; name="" }}')
        fi
    else
        if command -v jq &>/dev/null; then
            out=$(niri msg --json outputs 2>/dev/null | jq -r 'keys[]?, .[].name?' 2>/dev/null | grep -v '^null$' | awk '!seen[$0]++ && NF')
        fi
        if [ -z "$out" ]; then
            out=$(niri msg outputs 2>/dev/null | awk '/^Output /{match($0, /\(([^)]+)\)$/, m); if (m[1]) print m[1]}')
        fi
    fi
    if [ -n "$out" ]; then
        echo "$out"
        return 0
    fi
    return 1
}

detect_wlrrandr() {
    command -v wlr-randr &>/dev/null || return 1
    local out=""
    if [ "$VERBOSE" -eq 1 ]; then
        out=$(wlr-randr 2>/dev/null | awk '/^[a-zA-Z0-9-]+ /{name=$1} /current/{dim=""; fps="60.00"; for(i=1;i<=NF;i++){if($i~/^[0-9]+x[0-9]+$/) dim=$i; if($(i+1)=="Hz") fps=$i}; if(name!="" && dim!=""){printf "%s|%s|%.2f\n", name, dim, fps; name=""}}')
    else
        out=$(wlr-randr 2>/dev/null | awk '/^[a-zA-Z0-9-]+ /{print $1}')
    fi
    if [ -n "$out" ]; then
        echo "$out"
        return 0
    fi
    return 1
}

detect_sysfs() {
    local found=0
    for status in /sys/class/drm/card*-*/status; do
        if [ -f "$status" ] && [ "$(cat "$status")" = "connected" ]; then
            dev=$(dirname "$status")
            name=$(basename "$dev")
            name="${name#card*-}"
            if [ "$VERBOSE" -eq 1 ]; then
                if [ -f "$dev/modes" ]; then
                    mode=$(head -n 1 "$dev/modes")
                    echo "$name|$mode|60.00"
                else
                    echo "$name|Unknown|60.00"
                fi
            else
                echo "$name"
            fi
            found=1
        fi
    done
    [ "$found" -eq 1 ] && return 0
    return 1
}

detect_niri && exit 0
detect_wlrrandr && exit 0
detect_sysfs && exit 0
