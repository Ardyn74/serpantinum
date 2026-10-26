#!/usr/bin/env bash

source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/caching.sh"
qs_ensure_cache "widgets"

TARGET_MON="${1:-}"
SELECTED_ID="${2:-}"

if [ -n "$TARGET_MON" ] && [ -n "$SELECTED_ID" ]; then
    quickshell ${MAIN_QML:+-p "$MAIN_QML"} ipc call redactor open "$TARGET_MON" "$SELECTED_ID"
elif [ -n "$TARGET_MON" ]; then
    quickshell ${MAIN_QML:+-p "$MAIN_QML"} ipc call redactor open "$TARGET_MON" ""
else
    quickshell ${MAIN_QML:+-p "$MAIN_QML"} ipc call redactor activate
fi
