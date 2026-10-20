---
sidebar_position: 1
title: Serpantinum client
sidebar_label: Serpantinum client
slug: /cli/client
---

# Serpantinum client

`serpantinum` is the command-line client for the desktop shell.

## Options

- `-v, --verbose`: Enable verbose logging output.
- `-V, --version`: Print installed version and exit.
- `-h, --help`: Show usage help and exit.

## Commands

### `msg`

Dispatches layout, workspace, and overlay actions to the shell:

- `serpantinum msg workspace <number>`: Switch to workspace `<number>`.
- `serpantinum msg workspace <number> move`: Move active window to workspace `<number>`.
- `serpantinum msg <number>`: Shorthand to switch to workspace `<number>`.
- `serpantinum msg <number> move`: Shorthand to move active window to workspace `<number>`.
- `serpantinum msg open <target> [subtarget]`: Open a panel or activate a subtab.
- `serpantinum msg toggle <target> [subtarget]`: Toggle panel visibility.
- `serpantinum msg close`: Close any open overlay.

#### Targets

- `launcher`: Application search and launcher overlay.
- `clipboard` (alias: `clip`): Clipboard history manager.
- `network`: Network manager popup.
  - `network wifi`: Open directly on WiFi tab.
  - `network ethernet`: Open directly on Ethernet tab.
- `volume`: Audio mixer and device picker.
- `guide`: Settings and documentation hub.
  - `guide keybinds`: Open shortcut cheat sheet tab.
  - `guide appearance`: Open appearance and styling tab.
- `calendar`: Calendar, clock, and schedule panel.
- `music`: Media player controls and track artwork.
- `wallpaper`: Wallpaper picker and live preview.
- `notifications`: Notification history center.
- `system`: System resource monitor and power controls.
- `autohide`: Toggle bar autohide setting live.
- `airplane` (alias: `flight`): Toggle airplane mode (WiFi and Bluetooth).
- `clearNotifications` (aliases: `clear_notifications`, `clearNotifs`): Clear all notifications.

### `launch`

Runs standalone interface components in runner mode:

- `serpantinum launch start [args...]`: Launch first-time setup and onboarding wizard.
- `serpantinum launch widgetredactor [args...]`: Launch desktop widget editor.

### `ipc`

Sends raw IPC calls directly to the running shell:

- `serpantinum ipc call <target> <method> [args...]`: Forward call to target object.
  - `ipc call main handleCommand <cmd> <target> <arg>`: Dispatch generic UI command.
  - `ipc call main forceReload`: Force reload shell components.
  - `ipc call main clearNotifications`: Purge all notification popups and history.
  - `ipc call lock activate`: Trigger lock screen immediately.
  - `ipc call screenshotOverlay toggle [args...]`: Toggle interactive screenshot overlay.

### `kill`

Stops the daemon and terminates all background shell workers (`focus_daemon.py`, `quickshell`, `serpantinumd`).

### `restart`

Stops the daemon and starts it again.

## Shell control

### `launcher`, `clipboard`, `guide`, `calendar`

Opens, closes or toggles the matching panel. The action defaults to `toggle`:

- `serpantinum launcher [toggle|open|close]`: Application launcher.
- `serpantinum clipboard [toggle|open|close]`: Clipboard history.
- `serpantinum guide [toggle|open|close] [tab]`: Settings and documentation hub, optionally on a tab.
- `serpantinum calendar [toggle|open|close]`: Calendar and clock panel.
- `serpantinum lock-redactor [toggle|open [monitor]|close]`: Lock screen layout editor.
- `serpantinum redactor [monitor] [widget]`: Desktop widget layout editor.

### `config`

Reads and writes `settings.json`. Keys use dots to reach nested values and changes apply live:

- `serpantinum config get <key> [fallback]`: Print a setting.
- `serpantinum config set <key> <value>`: Set a setting. Values are parsed as JSON and fall back to plain strings.
- `serpantinum config dump`: Print the whole settings file.
- `serpantinum config path`: Print the settings file path.
- `serpantinum config edit`: Open the settings file in `$VISUAL` or `$EDITOR`.

### `lang`

- `serpantinum lang get`: Print the active language code.
- `serpantinum lang list`: List available language codes.
- `serpantinum lang set <code>`: Change the interface language.

### `wallpaper`

`[screen]` is a monitor name and defaults to `all`:

- `serpantinum wallpaper set <path> [screen] [transition]`: Set a wallpaper.
- `serpantinum wallpaper get [screen]`: Print the current wallpaper path.
- `serpantinum wallpaper random [screen]`: Pick a random wallpaper from the wallpaper directory.
- `serpantinum wallpaper next [screen]`: Switch to the next wallpaper in the directory.
- `serpantinum wallpaper prev [screen]`: Switch to the previous wallpaper in the directory.
- `serpantinum wallpaper playback <play|pause> [screen]`: Play or pause a video wallpaper.
- `serpantinum wallpaper clear [screen]`: Clear the wallpaper.

### `theme`

- `serpantinum theme list`: List bundled theme presets.
- `serpantinum theme get`: Print the active preset.
- `serpantinum theme set <preset>`: Apply a preset.
- `serpantinum theme matugen <on|off|toggle|status>`: Control wallpaper-derived colors.
- `serpantinum theme reload`: Reload colors.
- `serpantinum theme generate <image> [mode] [scheme]`: Generate colors from an image.

### `dnd`, `notif`

- `serpantinum dnd [on|off|toggle|status]`: Control do not disturb.
- `serpantinum notif clear`: Clear all notifications.
- `serpantinum notif <toggle|open|close>`: Control the notification center.

### `bar`, `dock`

- `serpantinum bar autohide [on|off|toggle|status]`: Control bar autohide.
- `serpantinum bar position <top|bottom|left|right>`: Move the bar.
- `serpantinum bar reload`: Reload the bar.
- `serpantinum dock [on|off|toggle|status]`: Show or hide the dock.
- `serpantinum dock autohide [on|off|toggle|status]`: Control dock autohide.

### `idle`, `caffeine`

- `serpantinum idle trigger <dim|dpms|lock|suspend>`: Run an idle action now.
- `serpantinum caffeine [on|off|toggle|status]`: Pause idle actions to keep the system awake.

### `sfx`, `firstlaunch`

- `serpantinum sfx mute [on|off|toggle|status]`: Mute interface sound effects.
- `serpantinum firstlaunch <trigger|reset>`: Run or reset the first launch setup.

### `check-updates`

- `serpantinum check-updates [--json]`: Compare the installed version with the latest release.

### `monitors`

- `serpantinum monitors [--json]`: List active outputs, with width, height and refresh rate as JSON.

## Script shortcuts

### `screenshot`

Captures screen images, records video, or decodes QR codes:

- `serpantinum screenshot`: Open interactive selection and recording overlay.
- `serpantinum screenshot --full`: Capture focused monitor immediately.
- `serpantinum screenshot --edit`: Open screenshot in Satty image editor.
- `serpantinum screenshot --record`: Toggle screen video recording (start or stop).
- `serpantinum screenshot --scan-qr`: Scan selected region for QR codes.
- `serpantinum screenshot --geometry <X,Y WxH>`: Set capture crop region.
- `serpantinum screenshot --monitor <name>`: Set target monitor output.
- `serpantinum screenshot --backend <gpu-screen-recorder|wf-recorder>`: Set recording backend.
- `serpantinum screenshot --desk-vol <0.0-1.0>`: Set desktop audio volume multiplier.
- `serpantinum screenshot --desk-mute <true|false>`: Mute desktop audio in recording.
- `serpantinum screenshot --mic-vol <0.0-1.0>`: Set microphone audio volume multiplier.
- `serpantinum screenshot --mic-mute <true|false>`: Mute microphone audio in recording.
- `serpantinum screenshot --mic-dev <name>`: Set microphone input device name.

### `volume`

Controls audio sink and source levels via WirePlumber:

- `serpantinum volume raise`: Increase output volume by 5%.
- `serpantinum volume lower`: Decrease output volume by 5%.
- `serpantinum volume mute-toggle`: Toggle output mute.
- `serpantinum volume mic-toggle`: Toggle microphone mute.
- `serpantinum volume mic-raise`: Increase microphone volume by 5%.
- `serpantinum volume mic-lower`: Decrease microphone volume by 5%.

### `brightness`

Controls display backlight and external monitor brightness:

- `serpantinum brightness get`: Print current brightness percentage (default).
- `serpantinum brightness set <0-100>`: Set brightness to percentage.
- `serpantinum brightness raise`: Increase brightness by 5%.
- `serpantinum brightness lower`: Decrease brightness by 5%.
- `serpantinum brightness backend`: Print active backend (`backlight`, `ddc`, or `none`).
- `serpantinum brightness watch`: Watch backlight changes with inotify.

### `weather`

Queries weather data and manages forecast cache:

- `serpantinum weather --current-temp`: Print current temperature.
- `serpantinum weather --current-icon`: Print current weather icon glyph.
- `serpantinum weather --current-hex`: Print current weather condition accent hex.
- `serpantinum weather --temp`: Print today forecasted maximum temperature.
- `serpantinum weather --icon`: Print today forecast icon glyph.
- `serpantinum weather --hex`: Print today forecast accent hex.
- `serpantinum weather --json`: Print complete structured forecast JSON.
- `serpantinum weather --getdata`: Force fresh fetch from Open-Meteo API.
- `serpantinum weather --nav next`: Advance 5-day forecast view to next day.
- `serpantinum weather --nav prev`: Move 5-day forecast view to previous day.
- `serpantinum weather --view-listener`: Stream active forecast view index.
- `serpantinum weather --unit <metric|imperial|standard>`: Set temperature unit profile.
- `serpantinum weather --location '<json>'`: Pass custom coordinates JSON.
- `serpantinum weather --verbose` (`-v`): Print verbose debug output.

### `location`

Retrieves and updates geographic coordinates:

- `serpantinum location`: Print cached or retrieved location JSON.
- `serpantinum location --refresh` (`-r`): Force fresh lookup from IP geolocation providers.
- `serpantinum location --verbose` (`-v`): Print debug diagnostics to stderr.

### `location_manual`

Sets geographic coordinates manually:

- `serpantinum location_manual <latitude> <longitude>`: Set coordinates, reverse-geocode city and country, resolve timezone, and save to settings.

### `blue_light_filter`

Controls color temperature and day/night schedule via DBus:

- `serpantinum blue_light_filter set <temperature> [output] [mode] [latitude] [longitude]`: Set temperature (1000-10000K) manually (`mode=manual`) or automatically with solar schedule (`mode=auto`).
- `serpantinum blue_light_filter reset [output]`: Reset color temperature to 6500K daylight neutral and stop auto loop.
- `serpantinum blue_light_filter status [output]`: Print status (`running` or `stopped`).
- `serpantinum blue_light_filter --verbose` (`-v`): Print verbose output with current Kelvin and brightness levels.

### `monitors_detect`

Queries active display outputs:

- `serpantinum monitors_detect`: List connected display names line-by-line.
- `serpantinum monitors_detect --verbose`: Output display specifications (`<name>|<resolution>|<refresh_rate>`).

### `current_focus`

Runs active window focus tracking daemon:

- `serpantinum current_focus`: Monitor and log window focus changes across compositors to JSONL.

### `lock`

Activates lock screen:

- `serpantinum lock`: Trigger lock screen interface immediately.

### `reload`

Reloads shell:

- `serpantinum reload`: Force reload QuickShell desktop elements without restarting the daemon.

### `exit`

Terminates desktop session:

- `serpantinum exit`: Cleanly terminate graphical session and exit active compositor.

### `suspend`, `hibernate`, `reboot`, `poweroff`

- `serpantinum suspend`: Lock the screen and suspend the system.
- `serpantinum hibernate`: Hibernate the system.
- `serpantinum reboot`: Reboot the system.
- `serpantinum poweroff`: Power off the system.
