# MATLAB Configuration & Wayland Fixes

This document details the configuration, launcher workarounds, and VS Code integration for running MATLAB (R2026a+) on Wayland compositors (such as Niri or Hyprland) on Arch / CachyOS.

All configuration files and the installation script are located under [`config/matlab/`](../config/matlab/).

---

## Overview of Fixes

| Problem | Cause | Solution |
| :--- | :--- | :--- |
| **CEF Window / UI Crashes** | Incompatibility with native Wayland compositors. | Run via `xwayland-satellite :12` using `matlab-satellite.service`. |
| **Segmentation Fault on Startup** | FlexLM `lc_new_job` crash in `libmwlmgrimpl.so` on glibc 2.44+. | Launch with `-licmode onlinelicensing`. |
| **Graphics / C++ Symbol Errors** | Bundled outdated `libstdc++` in MATLAB root. | Export `LD_PRELOAD=/usr/lib/libstdc++.so.6`. |
| **Unwanted GUI Window in VS Code** | Hardcoded `-desktop` in wrapper overriding extension's `-nodesktop`. | Dynamically filter `-desktop` when headless arguments are detected. |

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

With the launcher's headless argument detection, MATLAB runs as an invisible background daemon. When VS Code is closed, the background process is terminated cleanly.
