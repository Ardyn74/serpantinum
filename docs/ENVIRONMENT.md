# System Environment, Shell Architecture & Changelog Reference

This document consolidates the architecture, system configurations, custom enhancements, upstream synchronizations, and troubleshooting lessons for this CachyOS + Niri + Serpantinum system (`Ardyn74/serpantinum`).

---

## 1. CLI Shell & User Environment

### Active Shells & Startup Files
- **Default Interactive Login Shell (`$SHELL`)**: `/bin/fish`
  - **User Config (`~/.config/fish/config.fish`)**: Sources `/usr/share/cachyos-fish-config/cachyos-config.fish` and prepends `/home/abhay/.local/bin` to `PATH`.
  - **CachyOS Fish Config (`/usr/share/cachyos-fish-config/cachyos-config.fish`)**:
    - Runs `fastfetch` via `fish_greeting` on interactive terminal launch.
    - Adds `~/.local/bin`, `~/.cargo/bin`, and `~/Applications/depot_tools` to `PATH` via `fish_add_path`.
    - Sets `MANPAGER="sh -c 'col -bx | bat -l man -p'"` and `MANROFFOPT="-c"`.
    - Enables `!!` and `!$` history expansion bindings (`__history_previous_command`) and `done.fish` long-command notifications (>10s).
    - **Key Aliases & Functions**:
      - `ls`, `la`, `ll`, `lt`, `l.` -> `eza` with `--color=always --group-directories-first --icons=always`
      - `update` -> `sudo cachyos-rate-mirrors && sudo pacman -Syu`
      - `cleanup` -> `sudo pacman -Rns (pacman -Qtdq)`
      - `jctl` -> `journalctl -p 3 -xb`
      - `psmem` / `psmem10` -> top memory processes via `ps auxf`
      - `big` / `rip` -> `expac` package size and recent install reports
      - `backup <file>` -> copies `<file>` to `<file>.bak`
- **Bash (`~/.bashrc`, `~/.bash_profile`) & Zsh (`~/.zshrc`)**:
  - `~/.bashrc` exits early for non-interactive shells (`[[ $- != *i* ]] && return`) before setting aliases and exporting `PATH="/home/abhay/.local/bin:$PATH"`.
  - `~/.bash_profile` sources `~/.bashrc` and exports `PATH="/home/abhay/.local/bin:$PATH"`.
- **Session Environment Variables (`~/.config/environment.d/`)**:
  - `serpantinum-portal.conf`: `GTK_USE_PORTAL=1` (routes GTK file chooser dialogs through `xdg-desktop-portal` -> `ski`).
  - `serpantinum-qt.conf`: `QT_QPA_PLATFORMTHEME=qt6ct`.

### User-Local Binaries & Application Layout (`~/.local/`)
- **`~/.local/bin/`**:
  - `serpantinum` -> symlink to `~/.local/share/serpantinum/bin/serpantinum` (also symlinked in `/usr/local/bin/serpantinum`).
  - `serpantinumd` -> symlink to `~/.local/share/serpantinum/bin/serpantinumd` (also symlinked in `/usr/local/bin/serpantinumd`).
  - `serpantinum-audio` -> standalone Rust PipeWire DSP/equalizer daemon (v0.2.0).
  - `ski` -> standalone Rust/egui file manager and XDG file chooser portal binary (v0.4.3).
  - `matlab` -> symlink to `~/.local/bin/matlab-launcher` (deployed from `config/matlab/matlab-launcher`).
  - `antigravity` -> symlink to `~/.local/opt/Antigravity-x64/antigravity`.
  - `agy` -> Antigravity CLI binary.
- **`~/.local/opt/`**:
  - `Antigravity-x64/` -> Antigravity IDE installation managed by `install/modules/apps.sh`.
  - `MATLAB/R2026/` & `spkgs/` -> MATLAB R2026a and support packages installed via `matlab-mpm`.

---

## 2. Desktop Shell, Compositor & System Services

### Niri Wayland Compositor (`compositors/niri/` <-> `~/.config/niri/`)
- **Entry Point**: `~/.config/niri/config.kdl` includes modular files from `~/.config/niri/config/`:
  - `layout.kdl`:
    - `default-column-width { proportion 0.75; }`
    - `center-focused-column "always"` and `always-center-single-column`
    - **Half-Width Exceptions (`proportion 0.5`)**: `io.bassi.Amberol`, `org.gnome.Calculator`, `gnome-calculator`.
    - **Rounded Corner Clipping (`geometry-corner-radius 10`, `clip-to-geometry true`)**: Applied specifically to `^kitty$` and `^ski` because they render raw rectangular OpenGL/wgpu surfaces without GTK4 client-side decorations.
  - `input.kdl`: Touchpad `natural-scroll`, `tap`, and global `gestures { hot-corners { off } }`.
  - `keybinds.kdl`: `Mod+Return` (`kitty`), `Mod+E` (`ski`), `Mod+Space` (`serpantinum ipc call launcher toggle`), `Mod+V` (clipboard), `Mod+L` (lock), media/brightness/workspace keys.
  - `autostart.kdl`: Starts `/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1`, `serpantinumd start`, and `swww-daemon` (`easyeffects` removed after migration to `serpantinum-audio`).
  - `output.kdl` & `env.kdl`: Monitor configuration and compositor environment variables.

### Serpantinum (Quickshell) Runtime Architecture
- **Source Repository**: `/home/abhay/serpantinum`
- **Deployed Runtime**: `~/.local/share/serpantinum/{bin,src,version.txt}`
- **User Settings**: `~/.config/serpantinum/settings.json` (initialized from clean template `config/serpantinum/settings.json`; live file additionally stores user preferences and cached IP geolocation data from `location.sh`).
- **Audio Engine (`serpantinum-audio`)**:
  - Replaces EasyEffects (~200 MB RAM -> ~9.4 MB RAM) with real-time 10-band parametric EQ, preamp, balance/mono/swap, dynamic range compression, and Fletcher-Munson **Dynamic EQ**.
  - Controlled via `src/quickshell/media/equalizer.sh` (protected by `flock` on `$QS_RUN_MUSIC/eq_state.lock` and atomic batch `restore_bands`).
  - Internal PipeWire nodes (`serpantinum_output`, `serpantinum_sink`, `serpantinum-audio-test`) are filtered out of `Audio.qml` so `cava` does not spin at 60 FPS during silence.
- **File Manager & XDG Portals (`ski` v0.4.3)**:
  - Configured as default file manager (`Mod+E`, dock icon, `org.freedesktop.FileManager1` D-Bus service) and file picker (`org.freedesktop.impl.portal.FileChooser=ski`).
  - `~/.config/xdg-desktop-portal/portals.conf` explicitly retains `default=gnome;gtk;`, `Access=gtk;`, `Notification=gtk;`, and `Secret=gnome-keyring;` alongside `FileChooser=ski;` so user-level config does not shadow `/usr/share/xdg-desktop-portal/niri-portals.conf`.
  - `~/.config/ski/settings.json` sets `"terminal": "kitty"`.

### System-Level (`/etc`) & Hardware Optimizations
| Path / Service | Purpose & Configuration |
| :--- | :--- |
| `/etc/sddm.conf.d/10-impasto.conf` | Uses custom `impasto` SDDM theme (`/usr/share/sddm/themes/impasto`) with bundled `Inter Display` font, `DisplayServer=x11`, and single `QT_SCALE_FACTOR=1.4` (avoiding compounded `1.96x` Qt6 scaling). |
| `/etc/udev/rules.d/99-battery-charge-limit.rules` | Caps laptop internal battery charging at **80%**, guarded with `ACTION=="add\|change", SUBSYSTEM=="power_supply", KERNEL=="BAT[0-9]*", ATTR{type}=="Battery", TEST=="charge_control_end_threshold"`. |
| `/etc/fstab` (`/boot`) | Added `noauto,x-systemd.automount` to `/boot` (`UUID=25E4-3BB9`), eliminating ~3.2s `fsck.vfat` wait from the boot critical path. |
| `/etc/systemd/resolved.conf.d/10-no-mdns-llmnr.conf` | Sets `LLMNR=no` and `MulticastDNS=no` so `systemd-resolved` yields UDP 5353 to `avahi-daemon` and stops UFW UDP 5355 log spam. |
| `/etc/systemd/timesyncd.conf.d/local.conf` | Resets `NTP=` before setting `NTP=time.google.com 10.7.0.1` so `systemd-timesyncd` does not hang on blocked campus NTP requests to `time.cloudflare.com`. |
| `scx_loader.service` (`scx_bpfland`) | Enabled sched-ext `bpfland` CPU scheduler in Auto mode to prioritize interactive Wayland/Quickshell frame pacing under load. |
| `~/.config/autostart/mathworks-service-host.desktop` | Disabled (`Hidden=true`, `X-GNOME-Autostart-enabled=false`) to prevent background MathWorks daemon bloat at login. |

---

## 3. Repository Structure, Remotes & Sync Workflow

### Repository Layout (`/home/abhay/serpantinum`)
```text
/home/abhay/serpantinum/
├── AGENTS.md                  # Operational rules for AI coding agents
├── README.md                  # Fork overview and CachyOS/Arch install commands
├── bin/                       # CLI (serpantinum) & daemon (serpantinumd) scripts
├── compositors/niri/          # Tracked Niri config (config.kdl & config/*.kdl)
├── config/
│   ├── cava/                  # Cava audio visualizer config & shaders
│   ├── fastfetch/             # Fastfetch config
│   ├── kitty/                 # Kitty terminal config (JetBrainsMono Nerd Font)
│   ├── matlab/                # MATLAB Wayland launcher, satellite service, setup.sh
│   ├── sddm/themes/impasto/   # Bundled Impasto SDDM theme & Inter Display fonts
│   ├── serpantinum/           # Clean default settings.json template
│   └── udev/                  # 99-battery-charge-limit.rules (80% threshold)
├── docs/                      # Documentation (ENVIRONMENT.md, MATLAB.md, audio/, etc.)
├── install/
│   ├── get.sh & install.sh    # Installer entry points (REPO_SLUG=Ardyn74/serpantinum)
│   ├── assets/antigravity.png # Bundled icon for Antigravity desktop entry
│   ├── modules/               # Modular installer (pm.sh, deps.sh, ski.sh, audio.sh, apps.sh, deploy.sh, etc.)
│   └── tests/                 # Installer & migration test suites
├── packaging/                 # AUR PKGBUILDs & .desktop files
├── src/
│   ├── assets/                # Translations (23 languages), fonts, presets, sounds
│   ├── quickshell/            # QML desktop shell (bar, dock, lock, media, popouts, singletons)
│   └── scripts/               # Backend helper scripts (caching, brightness, monitors, screenshot, etc.)
└── wallpapers/                # Custom bundled wallpaper collection
```

### Git Remote Configuration & Sync Workflow
- **Remotes**:
  - `origin`: `https://github.com/Ardyn74/serpantinum.git` (Primary push/fetch target)
  - `upstream`: `https://github.com/ilyamiro/serpantinum.git` (Upstream tracking remote)
- **Deploying Repo Changes to the Live System**:
  - The running desktop shell loads from `~/.local/share/serpantinum/`, **not** directly from `/home/abhay/serpantinum/`.
  - After editing `src/` or `bin/` in `/home/abhay/serpantinum/`:
    ```bash
    rsync -a --delete /home/abhay/serpantinum/src/ ~/.local/share/serpantinum/src/
    rsync -a --delete /home/abhay/serpantinum/bin/ ~/.local/share/serpantinum/bin/
    serpantinum reload   # or: serpantinumd restart (if bin/serpantinumd env vars changed)
    ```
  - After editing Niri configs (`compositors/niri/config/*.kdl` <-> `~/.config/niri/config/*.kdl`):
    ```bash
    niri validate && cp ~/.config/niri/config/*.kdl /home/abhay/serpantinum/compositors/niri/config/
    ```
- **Syncing with Upstream (`ilyamiro/serpantinum`)**:
  - Because `ca35591` specialized the repo exclusively for CachyOS/Arch + Niri (deleting 38 NixOS, Fedora, Void, Hyprland, Sway, and Mango files), prefer **selective `git cherry-pick -x <commit>`** for upstream fixes in `src/quickshell/` or `src/scripts/`.
  - If performing a `git merge upstream/master`, inspect `git status` for `DU`/`UD` (deleted-by-us) conflicts on removed compositors/distros (`git rm` them), and audit `src/quickshell/qmldir` so no removed singleton (like `MangoState.qml`) is re-registered.

---

## 4. Chronological Changelog of Major Customizations

1. **Initial Fork & Niri/SDDM/Battery Customizations (`d92b94b`..`cc7a588`)**:
   - Retargeted installer and docs to `Ardyn74/serpantinum`.
   - Added 80% battery charge limit udev rule (`config/udev/99-battery-charge-limit.rules`).
   - Replaced upstream wallpaper pack with curated custom wallpapers in `wallpapers/`.
   - Switched SDDM theme from `material-you` to `impasto`, bundled `Inter Display` fonts, enabled smooth antialiased rendering, and tuned scaling to `1.4`.
   - Enforced 12-hour `hh:mm AP` clock format on lockscreen and widgets in 12h mode.
   - Removed QuickActions Draw/Canvas module (`ac91e15`) and Weather functionality (`e938dcd`), centering the time module popup.
   - Prevented duplicate `quickshell` daemon instances (`1200f47`).
2. **Core Shell Performance & Reliability Audit (`d3d3ef5`, `a21984a`, `a821d08`)**:
   - Stopped `qs_manager.sh` from deleting user `.webp` wallpapers.
   - Hoisted `Bar.qml` `IpcHandler` outside `Variants` for multi-monitor IPC support.
   - Eliminated 50ms hardware probe storms (`udevadm`/`lspci`/`lsblk`) on every settings save in `SystemInfo.qml`.
   - Added `_settingsCache` in `Config.qml` and fast-path CLI dispatch in `bin/serpantinum` + `i18n.sh` (reducing hotkey latency from ~100ms to ~15ms).
   - Lazy-loaded `TopBar`/`SideBar` via `Loader` in `Bar.qml` and bounded QML image decoding (`sourceSize`) across 13 components.
   - Merged upstream hybrid-GPU video wallpaper optimization (`QT_FFMPEG_DECODING_HW_DEVICE_TYPES=vaapi`) so video wallpapers decode on the AMD/Intel iGPU without waking the NVIDIA dGPU.
3. **MATLAB R2026a Wayland & VS Code Integration (`90b6d73`, `956bf30`, `d253bb6`)**:
   - Added `config/matlab/{matlab-launcher,matlab-satellite.service,matlab.desktop,setup.sh}` and `docs/MATLAB.md`.
   - Solved `glibc 2.44` FlexLM segfault (`-licmode onlinelicensing`), bundled `libstdc++` symbol conflicts (`LD_PRELOAD`), CEF Wayland crashes (`xwayland-satellite :12` on demand), VS Code background server GUI popups (filtering `-desktop` on headless flags), and CLI stdout/stderr swallowing.
4. **Upstream v2.3.2 Sync, Ski v0.4.3 & `serpantinum-audio` v0.2.0 (`37c40eb`..`06b9eec`)**:
   - Cherry-picked 10 upstream bugfixes and merged `upstream/master` (`v2.3.2`).
   - Bundled and deployed **Ski v0.4.3** as default file manager (`Mod+E`), dock app, and XDG file chooser portal.
   - Migrated audio processing from EasyEffects to **`serpantinum-audio` v0.2.0** with adaptive Dynamic EQ.
5. **Post-Merge Hardening, Fork Rebranding, CachyOS/Niri Specialization & Apps Suite (`956bf30`..`c9eb73d`)**:
   - Resolved 24 post-merge issues (`956bf30`): filtered `serpantinum_output` in `Audio.qml` to stop 24/7 60 FPS `cava` spin, added `flock` + batch `restore_bands` to `equalizer.sh`, removed stale `updateForecastData()` call in `LockScreen.qml`, typed `Bar.qml` IPC argument, fixed `MprisController.qml` `.dbusName`, fixed Niri `monitors_detect.sh` `jq` parser, and restored `gnome;gtk;` portal fallbacks.
   - Removed upstream donation/sponsor links and updated fork metadata (`bbaf44e`).
   - Added Niri `geometry-corner-radius 10` clipping for `kitty` and `ski` (`3e4b482`) and synced custom `layout.kdl` & `input.kdl` (`18c0a6d`).
   - Pruned 38 non-Arch / non-Niri files (~3,150 lines) to specialize exclusively for CachyOS/Arch Linux + Niri (`ca35591`) and cleaned up dangling `MangoState` references (`e85270b`).
   - Added `install/modules/apps.sh` (`c9eb73d`) to automate installing the 33-package Desktop Apps Suite, AUR apps (`visual-studio-code-bin`, `matlab-mpm`), and the Antigravity IDE auto-installer.

---

## 5. Key Decisions, Rationale & Troubleshooting Gotchas

- **Why `gsettings org.gnome.desktop.interface color-scheme` is `'default'` (Not `'prefer-dark'`)**:
  - Setting `color-scheme` to `'prefer-dark'` broadcasts dark mode via `xdg-desktop-portal`. MATLAB R2026a reads this portal setting when set to "Match system theme" and changes `groot` figure defaults so `figure`/`plot()` render with dark charcoal backgrounds (`[0.15 0.15 0.15]`). Keeping `color-scheme` at `'default'` ensures MATLAB plots render on clean white backgrounds while Qt (`qt6ct`) and Quickshell remain dark.
- **Why SDDM Uses `DisplayServer=x11` Instead of `wayland`**:
  - Setting `DisplayServer=wayland` in `/etc/sddm.conf.d/10-impasto.conf` requires an external Wayland greeter compositor (`weston`, `kwin_wayland`, or `labwc`). Without one installed, SDDM fails to start the login screen. Additionally, `QT_SCALE_FACTOR=1.4` must not be combined with `QT_SCREEN_SCALE_FACTORS=1.4` in Qt6 (which compounds to `1.96x`).
- **Why `brightness.sh` Must Use `exec inotifywait`**:
  - Removing `exec` before `inotifywait` to keep a bash `EXIT` trap alive causes `quickshell` reloads (`SIGTERM` to the parent `brightness.sh` subshell) to orphan `inotifywait` child processes on every reload. Always use `exec inotifywait` and match `brightness\.sh|inotifywait` when cleaning up stale PIDs.
- **Quickshell QJSEngine & `qmllint` Constraints**:
  - Quickshell's Qt6 QJSEngine does **not** implement browser Web APIs like `structuredClone()` (`ReferenceError`). Use manual shallow/deep cloning or `JSON.parse(JSON.stringify())`.
  - `IpcHandler` functions with arguments must have explicit QML parameter types (e.g., `function setRedactMode(active: string)`), otherwise Quickshell rejects registration (`QVariant cannot be used across IPC`). However, omit `: void` return type annotations so `qmllint` passes without warnings.
  - Every singleton listed in `src/quickshell/qmldir` is eagerly loaded at Quickshell startup; deleting a singleton `.qml` file without removing its entry from `qmldir` causes a fatal startup crash.
- **XDG Portal Configuration Shadowing (`~/.config/xdg-desktop-portal/portals.conf`)**:
  - `xdg-desktop-portal` stops scanning system portal configs (`/usr/share/xdg-desktop-portal/niri-portals.conf`) as soon as `~/.config/xdg-desktop-portal/portals.conf` exists. Always include `default=gnome;gtk;`, `Access=gtk;`, `Notification=gtk;`, and `Secret=gnome-keyring;` alongside `FileChooser=ski;`.
- **Systemd Drop-in List Reset (`timesyncd.conf.d`)**:
  - In systemd drop-in files (`/etc/systemd/timesyncd.conf.d/local.conf`), setting `NTP=time.google.com` appends to the compiled-in default (`time.cloudflare.com`). Always precede custom list values with an empty `NTP=` line to clear the default list first.
