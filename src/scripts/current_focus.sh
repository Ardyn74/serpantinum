#!/usr/bin/env bash

# Focus Tracker - Specialized for Niri on CachyOS / Arch Linux
source "$(dirname "${BASH_SOURCE[0]}")/caching.sh"

STATE_FILE="$QS_RUN_DIR/current_focus.json"
LOCK_FILE="$QS_RUN_DIR/current_focus.lock"
LOG_FILE="$QS_RUN_DIR/current_focus.log"

exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    exit 0
fi

log_append_count=0

cleanup() {
    flock -u 200 2>/dev/null
    rm -f "$LOCK_FILE"
    exit 0
}
trap cleanup EXIT SIGTERM SIGINT

cls=""
title=""
active_niri_id=""

get_active_window() {
    local data raw cls_lower title_lower
    data=$(timeout 0.4 niri msg -j focused-window 2>/dev/null)
    if [ -z "$data" ] || [ "$data" = "null" ] || [ "$data" = "{}" ]; then
        active_niri_id=""
        cls="Desktop"
        title="Desktop"
        return
    fi
    raw=$(jq -r '(.app_id // "Unknown") as $c | "\(.id // "")|\($c)|\(.title // $c)"' <<< "$data" 2>/dev/null)
    IFS='|' read -r active_niri_id cls title <<< "$raw"
    cls="${cls:-Desktop}"
    title="${title:-Desktop}"
    cls_lower="${cls,,}"
    title_lower="${title,,}"
    if [[ "$cls_lower" == *quickshell* ]] || [[ "$title_lower" == *qs-master* ]] || [[ "$cls_lower" == *qs-master* ]]; then
        cls="Quickshell"
        title="Quickshell"
    fi
}

last_cls=""
last_title=""

emit_state() {
    local target_cls="$1" target_title="$2" ts esc_cls esc_title json_payload

    if [ "$target_cls" = "$last_cls" ] && [ "$target_title" = "$last_title" ]; then
        return
    fi

    last_cls="$target_cls"
    last_title="$target_title"

    ts=$(date +%s%3N 2>/dev/null || date +%s)
    esc_cls=$(printf '%s' "$target_cls" | jq -Rsa . | sed 's/^"//;s/"$//')
    esc_title=$(printf '%s' "$target_title" | jq -Rsa . | sed 's/^"//;s/"$//')

    json_payload=$(printf '{"class":"%s","title":"%s","timestamp":%s}' "$esc_cls" "$esc_title" "$ts")

    printf '%s\n' "$json_payload" > "$STATE_FILE"
    printf '%s\n' "$json_payload" >> "$LOG_FILE"

    log_append_count=$((log_append_count + 1))
    if [ "$log_append_count" -ge 100 ]; then
        log_append_count=0
        if [ -f "$LOG_FILE" ]; then
            tail -n 200 "$LOG_FILE" > "$LOG_FILE.tmp" 2>/dev/null && mv "$LOG_FILE.tmp" "$LOG_FILE"
        fi
    fi
}

listen_events() {
    niri msg --json event-stream 2>/dev/null
}

get_active_window
emit_state "$cls" "$title"

while true; do
    while read -r line; do
        case "$line" in
            *'"WindowFocusChanged"'*|*'"WindowClosed"'*|*'"WorkspaceActivated"'*|*'"WindowOpenedOrChanged"'*)
                target_id=""
                has_focus_event=false
                is_window_changed=false
                closed=false
                is_workspace=false

                _parse_niri_line() {
                    local l="$1"
                    [[ "$l" == *'"WindowClosed"'* ]] && closed=true
                    [[ "$l" == *'"WorkspaceActivated"'* ]] && is_workspace=true
                    if [[ "$l" =~ \"WindowFocusChanged\":\{\"id\":([0-9]+)\} ]]; then
                        target_id="${BASH_REMATCH[1]}"
                        has_focus_event=true
                    elif [[ "$l" == *'"WindowFocusChanged":{"id":null}'* ]]; then
                        target_id="null"
                        has_focus_event=true
                    elif [[ "$l" == *'"WindowOpenedOrChanged"'* ]]; then
                        if [[ "$l" =~ \"is_focused\":\ *true ]]; then
                            if [[ "$l" =~ \"window\":\{\"id\":([0-9]+) ]] || [[ "$l" =~ \"id\":([0-9]+) ]]; then
                                target_id="${BASH_REMATCH[1]}"
                                has_focus_event=true
                                is_window_changed=true
                            fi
                        fi
                    fi
                }

                _parse_niri_line "$line"
                while read -t 0.02 -r extra_line; do
                    _parse_niri_line "$extra_line"
                done

                # If it was an unfocused WindowOpenedOrChanged with no other relevant events, ignore
                if [ "$closed" = false ] && [ "$has_focus_event" = false ] && [ "$is_workspace" = false ]; then
                    continue
                fi

                # If it was a pure focus event to the currently active window, skip
                if [ "$closed" = false ] && [ "$has_focus_event" = true ] && [ "$is_window_changed" = false ]; then
                    if [ "$target_id" = "$active_niri_id" ] || { [ "$target_id" = "null" ] && [ -z "$active_niri_id" ]; }; then
                        continue
                    fi
                fi
                get_active_window
                emit_state "$cls" "$title"
                ;;
        esac
    done < <(listen_events)
    sleep 1
done
