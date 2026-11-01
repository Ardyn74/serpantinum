#!/usr/bin/env bash

if [ -z "${SERPANTINUM_DIR:-}" ]; then
    SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
    export SERPANTINUM_DIR="$(dirname "$SCRIPT_DIR")"
fi

export QS_DIR="$SERPANTINUM_DIR/quickshell"
export MAIN_QML="${MAIN_QML:-$QS_DIR/Shell.qml}"
export IPC_SOCKET="${XDG_RUNTIME_DIR:-/tmp}/serpantinum.sock"

export QS_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/serpantinum"
export QS_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/serpantinum"
export QS_RUN_DIR="${XDG_RUNTIME_DIR:-/tmp}/serpantinum"
export QS_LOG_DIR="$QS_RUN_DIR/logs"
export QS_SETTINGS="${XDG_CONFIG_HOME:-$HOME/.config}/serpantinum/settings.json"

[[ -d "$QS_LOG_DIR" && -d "$QS_CACHE_DIR" && -d "$QS_STATE_DIR" ]] || mkdir -p "$QS_CACHE_DIR" "$QS_STATE_DIR" "$QS_RUN_DIR" "$QS_LOG_DIR"

qs_ensure_cache() {
    local WIDGET_NAME="$1"
    
    local WIDGET_UPPER="${WIDGET_NAME^^}"
    
    local WIDGET_CACHE="$QS_CACHE_DIR/$WIDGET_NAME"
    local WIDGET_STATE="$QS_STATE_DIR/$WIDGET_NAME"
    local WIDGET_RUN="$QS_RUN_DIR/$WIDGET_NAME"
    
    [[ -d "$WIDGET_RUN" && -d "$WIDGET_STATE" && -d "$WIDGET_CACHE" ]] || mkdir -p "$WIDGET_CACHE" "$WIDGET_STATE" "$WIDGET_RUN"
    
    export "QS_CACHE_${WIDGET_UPPER}=$WIDGET_CACHE"
    export "QS_STATE_${WIDGET_UPPER}=$WIDGET_STATE"
    export "QS_RUN_${WIDGET_UPPER}=$WIDGET_RUN"
}

qs_ensure_cache "focustime"
qs_ensure_cache "quickactions"
qs_ensure_cache "network"
qs_ensure_cache "wallpaper"
qs_ensure_cache "clipboard"
qs_ensure_cache "music"
qs_ensure_cache "screenshot"

if [ -z "${SERPANTINUM_INSTALLER:-}" ] && [ ! -f "$QS_STATE_DIR/version" ]; then
    ver=""
    if [ -f "$SERPANTINUM_DIR/version.txt" ]; then
        ver="$(cat "$SERPANTINUM_DIR/version.txt" 2>/dev/null | xargs)"
    elif [ -f "$(dirname "$SERPANTINUM_DIR")/version.txt" ]; then
        ver="$(cat "$(dirname "$SERPANTINUM_DIR")/version.txt" 2>/dev/null | xargs)"
    fi
    [ -z "$ver" ] && ver="${SERPANTINUM_VERSION:-2.0.0}"
    echo "SERPANTINUM_VERSION=\"$ver\"" > "$QS_STATE_DIR/version"
fi

[ -f "$QS_STATE_DIR/quickactions/palettes.json" ] || echo "[]" > "$QS_STATE_DIR/quickactions/palettes.json"
