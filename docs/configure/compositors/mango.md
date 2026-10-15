---
sidebar_position: 4
title: Mango
sidebar_label: Mango
slug: /configure/compositors/mango
---

# Mango

Configuration is stored in `~/.config/mango`. The main file is `config.conf`, which includes modular files from `config/`:

- `input` - keyboard layout and touchpad settings
- `layout` - tag count, window borders, and gaps
- `autostart` - startup processes
- `keybinds` - keybindings for compositor actions and shell controls

The bundled files use the option names of Mango 0.16. Mango 0.18 renamed several of them (`gappih` to `gap_inner_horizontal`, `borderpx` to `border_px`, `exec-once` to `exec_once`), so adjust them if your Mango is newer. Validate a config without starting the compositor using `mango -c ~/.config/mango/config.conf -p`.

## Autostart

The shell daemon, clipboard history, and audio effects are launched from `config/autostart.conf`:

```ini
exec-once=wl-paste --type text --watch cliphist store
exec-once=wl-paste --type image --watch cliphist store
exec-once=systemctl --user enable --now easyeffects
exec-once=serpantinumd start
```

## Keybindings

Shell overlays and controls are bound in `config/keybinds.conf` using `spawn,serpantinum msg toggle <module>`, with the same keys as the other compositors:

```ini
bind=SUPER,D,spawn,serpantinum msg toggle launcher
bind=SUPER,B,spawn,serpantinum msg toggle system
```

Tag switching is routed through the shell to update bar indicators. Mango has nine tags by default:

```ini
bind=SUPER,1,spawn,serpantinum msg workspace 1
bind=SUPER+SHIFT,1,spawn,serpantinum msg workspace 1 move
```

## Tags

Mango uses tags instead of workspaces. The bar shows the lowest active tag of each monitor as the current workspace and marks tags that hold windows as occupied.

## Limitations

- Output scale cannot be changed at runtime. It is set with `monitorrule` in the config.
- The output toggle in display settings puts the monitor to sleep instead of removing it.
