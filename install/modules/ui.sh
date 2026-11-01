#!/usr/bin/env bash

RESET=$'\e[0m'
BOLD=$'\e[1m'
DIM=$'\e[2m'
C_BLUE=$'\e[34m'
C_CYAN=$'\e[36m'
C_GREEN=$'\e[32m'
C_YELLOW=$'\e[33m'
C_RED=$'\e[31m'
C_MAGENTA=$'\e[35m'

ENABLE_TELEMETRY=true
INSTALL_FULL_WALLPAPERS=true
SELECTED_COMPOSITORS=()
DETECTED_COMPOSITOR_LABEL=""
MULTIPLE_COMPOSITORS_DETECTED=false
UNSUPPORTED_COMPOSITOR_DETECTED=false
IS_REINSTALL=false

OPT_SDDM=true
REPLACE_DM=false
SDDM_WAYLAND="$PM_SDDM_WAYLAND_DEFAULT"

USER_NAME="${USER:-$(whoami)}"
OS_NAME=$(grep '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
[[ -z "$OS_NAME" ]] && OS_NAME="$(t "installer.os.default_os")"
CPU_INFO=$(grep -m 1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs || true)
[[ -z "$CPU_INFO" ]] && CPU_INFO="$(t "installer.os.unknown_cpu")"

GPU_RAW=$(lspci -nn 2>/dev/null | grep -iE 'vga|3d|display' || true)
GPU_INFO=$(echo "$GPU_RAW" | cut -d: -f3 | sed -E 's/ \(rev [0-9a-f]+\)//g' | xargs)
[[ -z "$GPU_INFO" ]] && GPU_INFO="$(t "installer.os.unknown_gpu")"

cleanup_terminal() {
    printf "\e[?25h" 2>/dev/null || true
    stty echo icanon 2>/dev/null || true
}
trap cleanup_terminal EXIT INT TERM

read_key() {
    local key=""
    local rest=""
    IFS= read -rsn1 key 2>/dev/null
    if [[ "$key" == $'\x1b' ]]; then
        read -rsn2 -t 0.05 rest 2>/dev/null
        if [[ "$rest" == "[A" || "$rest" == "OA" ]]; then
            echo "UP"
            return
        elif [[ "$rest" == "[B" || "$rest" == "OB" ]]; then
            echo "DOWN"
            return
        elif [[ "$rest" == "[C" || "$rest" == "OC" ]]; then
            echo "RIGHT"
            return
        elif [[ "$rest" == "[D" || "$rest" == "OD" ]]; then
            echo "LEFT"
            return
        elif [[ "$rest" == *"["* ]]; then
            local trailing=""
            while read -rsn1 -t 0.05 trailing 2>/dev/null; do
                [[ -z "$trailing" ]] && break
            done
            echo "ESC"
            return
        elif [[ -z "$rest" ]]; then
            echo "ESC"
            return
        fi
        echo "ESC"
        return
    elif [[ -z "$key" || "$key" == $'\n' || "$key" == $'\r' ]]; then
        echo "ENTER"
        return
    elif [[ "$key" == " " ]]; then
        echo "SPACE"
        return
    fi
    echo "$key"
}

init_compositor_detection() {
    SELECTED_COMPOSITORS=("niri")
    DETECTED_COMPOSITOR_LABEL="niri"
    MULTIPLE_COMPOSITORS_DETECTED=false
    UNSUPPORTED_COMPOSITOR_DETECTED=false
}

prompt_compositor_selection() {
    SELECTED_COMPOSITORS=("niri")
    DETECTED_COMPOSITOR_LABEL="niri"
    return 0
}

draw_banner() {
    clear
    printf "%s%s" "$BOLD" "$C_CYAN"
    cat << "EOF"
███████╗███████╗██████╗ ██████╗  █████╗ ███╗   ██╗████████╗██╗███╗   ██╗██╗   ██╗███╗   ███╗
██╔════╝██╔════╝██╔══██╗██╔══██╗██╔══██╗████╗  ██║╚══██╔══╝██║████╗  ██║██║   ██║████╗ ████║
███████╗█████╗  ██████╔╝██████╔╝███████║██╔██╗ ██║   ██║   ██║██╔██╗ ██║██║   ██║██╔████╔██║
╚════██║██╔══╝  ██╔══██╗██╔═══╝ ██╔══██║██║╚██╗██║   ██║   ██║██║╚██╗██║██║   ██║██║╚██╔╝██║
███████║███████╗██║  ██║██║     ██║  ██║██║ ╚████║   ██║   ██║██║ ╚████║╚██████╔╝██║ ╚═╝ ██║
╚══════╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝
EOF
    printf "%s\n" "$RESET"

    local OSC8_GH=$'\e]8;;https://github.com/'"${REPO_SLUG}"$'\a'
    local OSC8_END=$'\e]8;;\a'

    printf "\033[K%s--------------------------------------------------------------------------------%s\n" "$C_BLUE" "$RESET"
    printf "\033[K%s%s $(t "installer.ui.github")%s   %shttps://github.com/%s%s\n" "$BOLD" "$C_GREEN" "$RESET" "$OSC8_GH" "$REPO_SLUG" "$OSC8_END"
    printf "\033[K%s--------------------------------------------------------------------------------%s\n" "$C_BLUE" "$RESET"
    printf "\033[K%s $(t "installer.ui.user")%s %-25s | %s$(t "installer.ui.os")%s %s\n" "$BOLD" "$RESET" "$USER_NAME" "$BOLD" "$RESET" "$OS_NAME"
    printf "\033[K%s $(t "installer.ui.cpu")%s  %-25s | %s$(t "installer.ui.gpu")%s %s\n" "$BOLD" "$RESET" "$CPU_INFO" "$BOLD" "$RESET" "$GPU_INFO"
    printf "\033[K%s--------------------------------------------------------------------------------%s\n" "$C_BLUE" "$RESET"
    printf "\033[K%s $(t "installer.ui.target_version")%s %-10s (%-7s) | %s$(t "installer.ui.install_mode")%s %s\n" "$BOLD" "$RESET" "$TARGET_VERSION" "$TARGET_COMMIT" "$BOLD" "$RESET" "$INSTALL_STATE"
    printf "\033[K%s================================================================================%s\n\n" "$C_BLUE" "$RESET"
}

show_package_overview() {
    local target_list=("${REQUIRED_PKGS[@]}")
    for comp in "${SELECTED_COMPOSITORS[@]}"; do
        target_list+=("$comp")
    done
    if [ "$OPT_SDDM" = true ]; then
        local sddm_pkgs=()
        mapfile -t sddm_pkgs < <(sddm_packages)
        target_list+=("${sddm_pkgs[@]}")
    fi
    target_list+=("${PM_EXTRA_PKGS[@]}")
    if [ "$OPT_DESKTOP_APPS" = true ]; then
        target_list+=("${OFFICIAL_APPS_PKGS[@]}")
    fi

    local missing_raw
    missing_raw=$(pm_missing_pkgs "${target_list[@]}")

    declare -A is_missing
    while IFS= read -r p; do
        [[ -n "$p" ]] && is_missing["$p"]=1
    done <<< "$missing_raw"

    local overview_items=()
    for pkg in "${target_list[@]}"; do
        if [[ -n "${is_missing[$pkg]}" ]]; then
            overview_items+=("$(t "installer.ui.package_missing" "pkg=$pkg")")
        else
            overview_items+=("$(t "installer.ui.package_installed" "pkg=$pkg")")
        fi
    done

    cleanup_terminal
    printf "%s\n" "${overview_items[@]}" | fzf \
        --ansi \
        --layout=reverse \
        --border=rounded \
        --margin=1,2 \
        --height=25 \
        --prompt="$(t "installer.ui.packages_prompt")" \
        --header="$(t "installer.ui.packages_header")" > /dev/null || true
    stty -echo icanon 2>/dev/null || true
    printf "\e[?25l"
}

manage_compositors_menu() {
    draw_banner
    stty -echo 2>/dev/null || true
    printf "\e[?25l"
    printf "%s%sCompositor Configuration%s\n\n" "$BOLD" "$C_CYAN" "$RESET"
    printf "  %s[✓] Niri (Wayland)%s - Active & Exclusively Supported\n\n" "$C_GREEN" "$RESET"
    printf "  %sSerpantinum is specialized exclusively for Niri on CachyOS / Arch Linux.%s\n\n" "$DIM" "$RESET"
    printf "  Press %s[Enter]%s or %s[Esc]%s to return.\n" "$BOLD" "$RESET" "$BOLD" "$RESET"

    while true; do
        local key
        key=$(read_key)
        case "$key" in
            ENTER|SPACE|ESC|[qQ]) break ;;
        esac
    done
}

manage_sddm_menu() {
    draw_banner
    stty -echo 2>/dev/null || true
    printf "\e[?25l"
    printf "%s%s$(t "installer.ui.sddm_title")%s\n\n" "$BOLD" "$C_CYAN" "$RESET"

    local current_dm=""
    local dms=("gdm" "gdm3" "lightdm" "sddm" "lxdm" "lxdm-gtk3" "ly")
    for dm in "${dms[@]}"; do
        if systemctl is-enabled "$dm.service" &>/dev/null || systemctl is-active "$dm.service" &>/dev/null; then
            current_dm="$dm"
            break
        fi
    done

    if [ -n "$current_dm" ]; then
        printf "$(t "installer.ui.sddm_detected_active" "dm=${BOLD}${C_YELLOW}%s${RESET}")\n\n" "$current_dm"
    else
        printf "%s\n\n" "$(t "installer.ui.sddm_detected_none")"
    fi

    local cursor=0
    local rendered_lines=0

    while true; do
        local S_SDDM="${DIM}[Disabled]${RESET}"
        local S_RDM="${DIM}[No]${RESET}"
        local S_WAY="${DIM}[X11/Default]${RESET}"

        [ "$OPT_SDDM" = true ] && S_SDDM="${C_GREEN}[Enabled]${RESET}"
        [ "$REPLACE_DM" = true ] && S_RDM="${C_GREEN}[Yes]${RESET}"
        [ "$SDDM_WAYLAND" = true ] && S_WAY="${C_GREEN}[Wayland]${RESET}"

        local items=()
        items+=("1. $(t "installer.ui.sddm_opt_install") $S_SDDM")
        if [ -n "$current_dm" ] && [ "$current_dm" != "sddm" ]; then
            items+=("2. $(t "installer.ui.sddm_opt_disable" "dm=$current_dm") $S_RDM")
        fi
        items+=("3. $(t "installer.ui.sddm_opt_wayland") $S_WAY")
        items+=("4. ${BOLD}${C_GREEN}$(t "installer.ui.done")${RESET}")

        if [ "$rendered_lines" -gt 0 ]; then
            printf "\033[%dA" "$rendered_lines"
        fi

        for i in "${!items[@]}"; do
            if [ "$i" -eq "$cursor" ]; then
                printf "\r\033[K%s%s ▸ %s%s\n" "$BOLD" "$C_CYAN" "$RESET" "${items[$i]}"
            else
                printf "\r\033[K    %s\n" "${items[$i]}"
            fi
        done
        rendered_lines=${#items[@]}

        local key
        key=$(read_key)

        case "$key" in
            UP|[kK])
                if [ "$cursor" -gt 0 ]; then
                    cursor=$(( cursor - 1 ))
                else
                    cursor=$(( ${#items[@]} - 1 ))
                fi
                ;;
            DOWN|[jJ])
                if [ "$cursor" -lt $(( ${#items[@]} - 1 )) ]; then
                    cursor=$(( cursor + 1 ))
                else
                    cursor=0
                fi
                ;;
            ENTER|SPACE)
                local selected_str="${items[$cursor]}"
                case "$selected_str" in
                    *"1."*)
                        OPT_SDDM=$([ "$OPT_SDDM" = true ] && echo false || echo true)
                        if [ "$OPT_SDDM" = true ] && [ -n "$current_dm" ] && [ "$current_dm" != "sddm" ]; then
                            REPLACE_DM=true
                        fi
                        ;;
                    *"2."*)
                        REPLACE_DM=$([ "$REPLACE_DM" = true ] && echo false || echo true)
                        ;;
                    *"3."*)
                        SDDM_WAYLAND=$([ "$SDDM_WAYLAND" = true ] && echo false || echo true)
                        ;;
                    *"4."*)
                        break
                        ;;
                esac
                ;;
            ESC|[qQ])
                break
                ;;
        esac
    done
}

run_installer_ui() {
    local cursor=0

    while true; do
        draw_banner
        stty -echo 2>/dev/null || true
        printf "\e[?25l"

        local rendered_lines=0

        while true; do
            local COMP_MENU_ITEM="${C_GREEN}Compositor: Niri${RESET}"

            local S_SDDM="${DIM}[OFF]${RESET}"
            local S_TEL="${DIM}[OFF]${RESET}"
            local S_WP="${DIM}[3 Random]${RESET}"
            local S_APPS="${DIM}[OFF]${RESET}"

            [ "$OPT_SDDM" = true ] && S_SDDM="${C_GREEN}[ON]${RESET}"
            [ "$ENABLE_TELEMETRY" = true ] && S_TEL="${C_GREEN}[ON]${RESET}"
            [ "$INSTALL_FULL_WALLPAPERS" = true ] && S_WP="${C_GREEN}[Full Pack]${RESET}"
            [ "$OPT_DESKTOP_APPS" = true ] && S_APPS="${C_GREEN}[ON]${RESET}"

            local total_count=${#REQUIRED_PKGS[@]}
            [ "$OPT_DESKTOP_APPS" = true ] && total_count=$(( total_count + ${#OFFICIAL_APPS_PKGS[@]} + ${#AUR_APPS_PKGS[@]} + 1 ))

            local items=()
            items+=("1. $(t "installer.ui.menu_overview" "count=$total_count")")
            items+=("2. $COMP_MENU_ITEM")
            items+=("3. $(t "installer.ui.menu_sddm") $S_SDDM")
            items+=("4. $(t "installer.ui.menu_wallpapers") $S_WP")
            items+=("5. $(t "installer.ui.menu_telemetry") $S_TEL")
            items+=("6. Desktop Apps Suite $S_APPS")

            if [[ "$INSTALL_STATE" == "current" ]]; then
                items+=("7. ${BOLD}${C_GREEN}$(t "installer.ui.menu_update")${RESET}")
                items+=("8. ${BOLD}${C_YELLOW}$(t "installer.ui.menu_reinstall")${RESET}")
                items+=("9. ${DIM}$(t "installer.ui.menu_exit")${RESET}")
            else
                items+=("7. ${BOLD}${C_GREEN}$(t "installer.ui.menu_install")${RESET}")
                items+=("8. ${DIM}$(t "installer.ui.menu_exit")${RESET}")
            fi

            if [ "$rendered_lines" -gt 0 ]; then
                printf "\033[%dA" "$rendered_lines"
            fi

            for i in "${!items[@]}"; do
                if [ "$i" -eq "$cursor" ]; then
                    printf "\r\033[K%s%s ▸ %s%s\n" "$BOLD" "$C_CYAN" "$RESET" "${items[$i]}"
                else
                    printf "\r\033[K    %s\n" "${items[$i]}"
                fi
            done
            rendered_lines=${#items[@]}

            local key
            key=$(read_key)

            case "$key" in
                UP|[kK])
                    if [ "$cursor" -gt 0 ]; then
                        cursor=$(( cursor - 1 ))
                    else
                        cursor=$(( ${#items[@]} - 1 ))
                    fi
                    ;;
                DOWN|[jJ])
                    if [ "$cursor" -lt $(( ${#items[@]} - 1 )) ]; then
                        cursor=$(( cursor + 1 ))
                    else
                        cursor=0
                    fi
                    ;;
                "1")
                    show_package_overview
                    break
                    ;;
                "2")
                    manage_compositors_menu
                    break
                    ;;
                "3")
                    manage_sddm_menu
                    break
                    ;;
                "4")
                    INSTALL_FULL_WALLPAPERS=$([ "$INSTALL_FULL_WALLPAPERS" = true ] && echo false || echo true)
                    ;;
                "5")
                    ENABLE_TELEMETRY=$([ "$ENABLE_TELEMETRY" = true ] && echo false || echo true)
                    ;;
                "6")
                    OPT_DESKTOP_APPS=$([ "$OPT_DESKTOP_APPS" = true ] && echo false || echo true)
                    ;;
                "7")
                    if [ ${#SELECTED_COMPOSITORS[@]} -eq 0 ]; then
                        printf "\n%s[!] %s%s\n" "$C_RED" "$(t "installer.ui.error_no_compositor")" "$RESET"
                        sleep 1.5
                        break
                    fi
                    IS_REINSTALL=false
                    cleanup_terminal
                    return 0
                    ;;
                "8")
                    if [[ "$INSTALL_STATE" == "current" ]]; then
                        if [ ${#SELECTED_COMPOSITORS[@]} -eq 0 ]; then
                            printf "\n%s[!] %s%s\n" "$C_RED" "$(t "installer.ui.error_no_compositor")" "$RESET"
                            sleep 1.5
                            break
                        fi
                        IS_REINSTALL=true
                        cleanup_terminal
                        return 0
                    else
                        cleanup_terminal
                        clear
                        exit 0
                    fi
                    ;;
                "9")
                    if [[ "$INSTALL_STATE" == "current" ]]; then
                        cleanup_terminal
                        clear
                        exit 0
                    fi
                    ;;
                ESC|[qQ])
                    cleanup_terminal
                    clear
                    exit 0
                    ;;
                ENTER|SPACE)
                    local sel="${items[$cursor]}"
                    case "$sel" in
                        *"1."*)
                            show_package_overview
                            break
                            ;;
                        *"2."*)
                            manage_compositors_menu
                            break
                            ;;
                        *"3."*)
                            manage_sddm_menu
                            break
                            ;;
                        *"4."*)
                            INSTALL_FULL_WALLPAPERS=$([ "$INSTALL_FULL_WALLPAPERS" = true ] && echo false || echo true)
                            ;;
                        *"5."*)
                            ENABLE_TELEMETRY=$([ "$ENABLE_TELEMETRY" = true ] && echo false || echo true)
                            ;;
                        *"6."*)
                            OPT_DESKTOP_APPS=$([ "$OPT_DESKTOP_APPS" = true ] && echo false || echo true)
                            ;;
                        *"7."*)
                            if [ ${#SELECTED_COMPOSITORS[@]} -eq 0 ]; then
                                printf "\n%s[!] %s%s\n" "$C_RED" "$(t "installer.ui.error_no_compositor")" "$RESET"
                                sleep 1.5
                                break
                            fi
                            IS_REINSTALL=false
                            cleanup_terminal
                            return 0
                            ;;
                        *"8."*)
                            if [[ "$INSTALL_STATE" == "current" ]]; then
                                if [ ${#SELECTED_COMPOSITORS[@]} -eq 0 ]; then
                                    printf "\n%s[!] %s%s\n" "$C_RED" "$(t "installer.ui.error_no_compositor")" "$RESET"
                                    sleep 1.5
                                    break
                                fi
                                IS_REINSTALL=true
                                cleanup_terminal
                                return 0
                            else
                                cleanup_terminal
                                clear
                                exit 0
                            fi
                            ;;
                        *"9."*)
                            if [[ "$INSTALL_STATE" == "current" ]]; then
                                cleanup_terminal
                                clear
                                exit 0
                            fi
                            ;;
                    esac
                    ;;
            esac
        done
    done
}

draw_completion_screen() {
    local target_ver="$1"
    local target_commit="$2"
    cleanup_terminal
    clear 2>/dev/null || true
    printf "%s%s" "$BOLD" "$C_GREEN"
    cat << "EOF"
 ___ _  _ ___ _____ _   _     _ _____ ___ ___  _  _    ___ ___  __  __ ___ _    ___ _____ ___ 
|_ _| \| / __|_   _/_\ | |   /_\_   _|_ _/ _ \| \| |  / __/ _ \ | \/  | _ \ |  | __|_   _| __|
 | || .` \__ \ | |/ _ \| |__| _ \| |  | | (_) | .` | | (_| (_) | |\/| |  _/ |__| _|  | | | _| 
|___|_|\_|___/ |_/_/ \_\____/_/ \_\_| |___\___/|_|\_|  \___\___/|_|  |_|_| |____|___| |_| |___|
EOF
    printf "%s\n\n" "$RESET"
    printf "%s%s  %s%s\n\n" "$BOLD" "$C_CYAN" "$(t "installer.ui.tagline")" "$RESET"
    printf "%s%s================================================================================%s\n\n" "$BOLD" "$C_MAGENTA" "$RESET"
    printf "%s%s%s\n" "$C_GREEN" "$(t "installer.ui.installed_success" "ver=$target_ver" "commit=$target_commit")" "$RESET"
    if [ ${#FAILED_PKGS[@]} -gt 0 ]; then
        printf "\n%s%s%s%s\n" "$BOLD" "$C_RED" "$(t "installer.ui.failed_packages")" "$RESET"
        for fp in "${FAILED_PKGS[@]}"; do
            printf "  - %s%s%s\n" "$C_YELLOW" "$fp" "$RESET"
        done
    fi
    printf "\n%s\n\n" "$(t "installer.ui.restart_prompt")"

    local restart_choice=""
    local prompt_msg
    prompt_msg="$(t "installer.ui.ask_reboot")"

    if [ -t 0 ]; then
        read -r -p "$prompt_msg" restart_choice
    elif [ -e /dev/tty ]; then
        read -r -p "$prompt_msg" restart_choice < /dev/tty
    fi

    if [[ "$restart_choice" =~ ^[Yy]$ ]]; then
        sudo reboot now
    fi
}
