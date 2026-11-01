# AI Agent Operational Rules (`Ardyn74/serpantinum`)

You are working in `/home/abhay/serpantinum`, a customized fork of the Serpantinum desktop shell and dotfile suite specialized **exclusively for CachyOS / Arch Linux (`pacman` + `systemd`) and the Niri Wayland compositor**.

Follow these rules strictly on every task.

---

## 1. Platform & Architecture Constraints

- **Target OS & Init**: CachyOS / Arch Linux (`pacman`, AUR helpers `paru`/`yay`, `systemd`). Do **not** add NixOS, Fedora (`dnf`), Void (`xbps`), OpenRC, runit, or dinit code paths.
- **Target Compositor**: **Niri (`niri`) only**. Do **not** add Hyprland, Sway, or Mango compositor branches, scripts, or QML singletons.
- **Core Stack**:
  - Desktop Shell: Quickshell (Qt6 / QML) launched via `serpantinumd` (`~/.local/share/serpantinum/bin/serpantinumd`).
  - File Manager & File Picker Portal: **Ski** (`~/.local/bin/ski`, v0.4.3).
  - Audio Engine: **`serpantinum-audio`** (`~/.local/bin/serpantinum-audio`, v0.2.0) — replaces EasyEffects.
  - Terminal: **Kitty** (`kitty`).

---

## 2. Shell Environment & Non-Interactive Command Caveats

- **User Interactive Shell vs. Agent Subshell**:
  - The user's interactive shell is `/bin/fish` (`~/.config/fish/config.fish` -> `/usr/share/cachyos-fish-config/cachyos-config.fish`), where `ls` is aliased to `eza` and `~/.local/bin` is in `PATH`.
  - Agent command execution tools run in **non-interactive `/bin/bash`**, where `~/.bashrc` exits immediately at `[[ $- != *i* ]] && return`.
  - Always ensure `/home/abhay/.local/bin` is in `PATH` (`export PATH="$HOME/.local/bin:$PATH"`) or invoke binaries by path when calling `serpantinum`, `serpantinumd`, `ski`, `serpantinum-audio`, `matlab`, or `agy`.
- **Testing `quickshell` from the CLI**:
  - Never run `quickshell -p /home/abhay/serpantinum/src/quickshell/Shell.qml` without setting `SERPANTINUM_DIR`, because `src/scripts/caching.sh` defaults `SERPANTINUM_DIR` to `$HOME/.local/share/serpantinum/src` and relative `.qsb` shader paths will fail if out of sync.
  - To validate QML syntax statically, run:
    ```bash
    qmllint <path/to/file.qml>
    ```
  - To test runtime startup cleanly:
    ```bash
    SERPANTINUM_DIR=/home/abhay/serpantinum/src quickshell -p /home/abhay/serpantinum/src/quickshell/Shell.qml
    ```

---

## 3. Source-of-Truth & Live Deployment Sync Rules

The live desktop session does **not** run directly out of `/home/abhay/serpantinum`. Files are deployed (copied) to runtime locations. Whenever you modify files, keep the repository and live runtime synchronized:

| Component | Repo Source of Truth | Live Runtime Location | Sync / Reload Command |
| :--- | :--- | :--- | :--- |
| **Quickshell QML & Scripts** | `/home/abhay/serpantinum/src/` | `~/.local/share/serpantinum/src/` | `rsync -a --delete /home/abhay/serpantinum/src/ ~/.local/share/serpantinum/src/ && serpantinum reload` |
| **CLI & Daemon Binaries** | `/home/abhay/serpantinum/bin/` | `~/.local/share/serpantinum/bin/` (symlinked to `~/.local/bin/` & `/usr/local/bin/`) | `rsync -a --delete /home/abhay/serpantinum/bin/ ~/.local/share/serpantinum/bin/ && serpantinumd restart` |
| **Niri Configuration** | `/home/abhay/serpantinum/compositors/niri/` | `~/.config/niri/` | Validate with `niri validate`, sync both directions, and run `niri msg action load-config-file` |
| **MATLAB Wayland Wrapper** | `/home/abhay/serpantinum/config/matlab/` | `~/.local/bin/matlab-launcher`, `~/.config/systemd/user/matlab-satellite.service`, `~/.local/share/applications/matlab.desktop` | Run `./config/matlab/setup.sh` or copy directly |
| **Kitty / Cava / Fastfetch** | `/home/abhay/serpantinum/config/{kitty,cava,fastfetch}/` | `~/.config/{kitty,cava,fastfetch}/` | Copy modified files to both locations (keep runtime-generated `~/.config/kitty/colors.conf` and `~/.config/cava/themes/` untracked) |
| **Serpantinum Settings** | `/home/abhay/serpantinum/config/serpantinum/settings.json` (clean template only) | `~/.config/serpantinum/settings.json` (user state + geolocation) | **NEVER** copy live `~/.config/serpantinum/settings.json` wholesale into the repo |
| **System Configs (`/etc`)** | `config/udev/99-battery-charge-limit.rules`, `config/sddm/themes/impasto/`, `install/modules/deploy.sh` | `/etc/udev/rules.d/99-battery-charge-limit.rules`, `/usr/share/sddm/themes/impasto/`, `/etc/sddm.conf.d/10-impasto.conf` | Requires `sudo` to deploy to `/etc` or `/usr/share/sddm` |

---

## 4. QML, Shell Script & System Guardrails

1. **`qmldir` Integrity**:
   - Every singleton declared in `src/quickshell/qmldir` (or subdirectory `qmldir` files) **must** exist on disk. Deleting a singleton `.qml` file without removing its `qmldir` declaration and all QML references will crash Quickshell on startup.
2. **Qt6 QJSEngine & `qmllint` Compatibility**:
   - Do **not** use browser-only APIs such as `structuredClone()` in QML/JS (`ReferenceError` in QJSEngine).
   - `IpcHandler` functions that accept parameters must declare explicit QML parameter types (e.g., `function setRedactMode(active: string)`), otherwise Quickshell fails to expose them over IPC (`QVariant cannot be used across IPC`). Omit `: void` return type annotations so `qmllint` passes cleanly.
   - Bound large dynamic images (`Image`, `AnimatedImage`) with `asynchronous: true` and `sourceSize` scaled by `Screen.devicePixelRatio` (or use `BoundedImage`).
3. **Background Watcher Process Lifecycle**:
   - In watcher scripts spawned by QML `Process` (such as `src/scripts/brightness.sh`), always use `exec` before long-running binaries (`exec inotifywait ...`) so `SIGTERM` on shell reload kills the binary directly rather than leaving orphaned child processes.
   - Always verify `/proc/$PID/cmdline` before sending `kill` signals to PIDs read from cache/state files.
4. **Audio & Equalizer State**:
   - `src/quickshell/singletons/audio/Audio.qml` must filter out internal `serpantinum-audio` nodes (`serpantinum_output`, `serpantinum_sink`, `serpantinum-audio-test`) in `isSerpantinumStream()` and `Audio.outputs` so `cava` does not run at 60 FPS during silence.
   - All writes to `$QS_RUN_MUSIC/eq_state.json` in `src/quickshell/media/equalizer.sh` must acquire the `flock` lock on `$QS_RUN_MUSIC/eq_state.lock` and write atomically via a temporary file.
5. **XDG Desktop Portals & Dark Mode**:
   - `~/.config/xdg-desktop-portal/portals.conf` shadows `/usr/share/xdg-desktop-portal/niri-portals.conf`. Always retain `default=gnome;gtk;`, `Access=gtk;`, `Notification=gtk;`, and `Secret=gnome-keyring;` alongside `org.freedesktop.impl.portal.FileChooser=ski;`.
   - Do **not** set `gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'` globally; keep it at `'default'` so MATLAB R2026a figures (`groot`) render with white backgrounds.
6. **MATLAB Launcher (`config/matlab/matlab-launcher`)**:
   - Never redirect stdout/stderr of the final `exec env ... matlab` call when running in a terminal (`[ -t 1 ]`) or headless mode (`-nodesktop`, `-nodisplay`, `-batch`, `-help`, `-version`), and only start `matlab-satellite.service` (`xwayland-satellite :12`) for GUI launches.

---

## 5. Git & GitHub Workflow Rules

- **Remotes & Branch**:
  - Active branch: `master`.
  - Push/fetch target: `origin` (`https://github.com/Ardyn74/serpantinum.git`).
  - Upstream reference: `upstream` (`https://github.com/ilyamiro/serpantinum.git`). Never push to `upstream`.
- **Commit Conventions**:
  - Use Conventional Commits matching the repository history: `feat(<scope>): ...`, `fix(<scope>): ...`, `perf(<scope>): ...`, `refactor(<scope>): ...`, `docs(<scope>): ...`, `chore(<scope>): ...`.
- **Upstream Sync Rules**:
  - Prefer `git cherry-pick -x <sha>` when porting specific fixes from `upstream/master`.
  - If merging `upstream/master`, never re-introduce deleted NixOS (`flake.*`, `nix/`), Fedora (`dnf.sh`), Void (`void.sh`), or non-Niri compositor (`hyprland`, `sway`, `mango`, `MangoState.qml`) files.
- **Secrets, PII & Untracked Files (NEVER Commit)**:
  - Never commit live `~/.config/serpantinum/settings.json` (contains IP address, latitude/longitude, city/postal/ASN geolocation from `ipapi.co`).
  - Never commit API keys, tokens, `.env` files, backup files (`*.bak`), runtime shader caches (`*.qsb` if untracked), or temporary root helper scripts.
