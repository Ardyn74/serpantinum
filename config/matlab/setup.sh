#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing MATLAB Wayland & VS Code integration..."

# Ensure target directories exist
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/share/applications"
mkdir -p "$HOME/.config/systemd/user"
mkdir -p "$HOME/.local/state"

# Install launcher script and symlink
cp -f "$SCRIPT_DIR/matlab-launcher" "$HOME/.local/bin/matlab-launcher"
chmod +x "$HOME/.local/bin/matlab-launcher"
ln -sf "$HOME/.local/bin/matlab-launcher" "$HOME/.local/bin/matlab"

# Install desktop entry
cp -f "$SCRIPT_DIR/matlab.desktop" "$HOME/.local/share/applications/matlab.desktop"
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications" || true
fi

# Install systemd service for xwayland-satellite
cp -f "$SCRIPT_DIR/matlab-satellite.service" "$HOME/.config/systemd/user/matlab-satellite.service"
systemctl --user daemon-reload
systemctl --user enable matlab-satellite.service

echo "MATLAB fixes successfully installed!"
echo "Check README.md in this directory for detailed documentation and VS Code settings."
