#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/caching.sh"

PIPE="$QS_RUN_DIR/qs_kb_wait_$$.fifo"
mkfifo "$PIPE" 2>/dev/null
trap 'rm -f "$PIPE"; kill $(jobs -p) 2>/dev/null; exit 0' EXIT INT TERM

niri msg -j event-stream 2>/dev/null | jq --unbuffered -c 'select(has("KeyboardLayoutSwitched"))' > "$PIPE" &

read -r _ < "$PIPE"
sleep 0.05
