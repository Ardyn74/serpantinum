# MATLAB on Wayland & VS Code Integration

Configuration, launcher scripts, and fixes for running MATLAB (R2026a+) seamlessly under Wayland compositors (Niri, Hyprland) with the official VS Code MATLAB extension.

---

## The Issues & Solutions

### 1. Wayland & Embedded Browser (CEF) Crashes
* **Issue:** MATLAB uses Chromium Embedded Framework (CEF) for its UI, which fails or crashes when launched directly under native Wayland or standard XWayland without rootful isolation.
* **Fix:** A dedicated `xwayland-satellite :12` instance managed via systemd user service (`matlab-satellite.service`). The launcher starts and checks the `:12` display socket before executing MATLAB with `DISPLAY=:12`.

### 2. Licensing Segmentation Fault on Modern Linux (glibc 2.44+)
* **Issue:** On modern Linux distributions (such as Arch / CachyOS with glibc 2.44+), the default FlexLM license manager crashes on launch with:
  ```text
  Segmentation violation in lc_new_job in libmwlmgrimpl.so
  ```
* **Fix:** Add `-licmode onlinelicensing` to bypass the local FlexLM daemon and authenticate via MathWorks online licensing.

### 3. Outdated C++ Runtime Symbols
* **Issue:** MATLAB bundles an older `libstdc++` in its installation directory, causing symbol lookup errors when interfacing with system graphics drivers (Mesa, NVIDIA, Vulkan).
* **Fix:** Preload the system runtime: `LD_PRELOAD=/usr/lib/libstdc++.so.6`.

### 4. VS Code Extension Opening Unwanted GUI Windows
* **Issue:** The official VS Code MATLAB extension starts a background language server using `-nodesktop`. However, hardcoding `-desktop` in custom launcher wrappers causes MATLAB to pop up its entire desktop GUI window instead of running invisibly.
* **Fix:** The launcher dynamically checks arguments (`"$@"`) for headless flags (`-nodesktop`, `-nodisplay`, `-batch`). If present, `-desktop` is omitted, allowing MATLAB to run headlessly in the background as intended.

---

## File Structure

* **`matlab-launcher`**: Smart executable wrapper handling DISPLAY socket checks, LD_PRELOAD, online licensing, and headless argument filtering.
* **`matlab-satellite.service`**: Systemd user service running `xwayland-satellite :12`.
* **`matlab.desktop`**: XDG desktop entry for application menus and file associations (`.m`, `.mlx`, `.mat`).
* **`setup.sh`**: Automated installation script.

---

## Installation

Run the setup script from this directory:

```bash
chmod +x setup.sh
./setup.sh
```

This will:
1. Install `matlab-launcher` to `~/.local/bin/matlab-launcher`.
2. Create the symlink `~/.local/bin/matlab -> ~/.local/bin/matlab-launcher`.
3. Install `matlab.desktop` to `~/.local/share/applications/matlab.desktop`.
4. Install and enable `matlab-satellite.service` under `~/.config/systemd/user/`.

---

## Recommended VS Code Settings

Add the following to your VS Code `settings.json` (`Ctrl+Shift+P` > `Preferences: Open User Settings (JSON)`):

```json
{
  "MATLAB.matlabConnectionTiming": "onStart",
  "terminal.integrated.commandsToSkipShell": ["matlab.interrupt"]
}
```

* **`onStart`**: Launches MATLAB headlessly in the background when a `.m` file is opened, giving immediate autocompletion and workspace variable inspection.
* **`onDemand`**: Alternative setting if you only want MATLAB to start when you explicitly click "Run" or "Debug".
