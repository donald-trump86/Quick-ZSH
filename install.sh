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
MIRROR_CONFIGURED="${USE_MIRROR:+1}"
USE_MIRROR="${USE_MIRROR:-0}"
INSTALL_FONT="${INSTALL_FONT:-0}"
UNATTENDED="${UNATTENDED:-0}"
SKIP_CHSH="${SKIP_CHSH:-0}"
GH_MIRROR_PREFIX="${GH_MIRROR_PREFIX:-https://ghfast.top/}"
BACKUP_ZSHRC=""
LAST_BACKUP=""
OVERWRITE_P10K="${OVERWRITE_P10K:-}"
RESTORE_BACKUP=0
TEMPORARY_PATHS=()

# Modular Feature Toggles (1 = Enable, 0 = Disable)
ENABLE_P10K="${ENABLE_P10K:-1}"
ENABLE_AUTOSUGGESTIONS="${ENABLE_AUTOSUGGESTIONS:-1}"
ENABLE_SYNTAX_HIGHLIGHTING="${ENABLE_SYNTAX_HIGHLIGHTING:-1}"
ENABLE_COMPLETIONS="${ENABLE_COMPLETIONS:-1}"

EXPLICIT_FLAGS_PASSED=0
CUSTOM_INTERACTIVE=0
TTY_INPUT=""

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
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" -- [options]

Interactive Setup:
  Choose whether to use a GitHub mirror, then select an installation profile.
  USE_MIRROR=0|1 or --mirror skips the mirror question.
  Unattended mode or no terminal: direct downloads, theme and plugins enabled,
  fonts disabled unless explicitly selected.

Core Options:
  -m, --mirror                Use GitHub proxy/mirror acceleration (for fast download in China)
  -a, --all                   Install all components (Powerlevel10k + 3 Plugins + Meslo Fonts)
  -c, --custom                Interactive custom setup (choose individual components)
  -u, -y, --yes, --unattended Run in non-interactive / automated mode
  --skip-chsh                 Skip changing the default login shell to zsh
  --restore                   Interactively restore a .zshrc or .p10k.zsh backup and exit
  -h, --help                  Show this help message and exit

Theme Selection:
  --with-p10k, --p10k         Enable Powerlevel10k theme (default: enabled)
  --no-p10k, --skip-p10k      Disable Powerlevel10k theme (uses standard OMZ theme)
  --overwrite-p10k            Replace an existing .p10k.zsh after backing it up
  --keep-p10k                 Keep an existing .p10k.zsh without prompting (default unattended)

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
  USE_MIRROR=0|1              Choose direct downloads / mirror acceleration without prompting
  ENABLE_P10K=1|0             Enable / disable Powerlevel10k theme
  ENABLE_AUTOSUGGESTIONS=1|0  Enable / disable zsh-autosuggestions
  ENABLE_SYNTAX_HIGHLIGHTING=1|0 Enable / disable zsh-syntax-highlighting
  ENABLE_COMPLETIONS=1|0      Enable / disable zsh-completions
  INSTALL_FONT=1|0            Enable / disable MesloLGS NF font installation
  UNATTENDED=1                Non-interactive execution mode
  SKIP_CHSH=1                 Do not attempt to change default shell
  GH_MIRROR_PREFIX            Custom proxy prefix (default: https://ghfast.top/)
  OVERWRITE_P10K=0|1          Keep / replace an existing Powerlevel10k configuration

Downloads are attempted up to 3 times per source. After failure, interactive
setup offers one switch between GitHub and the mirror for this and later downloads.
Existing custom plugins are retained; selected Quick-ZSH plugins are merged in.
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
        MIRROR_CONFIGURED=1
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
        local p
        local p_arr=()
        IFS=',' read -ra p_arr <<< "$plugins_arg"
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
      --restore)
        RESTORE_BACKUP=1
        shift
        ;;
      --overwrite-p10k)
        OVERWRITE_P10K=1
        shift
        ;;
      --keep-p10k)
        OVERWRITE_P10K=0
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
setup_interactive_input() {
  TTY_INPUT=""
  if [[ "$UNATTENDED" == "1" ]]; then
    return 0
  fi

  # /dev/tty can exist without a controlling terminal (for example, in CI).
  if ( : < /dev/tty ) 2>/dev/null; then
    TTY_INPUT="/dev/tty"
  elif [[ -t 0 ]]; then
    TTY_INPUT="/dev/stdin"
  fi
}

prompt_yes_no() {
  local variable="$1" prompt="$2" default="$3"
  local answer hint="y/N"
  [[ "$default" == "1" ]] && hint="Y/n"

  while true; do
    printf "${CYAN}${BOLD}[?]${RESET} %s [%s]: " "$prompt" "$hint"
    if ! read -r answer < "$TTY_INPUT"; then
      log_error "Terminal input closed; installation cancelled."
      exit 1
    fi
    answer="${answer//[[:space:]]/}"
    case "$answer" in
      '') printf -v "$variable" '%s' "$default"; return 0 ;;
      [yY]|[yY][eE][sS]) printf -v "$variable" '%s' 1; return 0 ;;
      [nN]|[nN][oO]) printf -v "$variable" '%s' 0; return 0 ;;
      *) log_warn "Please enter y or n." ;;
    esac
  done
}

select_download_source() {
  if [[ -n "$TTY_INPUT" ]] && [[ "$MIRROR_CONFIGURED" != "1" ]]; then
    log_step "Download source"
    log_info "Mirror: $GH_MIRROR_PREFIX (GitHub downloads only)."
    prompt_yes_no USE_MIRROR "Use a GitHub mirror for downloads in mainland China?" 0
  fi

  if [[ "$USE_MIRROR" == "1" ]]; then
    log_info "Mirror acceleration enabled (Proxy: $GH_MIRROR_PREFIX)."
  else
    log_info "Download source: GitHub (direct)."
  fi
}

interactive_menu() {
  if [[ -z "$TTY_INPUT" ]] || { [[ "$EXPLICIT_FLAGS_PASSED" == "1" ]] && [[ "$CUSTOM_INTERACTIVE" != "1" ]]; }; then
    return 0
  fi

  log_step "Installation setup"

  if [[ "$CUSTOM_INTERACTIVE" != "1" ]]; then
    printf " ${BOLD}Please select an installation profile:${RESET}\n"
    printf "  ${GREEN}[1]${RESET} ${BOLD}Recommended${RESET} : Powerlevel10k + All 3 Plugins + MesloLGS NF Fonts (${CYAN}Default${RESET})\n"
    printf "  ${GREEN}[2]${RESET} ${BOLD}Standard${RESET}    : Powerlevel10k + All 3 Plugins (Skip Fonts)\n"
    printf "  ${GREEN}[3]${RESET} ${BOLD}Custom${RESET}      : Choose theme, plugins, and fonts individually\n"
    printf "\n"
    local choice=""
    while true; do
      printf "${CYAN}${BOLD}[?]${RESET} Enter choice [1-3] (Default: 1): "
      if ! read -r choice < "$TTY_INPUT"; then
        log_error "Terminal input closed; installation cancelled."
        exit 1
      fi
      choice="${choice//[[:space:]]/}"
      case "$choice" in
        ''|1|2|3) break ;;
        *) log_warn "Please enter 1, 2, or 3." ;;
      esac
    done

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
      ''|1)
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

  prompt_yes_no ENABLE_P10K "Install Powerlevel10k theme with pre-configured rainbow preset?" 1
  prompt_yes_no ENABLE_AUTOSUGGESTIONS "Install zsh-autosuggestions (history suggestions)?" 1
  prompt_yes_no ENABLE_SYNTAX_HIGHLIGHTING "Install zsh-syntax-highlighting (real-time syntax colors)?" 1
  prompt_yes_no ENABLE_COMPLETIONS "Install zsh-completions (extended tab completion library)?" 1
  prompt_yes_no INSTALL_FONT "Download & install MesloLGS NF font family?" "$ENABLE_P10K"

  printf "\n"
}

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------
proxy_url() {
  local target_url="$1"
  local prefix="${GH_MIRROR_PREFIX%/}"
  # Normalize existing remotes to avoid nesting the same proxy on repeated runs.
  target_url="${target_url#"$prefix/"}"
  if [[ "${USE_MIRROR}" == "1" ]] && [[ "$target_url" == https://github.com/* || "$target_url" == https://raw.githubusercontent.com/* ]]; then
    printf "%s/%s\n" "$prefix" "$target_url"
  else
    printf "%s\n" "$target_url"
  fi
}

retry_download() {
  local original_url="$1"
  shift
  local attempt switched=0 switch_source=0 next_source direct_url
  direct_url="${original_url#"${GH_MIRROR_PREFIX%/}/"}"

  while true; do
    for attempt in 1 2 3; do
      if "$@" "$(proxy_url "$original_url")"; then
        return 0
      fi
      log_warn "Download attempt $attempt/3 failed: $(proxy_url "$original_url")"
      [[ "$attempt" == "3" ]] || sleep 1
    done

    if [[ -z "$TTY_INPUT" || "$switched" == "1" ]] ||
       [[ "$direct_url" != https://github.com/* && "$direct_url" != https://raw.githubusercontent.com/* ]]; then
      return 1
    fi
    next_source="the mirror ($GH_MIRROR_PREFIX)"
    [[ "$USE_MIRROR" == "1" ]] && next_source="GitHub directly"
    prompt_yes_no switch_source "Download failed. Switch to $next_source for this and later downloads?" 0
    [[ "$switch_source" == "1" ]] || return 1
    USE_MIRROR=$((1 - USE_MIRROR))
    switched=1
  done
}

fetch_file() {
  local destination="$1" url="$2"
  curl -fsSL --connect-timeout 10 --max-time 120 "$url" -o "$destination"
}

download_file() {
  local url="$1" destination="$2" temporary
  temporary="$(mktemp "${destination}.download.XXXXXX")" || return 1
  TEMPORARY_PATHS+=("$temporary")
  if retry_download "$url" fetch_file "$temporary" && mv -f "$temporary" "$destination"; then
    return 0
  fi
  rm -f "$temporary"
  return 1
}

cleanup_temporary() {
  if [[ ${#TEMPORARY_PATHS[@]} -gt 0 ]]; then
    rm -rf -- "${TEMPORARY_PATHS[@]}"
  fi
}

backup_file() {
  local file="$1"
  LAST_BACKUP=""
  [[ -f "$file" ]] || return 0
  LAST_BACKUP="$(mktemp "${file}.bak.$(date +%Y%m%d_%H%M%S).XXXXXX")" || return 1
  if ! cp -p "$file" "$LAST_BACKUP"; then
    rm -f "$LAST_BACKUP"
    return 1
  fi
  log_info "Existing config backed up to: $LAST_BACKUP"
}

select_action() {
  [[ "$RESTORE_BACKUP" == "0" && -n "$TTY_INPUT" && "$EXPLICIT_FLAGS_PASSED" == "0" && "$CUSTOM_INTERACTIVE" == "0" ]] || return 0
  local backup choice
  for backup in "$HOME"/.zshrc.bak.* "$HOME"/.p10k.zsh.bak.*; do
    [[ -f "$backup" ]] || continue
    log_step "Choose an action"
    printf '  [1] Install / update (default)\n  [2] Restore a configuration backup\n'
    while true; do
      printf '[?] Enter choice [1-2] (Default: 1): '
      read -r choice < "$TTY_INPUT" || { log_error "Terminal input closed."; exit 1; }
      case "$choice" in
        ''|1) return 0 ;;
        2) RESTORE_BACKUP=1; return 0 ;;
        *) log_warn "Please enter 1 or 2." ;;
      esac
    done
  done
}

restore_backup() {
  if [[ -z "$TTY_INPUT" ]]; then
    log_error "Backup restoration requires an interactive terminal."
    return 1
  fi
  local backups=() backup choice index selected="" target confirm=0 temporary
  for backup in "$HOME"/.zshrc.bak.* "$HOME"/.p10k.zsh.bak.*; do
    [[ -f "$backup" ]] && backups+=("$backup")
  done
  if [[ ${#backups[@]} == 0 ]]; then
    log_info "No .zshrc or .p10k.zsh backups found."
    return 0
  fi

  log_step "Restore a configuration backup"
  for ((index=0; index<${#backups[@]}; index++)); do
    printf '  [%s] %s\n' "$((index + 1))" "${backups[index]##*/}"
  done
  printf '  [0] Cancel\n'
  while [[ -z "$selected" ]]; do
    printf '[?] Select a backup (Default: cancel): '
    read -r choice < "$TTY_INPUT" || { log_error "Terminal input closed."; return 1; }
    [[ -n "$choice" && "$choice" != 0 ]] || return 0
    for ((index=0; index<${#backups[@]}; index++)); do
      [[ "$choice" == "$((index + 1))" ]] && selected="${backups[index]}"
    done
    [[ -n "$selected" ]] || log_warn "Please enter a listed backup number or 0."
  done
  case "${selected##*/}" in
    .zshrc.bak.*) target="$HOME/.zshrc" ;;
    .p10k.zsh.bak.*) target="$HOME/.p10k.zsh" ;;
  esac
  prompt_yes_no confirm "Restore ${selected##*/} to $target? The current file will be backed up." 0
  [[ "$confirm" == "1" ]] || return 0
  backup_file "$target" || return 1
  temporary="$(mktemp "${target}.restore.XXXXXX")" || return 1
  TEMPORARY_PATHS+=("$temporary")
  if ! { cp -p "$selected" "$temporary" && mv -f "$temporary" "$target"; }; then
    rm -f "$temporary"
    return 1
  fi
  log_success "Restored $target. Open a new shell to use the restored configuration."
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
  local new_install=0
  [[ -e "$zsh_dir" ]] || new_install=1
  clone_or_update "${REMOTE:-https://github.com/${REPO:-ohmyzsh/ohmyzsh}.git}" "$zsh_dir" "Oh My Zsh" "${BRANCH:-master}" || return 1
  if [[ "$new_install" == "1" ]]; then
    git -C "$zsh_dir" config oh-my-zsh.remote origin
    git -C "$zsh_dir" config oh-my-zsh.branch "${BRANCH:-master}"
  fi
}

# ------------------------------------------------------------------------------
# Powerlevel10k & Plugins Installation
# ------------------------------------------------------------------------------
clone_repository() {
  local staging="$1" branch="$2" url="$3"
  local options=(--depth=1)
  [[ -z "$branch" ]] || options+=(--branch "$branch")
  rm -rf "$staging/repository" || return 1
  # Clone into a private staging directory so failed attempts cannot damage an existing checkout.
  (umask go-w; git -c http.lowSpeedLimit=1 -c http.lowSpeedTime=30 clone "${options[@]}" "$url" "$staging/repository")
}

fetch_repository() {
  local directory="$1" remote="$2" original_url="$3" url="$4"
  git -C "$directory" -c http.lowSpeedLimit=1 -c http.lowSpeedTime=30 \
    -c "url.$url.insteadOf=$original_url" fetch --quiet "$remote"
}

clone_or_update() {
  local repo_url="$1"
  local dest_dir="$2"
  local desc="$3"

  local branch="${4:-}"

  if [[ -d "$dest_dir/.git" ]]; then
    log_info "Updating $desc..."
    local remote_url remote
    if branch="$(git -C "$dest_dir" symbolic-ref --quiet --short HEAD)" &&
       remote="$(git -C "$dest_dir" config --get "branch.$branch.remote")" &&
       remote_url="$(git -C "$dest_dir" remote get-url "$remote")"; then
      # Retry only the fetch; local merge conflicts should not trigger a source switch.
      if retry_download "$remote_url" fetch_repository "$dest_dir" "$remote" "$remote_url"; then
        git -C "$dest_dir" merge --quiet --ff-only '@{upstream}' || log_warn "Could not fast-forward $desc; keeping local changes."
      else
        log_warn "Could not download updates for $desc; keeping existing version."
      fi
    else
      log_warn "No tracked remote branch for $desc; keeping existing version."
    fi
  elif [[ -d "$dest_dir" ]]; then
    log_info "$desc directory exists at $dest_dir."
  else
    log_info "Installing $desc..."
    mkdir -p "$(dirname "$dest_dir")" || return 1
    local staging
    staging="$(mktemp -d "${dest_dir}.clone.XXXXXX")" || return 1
    TEMPORARY_PATHS+=("$staging")
    if ! retry_download "$repo_url" clone_repository "$staging" "$branch"; then
      rm -rf "$staging"
      log_error "Could not install $desc."
      return 1
    fi
    mv "$staging/repository" "$dest_dir" || return 1
    rmdir "$staging" || return 1
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
  local zshrc="$HOME/.zshrc" zsh_dir="${ZSH:-$HOME/.oh-my-zsh}"
  local input="$zshrc" staging
  backup_file "$zshrc" || return 1
  BACKUP_ZSHRC="$LAST_BACKUP"
  if [[ ! -f "$input" ]]; then
    input="$zsh_dir/templates/zshrc.zsh-template"
    [[ -f "$input" ]] || input=/dev/null
  fi
  staging="$(mktemp -d "${zshrc}.configure.XXXXXX")" || return 1
  TEMPORARY_PATHS+=("$staging")

  # Keep user plugin declarations intact, including comments and shell expressions.
  # Apply only our component choices just before Oh My Zsh loads those plugins.
  {
    printf '# >>> Quick-ZSH Components >>>\n'
    printf 'export ZSH=%q\n' "$zsh_dir"
    [[ -z "${ZSH_CUSTOM:-}" ]] || printf 'export ZSH_CUSTOM=%q\n' "$ZSH_CUSTOM"
    if [[ "$ENABLE_P10K" == "1" ]]; then
      printf 'ZSH_THEME="powerlevel10k/powerlevel10k"\n'
    else
      cat <<'EOF'
if [[ ${ZSH_THEME:-} == powerlevel10k/powerlevel10k ]]; then
  ZSH_THEME="robbyrussell"
fi
: "${ZSH_THEME=robbyrussell}"
EOF
    fi
    cat <<'EOF'
typeset -gaU plugins
plugins=("${(@)plugins:#(zsh-autosuggestions|zsh-syntax-highlighting|zsh-completions)}" git)
EOF
    [[ "$ENABLE_COMPLETIONS" == "1" ]] && printf 'plugins+=(zsh-completions)\n'
    [[ "$ENABLE_AUTOSUGGESTIONS" == "1" ]] && printf 'plugins+=(zsh-autosuggestions)\n'
    # Load syntax highlighting after other plugins that install ZLE widgets.
    [[ "$ENABLE_SYNTAX_HIGHLIGHTING" == "1" ]] && printf 'plugins+=(zsh-syntax-highlighting)\n'
    if [[ "$ENABLE_COMPLETIONS" == "1" ]]; then
      printf 'fpath+=("${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions/src")\n'
    fi
    printf '# <<< Quick-ZSH Components <<<\n'
  } > "$staging/components" || return 1

  QUICK_ZSH_BLOCK="$staging/components" awk '
  function insert_components(  line) {
    while ((getline line < ENVIRON["QUICK_ZSH_BLOCK"]) > 0) print line
    close(ENVIRON["QUICK_ZSH_BLOCK"])
    inserted = 1
  }
  /^# >>> Quick-ZSH (Initialization|Components|Instant Prompt) >>>$/ { skipping = 1; next }
  /^# <<< Quick-ZSH (Initialization|Components|Instant Prompt) <<<$/ { skipping = 0; next }
  skipping { next }
  /^[[:space:]]*(source|[.])[[:space:]]+.*oh-my-zsh[.]sh/ {
    if (!inserted) insert_components()
  }
  { print }
  END {
    if (skipping) {
      print "Unclosed Quick-ZSH configuration block; original file was not changed." > "/dev/stderr"
      exit 1
    }
    if (!inserted) {
      insert_components()
      print "source \"$ZSH/oh-my-zsh.sh\""
    }
  }
  ' "$input" > "$staging/config" || return 1

  {
    if [[ "$ENABLE_P10K" == "1" ]] && ! grep -q 'p10k-instant-prompt' "$staging/config"; then
      cat <<'EOF'
# >>> Quick-ZSH Instant Prompt >>>
# Keep initialization that requires terminal input above this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# <<< Quick-ZSH Instant Prompt <<<
EOF
    fi
    cat "$staging/config"
    if [[ "$ENABLE_P10K" == "1" ]] && ! grep -Eq '^[^#]*(source|[.])[[:space:]]+.*[.]p10k[.]zsh' "$staging/config"; then
      cat <<'EOF'
# >>> Quick-ZSH Initialization >>>
# To customize the prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# <<< Quick-ZSH Initialization <<<
EOF
    fi
  } > "$staging/result" || return 1

  if ! zsh -n "$staging/result"; then
    log_error "Generated configuration has a syntax error; $zshrc was not changed."
    return 1
  fi
  if [[ -f "$zshrc" ]]; then
    cp -p "$zshrc" "$staging/final" || return 1
    cat "$staging/result" > "$staging/final" || return 1
  else
    mv "$staging/result" "$staging/final" || return 1
  fi
  mv "$staging/final" "$zshrc" || return 1
  rm -rf "$staging"
  log_success "$zshrc updated; custom plugins and user configuration retained."
}

# ------------------------------------------------------------------------------
# Powerlevel10k Configuration (~/.p10k.zsh) Management
# ------------------------------------------------------------------------------
configure_p10k() {
  [[ "$ENABLE_P10K" == "1" ]] || return 0
  local target_p10k="$HOME/.p10k.zsh" script_dir="" temporary
  local overwrite="${OVERWRITE_P10K:-0}"
  if [[ -f "$target_p10k" ]]; then
    if [[ -z "$OVERWRITE_P10K" && -n "$TTY_INPUT" ]]; then
      prompt_yes_no overwrite "Replace your existing .p10k.zsh with the bundled preset? A backup will be kept." 0
    fi
    if [[ "$overwrite" != "1" ]]; then
      log_info "Keeping existing $target_p10k."
      return 0
    fi
  fi

  log_step "Deploying Powerlevel10k configuration ($target_p10k)..."
  if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ -f "${BASH_SOURCE[0]}" ]]; then
    script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  fi
  temporary="$(mktemp "${target_p10k}.preset.XXXXXX")" || return 1
  TEMPORARY_PATHS+=("$temporary")
  if [[ -n "$script_dir" && -f "$script_dir/.p10k.zsh" ]]; then
    cp "$script_dir/.p10k.zsh" "$temporary" || return 1
  elif ! download_file "https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/.p10k.zsh" "$temporary"; then
    rm -f "$temporary"
    log_warn "Could not fetch the preset; existing configuration was not changed. Run 'p10k configure' later."
    return 0
  fi
  if ! zsh -n "$temporary"; then
    rm -f "$temporary"
    log_warn "Preset has a syntax error; existing configuration was not changed."
    return 0
  fi
  backup_file "$target_p10k" || return 1
  mv "$temporary" "$target_p10k" || return 1
  log_success "Powerlevel10k preset deployed successfully."
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
    local dest_path="${font_dir}/${font}"

    log_info "Downloading ${font}..."
    download_file "$raw_url" "$dest_path"
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
  printf "  ${GREEN}[OK]${RESET} Zsh (Shell)\n"
  printf "  ${GREEN}[OK]${RESET} Oh My Zsh framework\n"
  if [[ "$ENABLE_P10K" == "1" ]]; then
    printf "  ${GREEN}[OK]${RESET} Powerlevel10k theme\n"
  else
    printf "  ${DIM}[SKIP]${RESET} Powerlevel10k theme (Skipped, using default theme)\n"
  fi
  if [[ "$ENABLE_AUTOSUGGESTIONS" == "1" ]]; then
    printf "  ${GREEN}[OK]${RESET} zsh-autosuggestions (history suggestions)\n"
  else
    printf "  ${DIM}[SKIP]${RESET} zsh-autosuggestions (Skipped)\n"
  fi
  if [[ "$ENABLE_SYNTAX_HIGHLIGHTING" == "1" ]]; then
    printf "  ${GREEN}[OK]${RESET} zsh-syntax-highlighting (syntax highlighting)\n"
  else
    printf "  ${DIM}[SKIP]${RESET} zsh-syntax-highlighting (Skipped)\n"
  fi
  if [[ "$ENABLE_COMPLETIONS" == "1" ]]; then
    printf "  ${GREEN}[OK]${RESET} zsh-completions (enhanced completions)\n"
  else
    printf "  ${DIM}[SKIP]${RESET} zsh-completions (Skipped)\n"
  fi
  if [[ "$INSTALL_FONT" == "1" ]]; then
    printf "  ${GREEN}[OK]${RESET} MesloLGS NF Fonts\n"
  else
    printf "  ${DIM}[SKIP]${RESET} MesloLGS NF Fonts (Skipped)\n"
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
  if [[ -n "$TTY_INPUT" ]]; then
    log_step "Entering new Zsh shell environment..."
    log_info "Loading $HOME/.zshrc and switching into Zsh now..."
    exec "$zsh_bin" -l
  fi
}

# ------------------------------------------------------------------------------
# Main Execution Entry
# ------------------------------------------------------------------------------
main() {
  parse_args "$@"
  trap cleanup_temporary EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM

  print_banner
  setup_interactive_input
  select_action
  if [[ "$RESTORE_BACKUP" == "1" ]]; then
    restore_backup
    return
  fi
  select_download_source
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
