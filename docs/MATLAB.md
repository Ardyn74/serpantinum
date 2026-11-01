# MATLAB Configuration & Wayland Fixes

This document details the configuration, launcher workarounds, and VS Code integration for running MATLAB (R2026a+) on the **Niri** Wayland compositor on CachyOS / Arch Linux.

All configuration files and the installation script are located under [`config/matlab/`](../config/matlab/).

---

## Overview of Fixes

| Problem | Cause | Solution |
| :--- | :--- | :--- |
| **CEF Window / UI Crashes** | Incompatibility with native Wayland compositors. | Run via `xwayland-satellite :12` using `matlab-satellite.service`. Satellite service starts on-demand for GUI launches only. |
| **Segmentation Fault on Startup** | FlexLM `lc_new_job` crash in `libmwlmgrimpl.so` on glibc 2.44+. | Launch with `-licmode onlinelicensing`. |
| **Graphics / C++ Symbol Errors** | Bundled outdated `libstdc++` in MATLAB root. | Dynamically detect and preload system runtime (`/usr/lib/libstdc++.so.6` or `/usr/lib64/libstdc++.so.6`). |
| **Unwanted GUI Window in VS Code** | Hardcoded `-desktop` in wrapper overriding extension's `-nodesktop`. | Dynamically filter `-desktop` when headless arguments (`-nodesktop`, `-nodisplay`, `-batch`, `-help`, `-version`) are detected. |
| **Swallowed CLI & Terminal Output** | Unconditional log redirection (`>> $LOG 2>&1`) in previous wrappers. | Stream stdout/stderr directly when attached to a TTY (`[ -t 1 ]`) or running headless CLI/batch commands, redirecting only GUI launches to `$XDG_STATE_HOME/matlab-launcher.log`. |
| **File Association & Execution** | Missing MIME associations in `.desktop` file. | Added `text/x-matlab;application/x-matlab-data;` and PATH-agnostic launcher execution. |

---

## Environment Variables

The launcher supports the following overrides:
- `MATLAB_BIN`: Path to custom MATLAB executable (defaults to `$HOME/.local/opt/MATLAB/R2026/bin/matlab`).
- `DISPLAY`: Defaults to `:12` for the satellite display.
- `XDG_STATE_HOME`: Directory for launch logs (defaults to `~/.local/state`).

---

## Setup & Deployment

To deploy the MATLAB configurations and services:

```bash
cd config/matlab
chmod +x setup.sh
./setup.sh
```

---

## VS Code MATLAB Integration

The official MATLAB extension (`mathworks.language-matlab`) runs a Node.js Language Server that connects to a background MATLAB engine for live code completion, linting, debugging, and workspace variable inspection.

With the launcher's headless argument detection and direct stdout/stderr streaming, MATLAB runs smoothly as an invisible background daemon without swallowing communication streams or spawning graphical satellite instances unnecessarily. When VS Code is closed, the background process is terminated cleanly.
