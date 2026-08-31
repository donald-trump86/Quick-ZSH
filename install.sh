#!/usr/bin/env bash
# ==============================================================================
# Quick-ZSH: Automated Production-Grade Zsh + Oh My Zsh + Powerlevel10k Installer
# Repository: https://github.com/donald-trump86/Quick-ZSH
# License: MIT
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Global Variables and Defaults
# ------------------------------------------------------------------------------
USE_MIRROR="${USE_MIRROR:-0}"
INSTALL_FONT="${INSTALL_FONT:-0}"
UNATTENDED="${UNATTENDED:-0}"
SKIP_CHSH="${SKIP_CHSH:-0}"
GH_MIRROR_PREFIX="${GH_MIRROR_PREFIX:-https://ghfast.top/}"
BACKUP_ZSHRC=""

# Modular Feature Toggles (1 = Enable, 0 = Disable)
ENABLE_P10K="${ENABLE_P10K:-1}"
ENABLE_AUTOSUGGESTIONS="${ENABLE_AUTOSUGGESTIONS:-1}"
ENABLE_SYNTAX_HIGHLIGHTING="${ENABLE_SYNTAX_HIGHLIGHTING:-1}"
ENABLE_COMPLETIONS="${ENABLE_COMPLETIONS:-1}"

EXPLICIT_FLAGS_PASSED=0
CUSTOM_INTERACTIVE=0

# ------------------------------------------------------------------------------
# Colors and Styling
# ------------------------------------------------------------------------------
if [[ -t 1 ]] && [[ "${TERM:-dumb}" != "dumb" ]] && [[ -z "${NO_COLOR:-}" ]]; then
  BOLD='\033[1m'
  DIM='\033[2m'
  GREEN='\033[32m'
  BLUE='\033[34m'
  YELLOW='\033[33m'
  RED='\033[31m'
  CYAN='\033[36m'
  RESET='\033[0m'
else
  BOLD=''
  DIM=''
  GREEN=''
  BLUE=''
  YELLOW=''
  RED=''
  CYAN=''
  RESET=''
fi

log_info() {
  printf "${BLUE}${BOLD}[INFO]${RESET} %s\n" "$*"
}

log_step() {
  printf "\n${CYAN}${BOLD}==>${RESET} ${BOLD}%s${RESET}\n" "$*"
}

log_success() {
  printf "${GREEN}${BOLD}[SUCCESS]${RESET} %s\n" "$*"
}

log_warn() {
  printf "${YELLOW}${BOLD}[WARN]${RESET} %s\n" "$*" >&2
}

log_error() {
  printf "${RED}${BOLD}[ERROR]${RESET} %s\n" "$*" >&2
}

# ------------------------------------------------------------------------------
# Welcome Banner
# ------------------------------------------------------------------------------
print_banner() {
  printf "\n${CYAN}${BOLD}"
  cat <<'EOF'
   ____        _      __          __________  __  __
  / __ \__  __(_)____/ /__       /__  / ___/ / / / /
 / / / / / / / / ___/ //_/         / /\__ \ / /_/ / 
/ /_/ / /_/ / / /__/ ,<           / /___/ // __  /  
\___\_\__,_/_/\___/_/|_|         /_//____//_/ /_/   
EOF
  printf "${RESET}\n"
  printf "  ${BOLD}Automated Production-Grade Zsh Environment Installer${RESET}\n\n"
}

# ------------------------------------------------------------------------------
# CLI Help and Argument Parsing
# ------------------------------------------------------------------------------
print_help() {
  cat <<'EOF'
Quick-ZSH Installer
Automated production-grade modular installer for Zsh, Oh My Zsh, Powerlevel10k, and popular plugins.

Usage:
  install.sh [options]
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" [options]

Core Options:
  -m, --mirror                Use GitHub proxy/mirror acceleration (for fast download in China)
  -a, --all                   Install all components (Powerlevel10k + 3 Plugins + Meslo Fonts)
  -c, --custom                Interactive custom setup (choose individual components)
  -u, -y, --yes, --unattended Run in non-interactive / automated mode
  --skip-chsh                 Skip changing the default login shell to zsh
  -h, --help                  Show this help message and exit

Theme Selection:
  --with-p10k, --p10k         Enable Powerlevel10k theme (default: enabled)
  --no-p10k, --skip-p10k      Disable Powerlevel10k theme (uses standard OMZ theme)

Plugin Selection:
  --plugins=<list>            Specify plugins to enable (comma-separated: autosuggestions,syntax-highlighting,completions,all,none)
  --with-autosuggestions      Enable zsh-autosuggestions
  --no-autosuggestions        Disable zsh-autosuggestions
  --with-syntax-highlighting  Enable zsh-syntax-highlighting
  --no-syntax-highlighting    Disable zsh-syntax-highlighting
  --with-completions          Enable zsh-completions
  --no-completions            Disable zsh-completions

Font Options:
  -f, --with-font             Automatically download and install MesloLGS NF fonts
  --no-font, --skip-font      Skip font installation

Environment Variables:
  USE_MIRROR=1                Enable mirror acceleration
  ENABLE_P10K=1|0             Enable / disable Powerlevel10k theme
  ENABLE_AUTOSUGGESTIONS=1|0  Enable / disable zsh-autosuggestions
  ENABLE_SYNTAX_HIGHLIGHTING=1|0 Enable / disable zsh-syntax-highlighting
  ENABLE_COMPLETIONS=1|0      Enable / disable zsh-completions
  INSTALL_FONT=1|0            Enable / disable MesloLGS NF font installation
  UNATTENDED=1                Non-interactive execution mode
  SKIP_CHSH=1                 Do not attempt to change default shell
  GH_MIRROR_PREFIX            Custom proxy prefix (default: https://ghfast.top/)
EOF
}

parse_args() {
  # Handle when invoked via `bash -c "..." --option` where $0 holds the first flag
  if [[ "$0" == -* ]] && [[ "$0" != "--" ]]; then
    set -- "$0" "$@"
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --)
        shift
        ;;
      -m|--mirror)
        USE_MIRROR=1
        shift
        ;;
      -a|--all)
        ENABLE_P10K=1
        ENABLE_AUTOSUGGESTIONS=1
        ENABLE_SYNTAX_HIGHLIGHTING=1
        ENABLE_COMPLETIONS=1
        INSTALL_FONT=1
        EXPLICIT_FLAGS_PASSED=1
        shift
        ;;
      -f|--with-font|--font)
        INSTALL_FONT=1
        EXPLICIT_FLAGS_PASSED=1
        shift
        ;;
      --no-font|--skip-font)
        INSTALL_FONT=0
        EXPLICIT_FLAGS_PASSED=1
        shift
        ;;
      --with-p10k|--p10k)
        ENABLE_P10K=1
        EXPLICIT_FLAGS_PASSED=1
        shift
        ;;
      --no-p10k|--skip-p10k)
        ENABLE_P10K=0
        EXPLICIT_FLAGS_PASSED=1
        shift
        ;;
      --with-autosuggestions)
        ENABLE_AUTOSUGGESTIONS=1
        EXPLICIT_FLAGS_PASSED=1
        shift
        ;;
      --no-autosuggestions)
        ENABLE_AUTOSUGGESTIONS=0
        EXPLICIT_FLAGS_PASSED=1
        shift
        ;;
      --with-syntax-highlighting)
        ENABLE_SYNTAX_HIGHLIGHTING=1
        EXPLICIT_FLAGS_PASSED=1
        shift
        ;;
      --no-syntax-highlighting)
        ENABLE_SYNTAX_HIGHLIGHTING=0
        EXPLICIT_FLAGS_PASSED=1
        shift
        ;;
      --with-completions)
        ENABLE_COMPLETIONS=1
        EXPLICIT_FLAGS_PASSED=1
        shift
        ;;
      --no-completions)
        ENABLE_COMPLETIONS=0
        EXPLICIT_FLAGS_PASSED=1
        shift
        ;;
      --plugins=*)
        local plugins_arg="${1#*=}"
        ENABLE_AUTOSUGGESTIONS=0
        ENABLE_SYNTAX_HIGHLIGHTING=0
        ENABLE_COMPLETIONS=0
        local old_ifs="$IFS"
        IFS=','
        read -ra p_arr <<< "$plugins_arg"
        IFS="$old_ifs"
        for p in "${p_arr[@]}"; do
          case "$p" in
            all)
              ENABLE_AUTOSUGGESTIONS=1
              ENABLE_SYNTAX_HIGHLIGHTING=1
              ENABLE_COMPLETIONS=1
              ;;
            none)
              ENABLE_AUTOSUGGESTIONS=0
              ENABLE_SYNTAX_HIGHLIGHTING=0
              ENABLE_COMPLETIONS=0
              ;;
            autosuggestions|zsh-autosuggestions)
              ENABLE_AUTOSUGGESTIONS=1
              ;;
            syntax-highlighting|zsh-syntax-highlighting)
              ENABLE_SYNTAX_HIGHLIGHTING=1
              ;;
            completions|zsh-completions)
              ENABLE_COMPLETIONS=1
              ;;
            *)
              log_warn "Unknown plugin in --plugins list: $p"
              ;;
          esac
        done
        EXPLICIT_FLAGS_PASSED=1
        shift
        ;;
      -c|--custom)
        CUSTOM_INTERACTIVE=1
        shift
        ;;
      -u|-y|--yes|--unattended)
        UNATTENDED=1
        shift
        ;;
      --skip-chsh|--no-chsh)
        SKIP_CHSH=1
        shift
        ;;
      -h|--help)
        print_help
        exit 0
        ;;
      *)
        log_warn "Unknown option: $1"
        shift
        ;;
    esac
  done
}

# ------------------------------------------------------------------------------
# Interactive Setup Menu
# ------------------------------------------------------------------------------
interactive_menu() {
  if [[ "$UNATTENDED" == "1" ]] || [[ "$EXPLICIT_FLAGS_PASSED" == "1" ]]; then
    return 0
  fi

  local tty_in=""
  if [[ -r /dev/tty ]]; then
    tty_in="/dev/tty"
  elif [[ -t 0 ]]; then
    tty_in="/dev/stdin"
  else
    return 0
  fi

  printf "\n"
  printf "${CYAN}${BOLD}╔═══════════════════════════════════════════════════════════════╗${RESET}\n"
  printf "${CYAN}${BOLD}║                Quick-ZSH Installation Setup                   ║${RESET}\n"
  printf "${CYAN}${BOLD}╚═══════════════════════════════════════════════════════════════╝${RESET}\n"
  printf "\n"

  if [[ "$CUSTOM_INTERACTIVE" != "1" ]]; then
    printf " ${BOLD}Please select an installation profile:${RESET}\n"
    printf "  ${GREEN}[1]${RESET} ${BOLD}Recommended${RESET} : Powerlevel10k + All 3 Plugins + MesloLGS NF Fonts (${CYAN}Default${RESET})\n"
    printf "  ${GREEN}[2]${RESET} ${BOLD}Standard${RESET}    : Powerlevel10k + All 3 Plugins (Skip Fonts)\n"
    printf "  ${GREEN}[3]${RESET} ${BOLD}Custom${RESET}      : Choose theme, plugins, and fonts individually\n"
    printf "\n"
    printf "${CYAN}${BOLD}[?]${RESET} Enter choice [1-3] (Default: 1): "

    local choice=""
    read -r choice < "$tty_in" || true
    choice="$(echo "$choice" | tr -d '[:space:]')"

    case "$choice" in
      2)
        ENABLE_P10K=1
        ENABLE_AUTOSUGGESTIONS=1
        ENABLE_SYNTAX_HIGHLIGHTING=1
        ENABLE_COMPLETIONS=1
        INSTALL_FONT=0
        log_info "Profile selected: Standard (Powerlevel10k + All plugins, skip fonts)."
        return 0
        ;;
      3)
        CUSTOM_INTERACTIVE=1
        ;;
      1|*)
        ENABLE_P10K=1
        ENABLE_AUTOSUGGESTIONS=1
        ENABLE_SYNTAX_HIGHLIGHTING=1
        ENABLE_COMPLETIONS=1
        INSTALL_FONT=1
        log_info "Profile selected: Recommended (Powerlevel10k + All plugins + MesloLGS NF fonts)."
        return 0
        ;;
    esac
  fi

  # Custom component selection
  printf "\n${CYAN}${BOLD}--- Custom Component Selection ---${RESET}\n\n"

  # 1. Powerlevel10k prompt
  printf "${CYAN}${BOLD}[?]${RESET} Install Powerlevel10k theme with pre-configured rainbow preset? [Y/n]: "
  local resp_p10k=""
  read -r resp_p10k < "$tty_in" || true
  case "$resp_p10k" in
    [nN]|[nN][oO]) ENABLE_P10K=0 ;;
    *) ENABLE_P10K=1 ;;
  esac

  # 2. zsh-autosuggestions prompt
  printf "${CYAN}${BOLD}[?]${RESET} Install zsh-autosuggestions (history suggestions)? [Y/n]: "
  local resp_auto=""
  read -r resp_auto < "$tty_in" || true
  case "$resp_auto" in
    [nN]|[nN][oO]) ENABLE_AUTOSUGGESTIONS=0 ;;
    *) ENABLE_AUTOSUGGESTIONS=1 ;;
  esac

  # 3. zsh-syntax-highlighting prompt
  printf "${CYAN}${BOLD}[?]${RESET} Install zsh-syntax-highlighting (real-time syntax colors)? [Y/n]: "
  local resp_syn=""
  read -r resp_syn < "$tty_in" || true
  case "$resp_syn" in
    [nN]|[nN][oO]) ENABLE_SYNTAX_HIGHLIGHTING=0 ;;
    *) ENABLE_SYNTAX_HIGHLIGHTING=1 ;;
  esac

  # 4. zsh-completions prompt
  printf "${CYAN}${BOLD}[?]${RESET} Install zsh-completions (extended tab completion library)? [Y/n]: "
  local resp_comp=""
  read -r resp_comp < "$tty_in" || true
  case "$resp_comp" in
    [nN]|[nN][oO]) ENABLE_COMPLETIONS=0 ;;
    *) ENABLE_COMPLETIONS=1 ;;
  esac

  # 5. MesloLGS NF Fonts prompt
  local font_default="y/N"
  [[ "$ENABLE_P10K" == "1" ]] && font_default="Y/n"
  printf "${CYAN}${BOLD}[?]${RESET} Download & install MesloLGS NF font family? [%s]: " "$font_default"
  local resp_font=""
  read -r resp_font < "$tty_in" || true
  if [[ "$ENABLE_P10K" == "1" ]]; then
    case "$resp_font" in
      [nN]|[nN][oO]) INSTALL_FONT=0 ;;
      *) INSTALL_FONT=1 ;;
    esac
  else
    case "$resp_font" in
      [yY]|[yY][eE][sS]) INSTALL_FONT=1 ;;
      *) INSTALL_FONT=0 ;;
    esac
  fi

  printf "\n"
}

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------
proxy_url() {
  local target_url="$1"
  if [[ "${USE_MIRROR}" == "1" ]]; then
    local prefix="${GH_MIRROR_PREFIX%/}"
    printf "%s/%s\n" "$prefix" "$target_url"
  else
    printf "%s\n" "$target_url"
  fi
}

run_elevated() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  elif command -v doas >/dev/null 2>&1; then
    doas "$@"
  else
    log_error "Root privileges are required to run '$*' but neither sudo nor doas was found."
    exit 1
  fi
}

# ------------------------------------------------------------------------------
# System Detection & Dependency Installation
# ------------------------------------------------------------------------------
detect_os() {
  local os_type="unknown"
  local pkg_mgr="unknown"

  if [[ "$OSTYPE" == "darwin"* ]] || [[ "$(uname -s)" == "Darwin" ]]; then
    os_type="macos"
    if command -v brew >/dev/null 2>&1; then
      pkg_mgr="brew"
    else
      pkg_mgr="none"
    fi
  elif [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    case "${ID:-}" in
      ubuntu|debian|kali|raspbian|linuxmint|pop)
        os_type="debian"
        pkg_mgr="apt"
        ;;
      arch|manjaro|endeavouros|artix|garuda)
        os_type="arch"
        pkg_mgr="pacman"
        ;;
      fedora|rhel|centos|rocky|almalinux|amzn)
        os_type="rhel"
        if command -v dnf >/dev/null 2>&1; then
          pkg_mgr="dnf"
        else
          pkg_mgr="yum"
        fi
        ;;
      alpine)
        os_type="alpine"
        pkg_mgr="apk"
        ;;
      opensuse*|sles)
        os_type="suse"
        pkg_mgr="zypper"
        ;;
      *)
        case "${ID_LIKE:-}" in
          *debian*|*ubuntu*)
            os_type="debian"
            pkg_mgr="apt"
            ;;
          *arch*)
            os_type="arch"
            pkg_mgr="pacman"
            ;;
          *rhel*|*fedora*|*centos*)
            os_type="rhel"
            if command -v dnf >/dev/null 2>&1; then
              pkg_mgr="dnf"
            else
              pkg_mgr="yum"
            fi
            ;;
          *)
            os_type="linux"
            pkg_mgr="unknown"
            ;;
        esac
        ;;
    esac
  elif [[ -f /etc/arch-release ]]; then
    os_type="arch"
    pkg_mgr="pacman"
  elif [[ -f /etc/debian_version ]]; then
    os_type="debian"
    pkg_mgr="apt"
  elif [[ -f /etc/redhat-release ]]; then
    os_type="rhel"
    pkg_mgr="dnf"
  fi

  echo "$os_type:$pkg_mgr"
}

install_dependencies() {
  log_step "Checking and installing required dependencies (zsh, git, curl)..."

  local missing_deps=()
  for dep in zsh git curl; do
    if ! command -v "$dep" >/dev/null 2>&1; then
      missing_deps+=("$dep")
    fi
  done

  if [[ ${#missing_deps[@]} -eq 0 ]]; then
    log_success "All required dependencies (zsh, git, curl) are already installed."
    return 0
  fi

  log_info "Missing dependencies: ${missing_deps[*]}"

  local detection
  detection="$(detect_os)"
  local pkg_mgr="${detection#*:}"

  case "$pkg_mgr" in
    apt)
      log_info "Updating apt package index and installing dependencies..."
      DEBIAN_FRONTEND=noninteractive run_elevated apt-get update -y
      DEBIAN_FRONTEND=noninteractive run_elevated apt-get install -y zsh git curl ca-certificates
      ;;
    pacman)
      log_info "Updating pacman repositories and installing dependencies..."
      run_elevated pacman -Sy --noconfirm zsh git curl ca-certificates
      ;;
    dnf)
      log_info "Installing dependencies with dnf..."
      run_elevated dnf install -y zsh git curl ca-certificates
      ;;
    yum)
      log_info "Installing dependencies with yum..."
      run_elevated yum install -y zsh git curl ca-certificates
      ;;
    apk)
      log_info "Installing dependencies with apk..."
      run_elevated apk update
      run_elevated apk add --no-cache zsh git curl ca-certificates shadow util-linux
      ;;
    zypper)
      log_info "Installing dependencies with zypper..."
      run_elevated zypper --non-interactive install zsh git curl ca-certificates
      ;;
    brew)
      log_info "Installing dependencies with Homebrew..."
      brew install zsh git curl
      ;;
    *)
      log_error "Unsupported package manager or system. Please install ${missing_deps[*]} manually."
      exit 1
      ;;
  esac

  log_success "Dependencies successfully installed."
}

# ------------------------------------------------------------------------------
# Oh My Zsh Installation
# ------------------------------------------------------------------------------
install_oh_my_zsh() {
  log_step "Installing / Verifying Oh My Zsh..."
  local zsh_dir="${ZSH:-$HOME/.oh-my-zsh}"

  if [[ -d "$zsh_dir/.git" ]]; then
    log_info "Oh My Zsh is already installed at $zsh_dir. Updating repository..."
    git -C "$zsh_dir" pull --quiet --ff-only || log_warn "Could not update Oh My Zsh via git pull; continuing with existing version."
  elif [[ -d "$zsh_dir" ]]; then
    log_info "Oh My Zsh directory exists at $zsh_dir."
  else
    log_info "Downloading and installing Oh My Zsh..."
    local omz_raw_url="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
    local omz_url
    omz_url="$(proxy_url "$omz_raw_url")"

    local tmp_installer
    tmp_installer="$(mktemp "${TMPDIR:-/tmp}/omz-install.XXXXXX")"
    curl -fsSL "$omz_url" -o "$tmp_installer"

    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh "$tmp_installer" --unattended
    rm -f "$tmp_installer"
    log_success "Oh My Zsh successfully installed at $zsh_dir."
  fi
}

# ------------------------------------------------------------------------------
# Powerlevel10k & Plugins Installation
# ------------------------------------------------------------------------------
clone_or_update() {
  local repo_url="$1"
  local dest_dir="$2"
  local desc="$3"

  local final_url
  final_url="$(proxy_url "$repo_url")"

  if [[ -d "$dest_dir/.git" ]]; then
    log_info "Updating $desc..."
    git -C "$dest_dir" pull --quiet --ff-only || log_warn "Could not update $desc; keeping existing version."
  elif [[ -d "$dest_dir" ]]; then
    log_info "$desc directory exists at $dest_dir."
  else
    log_info "Installing $desc..."
    mkdir -p "$(dirname "$dest_dir")"
    git clone --depth=1 "$final_url" "$dest_dir"
    log_success "$desc installed successfully."
  fi
}

install_themes_and_plugins() {
  log_step "Installing selected theme and plugins..."

  local zsh_custom="${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}"
  mkdir -p "$zsh_custom/themes" "$zsh_custom/plugins"

  # Powerlevel10k Theme
  if [[ "$ENABLE_P10K" == "1" ]]; then
    clone_or_update \
      "https://github.com/romkatv/powerlevel10k.git" \
      "$zsh_custom/themes/powerlevel10k" \
      "Powerlevel10k Theme"
  else
    log_info "Powerlevel10k theme installation skipped."
  fi

  # Plugin: zsh-autosuggestions
  if [[ "$ENABLE_AUTOSUGGESTIONS" == "1" ]]; then
    clone_or_update \
      "https://github.com/zsh-users/zsh-autosuggestions.git" \
      "$zsh_custom/plugins/zsh-autosuggestions" \
      "zsh-autosuggestions"
  else
    log_info "zsh-autosuggestions plugin skipped."
  fi

  # Plugin: zsh-syntax-highlighting
  if [[ "$ENABLE_SYNTAX_HIGHLIGHTING" == "1" ]]; then
    clone_or_update \
      "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
      "$zsh_custom/plugins/zsh-syntax-highlighting" \
      "zsh-syntax-highlighting"
  else
    log_info "zsh-syntax-highlighting plugin skipped."
  fi

  # Plugin: zsh-completions
  if [[ "$ENABLE_COMPLETIONS" == "1" ]]; then
    clone_or_update \
      "https://github.com/zsh-users/zsh-completions.git" \
      "$zsh_custom/plugins/zsh-completions" \
      "zsh-completions"
  else
    log_info "zsh-completions plugin skipped."
  fi
}

# ------------------------------------------------------------------------------
# Configuration File (~/.zshrc) Management
# ------------------------------------------------------------------------------
configure_zshrc() {
  log_step "Configuring $HOME/.zshrc..."
  local zshrc="$HOME/.zshrc"
  local zsh_dir="${ZSH:-$HOME/.oh-my-zsh}"

  # 1. Backup existing configuration file
  if [[ -f "$zshrc" ]]; then
    local timestamp
    timestamp="$(date +%Y%m%d_%H%M%S)"
    BACKUP_ZSHRC="${zshrc}.bak.${timestamp}"
    cp "$zshrc" "$BACKUP_ZSHRC"
    log_info "Existing config backed up to: $BACKUP_ZSHRC"
  else
    if [[ -f "$zsh_dir/templates/zshrc.zsh-template" ]]; then
      cp "$zsh_dir/templates/zshrc.zsh-template" "$zshrc"
      log_info "Created $zshrc from Oh My Zsh template."
    else
      touch "$zshrc"
      log_info "Created a new empty config at $zshrc."
    fi
  fi

  # 2. Update ZSH_THEME based on ENABLE_P10K
  if [[ "$ENABLE_P10K" == "1" ]]; then
    if grep -q '^[[:space:]]*ZSH_THEME=' "$zshrc"; then
      sed -i.tmp 's|^[[:space:]]*ZSH_THEME=.*$|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$zshrc"
      rm -f "${zshrc}.tmp"
    else
      printf '\nZSH_THEME="powerlevel10k/powerlevel10k"\n' >> "$zshrc"
    fi
  else
    # If p10k was explicitly disabled and current theme is p10k, switch to robbyrussell
    if grep -q '^[[:space:]]*ZSH_THEME="powerlevel10k/powerlevel10k"' "$zshrc"; then
      sed -i.tmp 's|^[[:space:]]*ZSH_THEME=.*$|ZSH_THEME="robbyrussell"|' "$zshrc"
      rm -f "${zshrc}.tmp"
    elif ! grep -q '^[[:space:]]*ZSH_THEME=' "$zshrc"; then
      printf '\nZSH_THEME="robbyrussell"\n' >> "$zshrc"
    fi
  fi

  # 3. Build plugins list dynamically
  local plugins_lines="  git"
  if [[ "$ENABLE_AUTOSUGGESTIONS" == "1" ]]; then
    plugins_lines="${plugins_lines}\n  zsh-autosuggestions"
  fi
  if [[ "$ENABLE_SYNTAX_HIGHLIGHTING" == "1" ]]; then
    plugins_lines="${plugins_lines}\n  zsh-syntax-highlighting"
  fi
  if [[ "$ENABLE_COMPLETIONS" == "1" ]]; then
    plugins_lines="${plugins_lines}\n  zsh-completions"
  fi

  local tmp_zshrc
  tmp_zshrc="$(mktemp "${TMPDIR:-/tmp}/zshrc.XXXXXX")"

  awk -v plines="$plugins_lines" '
  BEGIN { in_plugins = 0; found_plugins = 0 }
  /^[[:space:]]*plugins=\(/ {
    printf "plugins=(\n%s\n)\n", plines
    found_plugins = 1
    if ($0 ~ /\)/) {
      in_plugins = 0
    } else {
      in_plugins = 1
    }
    next
  }
  in_plugins {
    if ($0 ~ /\)/) {
      in_plugins = 0
    }
    next
  }
  { print }
  END {
    if (!found_plugins) {
      printf "\nplugins=(\n%s\n)\n", plines
    }
  }
  ' "$zshrc" > "$tmp_zshrc"

  mv "$tmp_zshrc" "$zshrc"

  # 4. Manage Powerlevel10k instant prompt
  if [[ "$ENABLE_P10K" == "1" ]]; then
    if ! grep -q 'p10k-instant-prompt' "$zshrc"; then
      local p10k_instant_prompt
      p10k_instant_prompt=$(cat <<'EOF'
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

EOF
)
      local existing_content
      existing_content="$(cat "$zshrc")"
      printf "%s\n%s" "$p10k_instant_prompt" "$existing_content" > "$zshrc"
    fi
  fi

  # 5. Manage Quick-ZSH initialization block (fpath + p10k config sourcing)
  if grep -q '# >>> Quick-ZSH Initialization >>>' "$zshrc"; then
    awk '
    /# >>> Quick-ZSH Initialization >>>/ { skipping = 1; next }
    /# <<< Quick-ZSH Initialization <<</ { skipping = 0; next }
    !skipping { print }
    ' "$zshrc" > "$tmp_zshrc"
    mv "$tmp_zshrc" "$zshrc"
  fi

  local quick_block=""
  if [[ "$ENABLE_COMPLETIONS" == "1" ]]; then
    quick_block="${quick_block}# Add zsh-completions to fpath\nfpath+=\${ZSH_CUSTOM:-\${ZSH:-\$HOME/.oh-my-zsh}/custom}/plugins/zsh-completions/src\n\n"
  fi
  if [[ "$ENABLE_P10K" == "1" ]]; then
    quick_block="${quick_block}# To customize prompt, run \`p10k configure\` or edit ~/.p10k.zsh.\n[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh\n"
  fi

  if [[ -n "$quick_block" ]]; then
    printf "\n# >>> Quick-ZSH Initialization >>>\n%b# <<< Quick-ZSH Initialization <<<\n" "$quick_block" >> "$zshrc"
  fi

  log_success "$zshrc configuration updated successfully."
}

# ------------------------------------------------------------------------------
# Powerlevel10k Configuration (~/.p10k.zsh) Management
# ------------------------------------------------------------------------------
configure_p10k() {
  if [[ "$ENABLE_P10K" != "1" ]]; then
    return 0
  fi

  log_step "Deploying Powerlevel10k custom configuration ($HOME/.p10k.zsh)..."
  local target_p10k="$HOME/.p10k.zsh"
  local script_dir=""

  if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ -f "${BASH_SOURCE[0]}" ]]; then
    script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  fi

  # 1. Backup existing ~/.p10k.zsh if it exists
  if [[ -f "$target_p10k" ]]; then
    local timestamp
    timestamp="$(date +%Y%m%d_%H%M%S)"
    local backup_p10k="${target_p10k}.bak.${timestamp}"
    cp "$target_p10k" "$backup_p10k"
    log_info "Existing config backed up to: $backup_p10k"
  fi

  # 2. Deploy from local repository or download preset
  if [[ -n "$script_dir" ]] && [[ -f "$script_dir/.p10k.zsh" ]]; then
    log_info "Applying local .p10k.zsh preset..."
    cp "$script_dir/.p10k.zsh" "$target_p10k"
    log_success "Local .p10k.zsh preset deployed successfully."
  else
    log_info "Downloading bundled .p10k.zsh preset from repository..."
    local raw_p10k_url="https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/.p10k.zsh"
    local p10k_url
    p10k_url="$(proxy_url "$raw_p10k_url")"

    if curl -fsSL "$p10k_url" -o "$target_p10k" 2>/dev/null; then
      log_success "Remote .p10k.zsh preset deployed successfully."
    else
      log_warn "Could not fetch remote .p10k.zsh preset. You can run 'p10k configure' later."
    fi
  fi
}

# ------------------------------------------------------------------------------
# Fonts Installation (MesloLGS NF)
# ------------------------------------------------------------------------------
install_fonts() {
  if [[ "$INSTALL_FONT" != "1" ]]; then
    log_info "MesloLGS NF fonts installation skipped."
    return 0
  fi

  log_step "Downloading and installing MesloLGS NF fonts..."

  local font_dir
  if [[ "$OSTYPE" == "darwin"* ]] || [[ "$(uname -s)" == "Darwin" ]]; then
    font_dir="$HOME/Library/Fonts"
  else
    font_dir="$HOME/.local/share/fonts"
  fi

  mkdir -p "$font_dir"

  local font_files=(
    "MesloLGS NF Regular.ttf"
    "MesloLGS NF Bold.ttf"
    "MesloLGS NF Italic.ttf"
    "MesloLGS NF Bold Italic.ttf"
  )

  local base_url="https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master"

  for font in "${font_files[@]}"; do
    local encoded_font="${font// /%20}"
    local raw_url="${base_url}/${encoded_font}"
    local target_url
    target_url="$(proxy_url "$raw_url")"
    local dest_path="${font_dir}/${font}"

    log_info "Downloading ${font}..."
    curl -fsSL "$target_url" -o "$dest_path"
  done

  # Refresh font cache on Linux if fc-cache exists
  if command -v fc-cache >/dev/null 2>&1; then
    log_info "Updating system font cache with fc-cache..."
    fc-cache -f "$font_dir" >/dev/null 2>&1 || true
  fi

  log_success "MesloLGS NF fonts installed in $font_dir."
}

# ------------------------------------------------------------------------------
# Default Shell Configuration
# ------------------------------------------------------------------------------
change_default_shell() {
  if [[ "$SKIP_CHSH" == "1" ]]; then
    log_info "Skipping default shell change (--skip-chsh is set)."
    return 0
  fi

  log_step "Checking and configuring default shell..."
  local zsh_bin
  zsh_bin="$(command -v zsh || true)"

  if [[ -z "$zsh_bin" ]]; then
    log_warn "zsh binary not found in PATH."
    return 0
  fi

  # Ensure zsh is listed in /etc/shells if we have permission
  if [[ -f /etc/shells ]] && ! grep -Fxq "$zsh_bin" /etc/shells 2>/dev/null; then
    log_info "Adding $zsh_bin to /etc/shells..."
    if [[ "$(id -u)" -eq 0 ]]; then
      echo "$zsh_bin" >> /etc/shells
    elif command -v sudo >/dev/null 2>&1; then
      echo "$zsh_bin" | sudo tee -a /etc/shells >/dev/null 2>&1 || true
    fi
  fi

  local current_user
  current_user="$(id -un)"
  local current_shell
  current_shell="$(getent passwd "$current_user" 2>/dev/null | cut -d: -f7 || echo "${SHELL:-}")"

  if [[ "$current_shell" == "$zsh_bin" ]] || [[ "$current_shell" == *"/zsh" ]]; then
    log_success "Default shell is already zsh ($current_shell)."
    return 0
  fi

  log_info "Changing default shell for $current_user to $zsh_bin..."
  local chsh_success=0

  if [[ "$(id -u)" -eq 0 ]]; then
    chsh -s "$zsh_bin" "$current_user" 2>/dev/null && chsh_success=1 || chsh -s "$zsh_bin" 2>/dev/null && chsh_success=1 || true
  else
    chsh -s "$zsh_bin" 2>/dev/null && chsh_success=1 || true
  fi

  if [[ "$chsh_success" -eq 1 ]]; then
    log_success "Default shell changed to $zsh_bin."
  else
    log_warn "Could not change default shell automatically (password or PAM restrictions)."
    log_warn "To switch to zsh manually, run:"
    printf "      ${BOLD}chsh -s %s${RESET}\n" "$zsh_bin"
  fi
}

# ------------------------------------------------------------------------------
# Summary Output
# ------------------------------------------------------------------------------
print_summary() {
  printf "\n"
  printf "${GREEN}${BOLD}╔═══════════════════════════════════════════════════════════════╗${RESET}\n"
  printf "${GREEN}${BOLD}║                Quick-ZSH Installation Complete!               ║${RESET}\n"
  printf "${GREEN}${BOLD}╚═══════════════════════════════════════════════════════════════╝${RESET}\n"
  printf "\n"
  printf " ${BOLD}Summary of installed components:${RESET}\n"
  printf "  ${GREEN}✔${RESET} Zsh (Shell)\n"
  printf "  ${GREEN}✔${RESET} Oh My Zsh framework\n"
  if [[ "$ENABLE_P10K" == "1" ]]; then
    printf "  ${GREEN}✔${RESET} Powerlevel10k theme (Custom rainbow preset configured)\n"
  else
    printf "  ${DIM}○${RESET} Powerlevel10k theme (Skipped, using default theme)\n"
  fi
  if [[ "$ENABLE_AUTOSUGGESTIONS" == "1" ]]; then
    printf "  ${GREEN}✔${RESET} zsh-autosuggestions (history suggestions)\n"
  else
    printf "  ${DIM}○${RESET} zsh-autosuggestions (Skipped)\n"
  fi
  if [[ "$ENABLE_SYNTAX_HIGHLIGHTING" == "1" ]]; then
    printf "  ${GREEN}✔${RESET} zsh-syntax-highlighting (syntax highlighting)\n"
  else
    printf "  ${DIM}○${RESET} zsh-syntax-highlighting (Skipped)\n"
  fi
  if [[ "$ENABLE_COMPLETIONS" == "1" ]]; then
    printf "  ${GREEN}✔${RESET} zsh-completions (enhanced completions)\n"
  else
    printf "  ${DIM}○${RESET} zsh-completions (Skipped)\n"
  fi
  if [[ "$INSTALL_FONT" == "1" ]]; then
    printf "  ${GREEN}✔${RESET} MesloLGS NF Fonts\n"
  else
    printf "  ${DIM}○${RESET} MesloLGS NF Fonts (Skipped)\n"
  fi
  printf "\n"
  printf " ${BOLD}Next Steps & Tips:${RESET}\n"
  if [[ "$ENABLE_P10K" == "1" ]]; then
    printf "  1. To re-configure Powerlevel10k styles at any time, run:\n"
    printf "     ${CYAN}${BOLD}p10k configure${RESET}\n\n"
  fi
  if [[ "$INSTALL_FONT" == "1" ]]; then
    printf "  2. Set your terminal font to ${BOLD}MesloLGS NF${RESET} to ensure all icons display correctly.\n\n"
  fi
  if [[ -n "$BACKUP_ZSHRC" ]]; then
    printf " ${DIM}Note: Your previous configuration was backed up to: %s${RESET}\n\n" "$BACKUP_ZSHRC"
  fi
}

# ------------------------------------------------------------------------------
# Automatic Shell Switching
# ------------------------------------------------------------------------------
enter_zsh_shell() {
  if [[ "$UNATTENDED" == "1" ]]; then
    return 0
  fi

  local zsh_bin
  zsh_bin="$(command -v zsh || true)"
  if [[ -z "$zsh_bin" ]]; then
    return 0
  fi

  # Check if running in an interactive terminal
  if [[ -t 0 ]] || [[ -t 1 ]] || [[ -r /dev/tty ]]; then
    log_step "Entering new Zsh shell environment..."
    printf "${GREEN}${BOLD}➜ Loading $HOME/.zshrc and switching into Zsh now...${RESET}\n\n"
    exec "$zsh_bin" -l
  fi
}

# ------------------------------------------------------------------------------
# Main Execution Entry
# ------------------------------------------------------------------------------
main() {
  parse_args "$@"

  print_banner

  if [[ "$USE_MIRROR" == "1" ]]; then
    log_info "Mirror acceleration enabled (Proxy: $GH_MIRROR_PREFIX)."
  fi

  interactive_menu
  install_dependencies
  install_oh_my_zsh
  install_themes_and_plugins
  configure_zshrc
  configure_p10k
  install_fonts
  change_default_shell
  print_summary
  enter_zsh_shell
}

main "$@"
