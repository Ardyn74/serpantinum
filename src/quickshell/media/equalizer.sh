#!/usr/bin/env bash

export LC_NUMERIC=C

source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/caching.sh"
qs_ensure_cache "music"

STATE_FILE="$QS_RUN_MUSIC/eq_state.json"
LOCK_FILE="$QS_RUN_MUSIC/eq_state.lock"
SINK_NAME="serpantinum_sink"
DAEMON_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/serpantinum/audio.state"
TEST_FILE="$QS_RUN_MUSIC/channel_test.wav"
TEST_PID_FILE="$QS_RUN_MUSIC/channel_test.pid"

acquire_lock() {
    exec 200>"$LOCK_FILE"
    flock -x 200
}

declare -A PRESETS=(
    [Flat]="0 0 0 0 0 0 0 0 0 0"
    [Bass]="5 7 5 2 1 0 0 0 1 2"
    [Treble]="-2 -1 0 1 2 3 4 5 6 6"
    [Vocal]="-2 -1 1 3 5 5 4 2 1 0"
    [Pop]="2 4 2 0 1 2 4 2 1 2"
    [Rock]="5 4 2 -1 -2 -1 2 4 5 6"
    [Jazz]="3 3 1 1 1 1 2 1 2 3"
    [Classic]="0 1 2 2 2 2 1 2 3 4"
)

preset_for_gains() {
    local name
    for name in Flat Bass Treble Vocal Pop Rock Jazz Classic; do
        if [ "${PRESETS[$name]}" = "$*" ]; then
            echo "$name"
            return
        fi
    done
    echo "Custom"
}

seed_from_daemon() {
    local line fields
    [ -r "$DAEMON_STATE" ] || return 1
    read -r line < "$DAEMON_STATE" || return 1
    read -ra fields <<< "$line"
    [ "${fields[0]}" = "set" ] && [ "${#fields[@]}" -ge 16 ] || return 1

    local gains=("${fields[@]:1:10}") gain normalized=()
    for gain in "${gains[@]}"; do
        normalized+=("$(LC_NUMERIC=C awk -v g="$gain" 'BEGIN { printf "%g", g + 0 }')")
    done

    jq -n -c \
        --argjson gains "$(printf '%s\n' "${normalized[@]}" | jq -R . | jq -s .)" \
        --arg preset "$(preset_for_gains "${normalized[@]}")" \
        --argjson balance "${fields[11]}" \
        --arg mono "${fields[12]}" \
        --arg swap "${fields[13]}" \
        --arg dynamics "${fields[14]}" \
        --arg dyneq "${fields[16]:-0}" \
        '{
            "b1": $gains[0], "b2": $gains[1], "b3": $gains[2], "b4": $gains[3], "b5": $gains[4],
            "b6": $gains[5], "b7": $gains[6], "b8": $gains[7], "b9": $gains[8], "b10": $gains[9],
            "preset": $preset, "pending": false, "balance": $balance,
            "mono": ($mono == "1"), "swap": ($swap == "1"),
            "dynamics": (if ($dynamics | IN("off", "balanced", "night")) then $dynamics else "off" end),
            "dyneq": ($dyneq == "1")
        }' > "$STATE_FILE.tmp.$$" 2>/dev/null && mv -f "$STATE_FILE.tmp.$$" "$STATE_FILE"
}

if [ ! -s "$STATE_FILE" ] && ! seed_from_daemon; then
    rm -f "$STATE_FILE.tmp.$$"
    echo '{"b1": 0, "b2": 0, "b3": 0, "b4": 0, "b5": 0, "b6": 0, "b7": 0, "b8": 0, "b9": 0, "b10": 0, "preset": "Flat", "pending": false, "balance": 0, "mono": false, "swap": false, "dynamics": "off", "dyneq": false}' > "$STATE_FILE.tmp.$$" 2>/dev/null && mv -f "$STATE_FILE.tmp.$$" "$STATE_FILE"
elif ! jq -e 'has("balance") and has("mono") and has("swap") and has("dynamics") and has("dyneq")' "$STATE_FILE" >/dev/null 2>&1; then
    updated=$(jq -c '.balance //= 0 | .mono //= false | .swap //= false | .dynamics //= "off" | .dyneq //= false' "$STATE_FILE") &&
        echo "$updated" > "$STATE_FILE.tmp.$$" 2>/dev/null && mv -f "$STATE_FILE.tmp.$$" "$STATE_FILE"
fi

audio_ctl() {
    command -v serpantinum-audio >/dev/null 2>&1 || return 1
    serpantinum-audio ctl "$@" >/dev/null 2>&1 && return 0
    serpantinum-audio start >/dev/null 2>&1 || return 1
    serpantinum-audio ctl "$@" >/dev/null 2>&1
}

apply_eq() {
    local args
    args=$(jq -r '[
        (.b1, .b2, .b3, .b4, .b5, .b6, .b7, .b8, .b9, .b10 | tonumber),
        (.balance // 0),
        (if .mono then 1 else 0 end),
        (if .swap then 1 else 0 end),
        (.dynamics // "off"),
        0,
        (if .dyneq then 1 else 0 end)
    ] | map(tostring) | join(" ")' "$STATE_FILE" 2>/dev/null) || return 1

    audio_ctl set $args
}

save_preset() {
    local balance mono swap dynamics dyneq
    balance=$(jq -r '.balance // 0' "$STATE_FILE" 2>/dev/null || echo 0)
    mono=$(jq -r '.mono // false' "$STATE_FILE" 2>/dev/null || echo false)
    swap=$(jq -r '.swap // false' "$STATE_FILE" 2>/dev/null || echo false)
    dynamics=$(jq -r '.dynamics // "off"' "$STATE_FILE" 2>/dev/null || echo "off")
    dyneq=$(jq -r '.dyneq // false' "$STATE_FILE" 2>/dev/null || echo false)

    jq -n -c \
        --argjson b1 "${1:-0}" \
        --argjson b2 "${2:-0}" \
        --argjson b3 "${3:-0}" \
        --argjson b4 "${4:-0}" \
        --argjson b5 "${5:-0}" \
        --argjson b6 "${6:-0}" \
        --argjson b7 "${7:-0}" \
        --argjson b8 "${8:-0}" \
        --argjson b9 "${9:-0}" \
        --argjson b10 "${10:-0}" \
        --arg p "${11}" \
        --argjson balance "$balance" \
        --argjson mono "$mono" \
        --argjson swap "$swap" \
        --arg dynamics "$dynamics" \
        --argjson dyneq "$dyneq" \
        '{
            "b1": $b1,
            "b2": $b2,
            "b3": $b3,
            "b4": $b4,
            "b5": $b5,
            "b6": $b6,
            "b7": $b7,
            "b8": $b8,
            "b9": $b9,
            "b10": $b10,
            "preset": $p,
            "pending": false,
            "balance": $balance,
            "mono": $mono,
            "swap": $swap,
            "dynamics": $dynamics,
            "dyneq": $dyneq
        }' > "$STATE_FILE.tmp.$$" 2>/dev/null && mv -f "$STATE_FILE.tmp.$$" "$STATE_FILE"
}

stop_test() {
    if [ -f "$TEST_PID_FILE" ]; then
        pid=$(cat "$TEST_PID_FILE" 2>/dev/null || true)
        if [[ "$pid" =~ ^[0-9]+$ ]]; then
            kill "$pid" >/dev/null 2>&1 || true
        fi
        rm -f "$TEST_PID_FILE"
    fi
}

play_test() {
    stop_test

    if [ ! -s "$TEST_FILE" ]; then
        python3 - "$TEST_FILE" <<'PY'
import math, struct, sys, wave

path = sys.argv[1]
rate = 48000
segments = [(0.75, 660, 0), (0.18, 0, 0), (0.75, 0, 880),
            (0.18, 0, 0), (1.0, 770, 770)]
with wave.open(path, 'wb') as out:
    out.setnchannels(2)
    out.setsampwidth(2)
    out.setframerate(rate)
    for duration, left_hz, right_hz in segments:
        for index in range(int(duration * rate)):
            fade = min(1.0, index / (rate * 0.015),
                       (duration * rate - index) / (rate * 0.015))
            def sample(freq):
                return int(9000 * fade * math.sin(2 * math.pi * freq * index / rate)) if freq else 0
            out.writeframesraw(struct.pack('<hh', sample(left_hz), sample(right_hz)))
PY
    fi

    command -v serpantinum-audio >/dev/null 2>&1 && serpantinum-audio start >/dev/null 2>&1
    target=()
    if command -v pw-dump >/dev/null 2>&1 &&
       pw-dump 2>/dev/null | jq -e --arg n "$SINK_NAME" 'any(.[]; .info.props["node.name"] == $n)' >/dev/null 2>&1; then
        target=(--target="$SINK_NAME")
    fi

    (
        player_pid=""
        cleanup_test() {
            [ -n "$player_pid" ] && kill "$player_pid" >/dev/null 2>&1 || true
            if [ "$(cat "$TEST_PID_FILE" 2>/dev/null)" = "$BASHPID" ]; then
                rm -f "$TEST_PID_FILE"
            fi
        }
        trap cleanup_test EXIT TERM INT
        pw-play "${target[@]}" \
            -P '{"application.id":"serpantinum-audio-test","application.name":"Serpantinum audio test","media.role":"music"}' \
            "$TEST_FILE" >/dev/null 2>&1 &
        player_pid=$!
        wait "$player_pid"
    ) &
    echo "$!" > "$TEST_PID_FILE"
}

cmd=$1
arg1=$2
arg2=$3

case $cmd in
    "get")
        cat "$STATE_FILE"
        ;;

    "set_band")
        acquire_lock
        [[ "$arg1" =~ ^([1-9]|10)$ ]] || exit 1
        if ! [[ "$arg2" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
            exit 1
        fi

        jq -c \
            --argjson val "$arg2" \
            ".b$arg1 = \$val | .preset = \"Custom\" | .pending = true" \
            "$STATE_FILE" > "$STATE_FILE.tmp.$$" 2>/dev/null && mv -f "$STATE_FILE.tmp.$$" "$STATE_FILE"
        ;;

    "restore_bands")
        acquire_lock
        shift
        jq -c \
            --argjson b1 "${1:-0}" --argjson b2 "${2:-0}" --argjson b3 "${3:-0}" --argjson b4 "${4:-0}" --argjson b5 "${5:-0}" \
            --argjson b6 "${6:-0}" --argjson b7 "${7:-0}" --argjson b8 "${8:-0}" --argjson b9 "${9:-0}" --argjson b10 "${10:-0}" \
            --arg p "${11:-Custom}" \
            '.b1 = $b1 | .b2 = $b2 | .b3 = $b3 | .b4 = $b4 | .b5 = $b5 | .b6 = $b6 | .b7 = $b7 | .b8 = $b8 | .b9 = $b9 | .b10 = $b10 | .preset = $p | .pending = false' \
            "$STATE_FILE" > "$STATE_FILE.tmp.$$" 2>/dev/null && mv -f "$STATE_FILE.tmp.$$" "$STATE_FILE"
        apply_eq
        ;;

    "apply")
        acquire_lock
        jq -c ".pending = false" "$STATE_FILE" > "$STATE_FILE.tmp.$$" 2>/dev/null && mv -f "$STATE_FILE.tmp.$$" "$STATE_FILE"
        apply_eq
        ;;

    "set_balance")
        acquire_lock
        if ! [[ "$arg1" =~ ^-?([0-9]+([.][0-9]*)?|[.][0-9]+)$ ]]; then
            exit 1
        fi

        jq -c \
            --argjson val "$arg1" \
            '.balance = (if $val < -1 then -1 elif $val > 1 then 1 else $val end)' \
            "$STATE_FILE" > "$STATE_FILE.tmp.$$" 2>/dev/null && mv -f "$STATE_FILE.tmp.$$" "$STATE_FILE"
        apply_eq
        ;;

    "set_dyneq")
        acquire_lock
        [ "$arg1" = "true" ] || [ "$arg1" = "false" ] || exit 1
        jq -c --argjson val "$arg1" '.dyneq = $val' \
            "$STATE_FILE" > "$STATE_FILE.tmp.$$" || exit 1
        mv -f "$STATE_FILE.tmp.$$" "$STATE_FILE"
        apply_eq
        ;;

    "set_mono"|"set_swap")
        acquire_lock
        [ "$arg1" = "true" ] || [ "$arg1" = "false" ] || exit 1
        key=${cmd#set_}
        jq -c --arg key "$key" --argjson val "$arg1" '.[$key] = $val' \
            "$STATE_FILE" > "$STATE_FILE.tmp.$$" || exit 1
        mv -f "$STATE_FILE.tmp.$$" "$STATE_FILE"
        apply_eq
        ;;

    "set_dynamics")
        acquire_lock
        case "$arg1" in off|balanced|night) ;; *) exit 1 ;; esac
        jq -c --arg val "$arg1" '.dynamics = $val' \
            "$STATE_FILE" > "$STATE_FILE.tmp.$$" || exit 1
        mv -f "$STATE_FILE.tmp.$$" "$STATE_FILE"
        apply_eq
        ;;

    "reset_audio")
        acquire_lock
        jq -c '.balance = 0 | .mono = false | .swap = false | .dynamics = "off"' \
            "$STATE_FILE" > "$STATE_FILE.tmp.$$" || exit 1
        mv -f "$STATE_FILE.tmp.$$" "$STATE_FILE"
        stop_test
        apply_eq
        ;;

    "test")
        play_test
        ;;

    "stop_test")
        stop_test
        ;;

    "preset")
        acquire_lock
        [ -n "${PRESETS[$arg1]:-}" ] || exit 1
        save_preset ${PRESETS[$arg1]} "$arg1"
        apply_eq
        ;;
esac
