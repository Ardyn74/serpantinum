#!/usr/bin/env bash

rm -f /tmp/serpantinumd.lock /tmp/serpantinumd.pid 2>/dev/null

if command -v systemctl &>/dev/null; then
    systemctl --user stop graphical-session.target 2>/dev/null
    systemctl --user stop graphical-session-pre.target 2>/dev/null
fi

if command -v dinitctl &>/dev/null; then
    dinitctl --user stop graphical-session 2>/dev/null
fi

sleep 0.2

niri msg action quit --skip-confirmation 2>/dev/null || \
niri msg action quit 2>/dev/null || \
pkill -SIGTERM -x niri 2>/dev/null || \
loginctl terminate-session "${XDG_SESSION_ID:-self}" 2>/dev/null || \
loginctl terminate-user "$USER" 2>/dev/null
