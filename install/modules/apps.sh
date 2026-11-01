#!/usr/bin/env bash

OPT_DESKTOP_APPS=true

OFFICIAL_APPS_PKGS=(
    # Desktop & Media
    "spotify-launcher"
    "amberol"
    "decibels"
    "showtime"
    "loupe"
    "snapshot"
    "papers"
    "gnome-calculator"
    "gnome-text-editor"
    "gnome-console"
    "switcheroo"
    "warp"
    "fragments"

    # LaTeX & Typesetting
    "texstudio"
    "texlive-basic"
    "texlive-bibtexextra"
    "texlive-fontsextra"
    "texlive-fontsrecommended"
    "texlive-fontutils"
    "texlive-formatsextra"
    "texlive-latex"
    "texlive-latexextra"
    "texlive-latexrecommended"
    "texlive-mathscience"
    "texlive-pictures"
    "texlive-plaingeneric"
    "texlive-publishers"

    # Gaming & Compatibility
    "cachyos-gaming-meta"
    "faugus-launcher"
    "xorg-xwayland"
    "xwayland-satellite"

    # CLI & Developer Tools
    "github-cli"
    "uv"
)

AUR_APPS_PKGS=(
    "visual-studio-code-bin"
    "matlab-mpm"
)

install_antigravity_app() {
    local opt_dir="$HOME/.local/opt/Antigravity-x64"
    local bin_link="$HOME/.local/bin/antigravity"
    local desktop_file="$HOME/.local/share/applications/antigravity.desktop"
    local icon_file="$HOME/.local/share/icons/antigravity.png"

    echo -e "\n\e[36m[ INFO ]\e[0m Checking Antigravity Desktop Application..."

    local releases_json
    releases_json=$(curl -fsSL --connect-timeout 10 --retry 3 "https://antigravity-hub-auto-updater-974169037036.us-central1.run.app/releases" 2>/dev/null || true)
    if [ -z "$releases_json" ]; then
        echo -e "\e[33m[ WARN ]\e[0m Failed to query Antigravity release API, skipping download..."
        return 0
    fi

    local version execution_id
    version=$(jq -r '.[0].version // empty' <<< "$releases_json")
    execution_id=$(jq -r '.[0].execution_id // empty' <<< "$releases_json")

    if [ -z "$version" ] || [ -z "$execution_id" ]; then
        echo -e "\e[33m[ WARN ]\e[0m Could not parse Antigravity version information, skipping..."
        return 0
    fi

    echo -e "\e[36m[ INFO ]\e[0m Latest Antigravity release: v$version ($execution_id)"

    if pgrep -x "antigravity" >/dev/null; then
        echo -e "\e[33m[ INFO ]\e[0m Antigravity is currently running; keeping active installation"
        return 0
    fi

    local current_ver=""
    if [ -f "$opt_dir/.app_version" ]; then
        current_ver=$(head -n 1 "$opt_dir/.app_version" 2>/dev/null || true)
    fi

    if [ "$current_ver" = "$version" ] && [ -x "$opt_dir/antigravity" ] && [ -f "$desktop_file" ]; then
        echo -e "\e[32m[ OK ]\e[0m Antigravity v$version is already up to date"
        return 0
    fi

    local dl_url="https://storage.googleapis.com/antigravity-public/antigravity-hub/${version}-${execution_id}/linux-x64/Antigravity.tar.gz"
    local tmp_tar="${XDG_CACHE_HOME:-$HOME/.cache}/Antigravity-${version}.tar.gz"

    mkdir -p "$(dirname "$tmp_tar")" "$HOME/.local/opt" "$HOME/.local/bin" "$HOME/.local/share/applications" "$HOME/.local/share/icons"

    echo -e "\e[36m[ INFO ]\e[0m Downloading Antigravity v$version from Google Cloud Storage..."
    if ! curl -# -L --connect-timeout 15 --retry 3 "$dl_url" -o "$tmp_tar"; then
        echo -e "\e[31m[ FAILED ]\e[0m Failed to download Antigravity archive"
        rm -f "$tmp_tar"
        return 1
    fi

    echo -e "\e[36m[ INFO ]\e[0m Extracting Antigravity..."
    rm -rf "$opt_dir"
    tar -xzf "$tmp_tar" -C "$HOME/.local/opt/"
    chmod +x "$opt_dir/antigravity"
    printf '%s\n' "$version" > "$opt_dir/.app_version"
    rm -f "$tmp_tar"

    # Setup application icon
    if [ -f "$PROJECT_ROOT/install/assets/antigravity.png" ]; then
        cp "$PROJECT_ROOT/install/assets/antigravity.png" "$icon_file"
        cp "$PROJECT_ROOT/install/assets/antigravity.png" "$opt_dir/antigravity.png" 2>/dev/null || true
    elif [ -f "$opt_dir/antigravity.png" ]; then
        cp "$opt_dir/antigravity.png" "$icon_file"
    fi

    # Symlink binary to user path
    ln -sf "$opt_dir/antigravity" "$bin_link"

    # Setup desktop entry
    cat << EOF > "$desktop_file"
[Desktop Entry]
Name=Antigravity
Comment=Antigravity - Agentic Desktop Application
Exec=$opt_dir/antigravity %U
Icon=$icon_file
Terminal=false
Type=Application
StartupNotify=true
StartupWMClass=antigravity
Categories=Development;IDE;Utility;
EOF
    chmod 644 "$desktop_file"

    echo -e "\e[32m[ OK ]\e[0m Antigravity v$version successfully installed to $opt_dir"
}

install_desktop_apps() {
    if [ "$OPT_DESKTOP_APPS" != true ]; then
        echo -e "\n\e[33m[ SKIP ]\e[0m Desktop Applications Suite installation skipped (disabled)"
        return 0
    fi

    echo -e "\n\e[36m=================================================================\e[0m"
    echo -e "\e[34m::\e[0m \e[1mInstalling Desktop Applications Suite\e[0m"
    echo -e "\e[36m=================================================================\e[0m"

    local missing_raw
    missing_raw=$(pm_missing_pkgs "${OFFICIAL_APPS_PKGS[@]}")

    local missing_official=()
    while IFS= read -r pkg; do
        [[ -n "$pkg" ]] && missing_official+=("$pkg")
    done <<< "$missing_raw"

    local SAFE_JOBS=$(( $(nproc) / 2 ))
    [[ $SAFE_JOBS -lt 1 ]] && SAFE_JOBS=1
    [[ $SAFE_JOBS -gt 4 ]] && SAFE_JOBS=4

    if [ ${#missing_official[@]} -gt 0 ]; then
        echo -e "\n\e[36m[ INFO ]\e[0m Installing official packages: ${#missing_official[@]} to install..."
        for pkg in "${missing_official[@]}"; do
            echo -e "\e[34m::\e[0m Installing $pkg..."
            pm_install_pkg "$pkg" "$SAFE_JOBS" || true
        done
    else
        echo -e "\n\e[32m[ OK ]\e[0m All official desktop packages are already installed"
    fi

    # AUR packages
    echo -e "\n\e[36m[ INFO ]\e[0m Checking AUR packages (${AUR_APPS_PKGS[*]})..."
    for aur_pkg in "${AUR_APPS_PKGS[@]}"; do
        if ! pm_is_installed "$aur_pkg"; then
            echo -e "\e[34m::\e[0m Installing AUR package: $aur_pkg..."
            pm_install_pkg "$aur_pkg" "$SAFE_JOBS" || true
        else
            echo -e "\e[32m[ OK ]\e[0m AUR package $aur_pkg is already installed"
        fi
    done

    # Standalone Antigravity Desktop App
    install_antigravity_app
}
