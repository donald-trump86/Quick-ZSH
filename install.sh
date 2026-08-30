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
# CLI Help and Argument Parsing
# ------------------------------------------------------------------------------
print_help() {
  cat <<'EOF'
Quick-ZSH Installer
Automated production-grade installer for Zsh, Oh My Zsh, Powerlevel10k, and popular plugins.

Usage:
  install.sh [options]
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" [options]

Options:
  -m, --mirror        Use GitHub proxy/mirror acceleration (for fast download in China)
  -f, --with-font     Automatically download and install MesloLGS NF fonts
  -u, -y, --yes,
  --unattended        Run in non-interactive / automated mode
  --skip-chsh         Skip changing the default login shell to zsh
  -h, --help          Show this help message and exit

Environment Variables:
  USE_MIRROR=1        Enable mirror acceleration
  INSTALL_FONT=1      Enable MesloLGS NF font installation
  UNATTENDED=1        Non-interactive execution mode
  SKIP_CHSH=1         Do not attempt to change default shell
  GH_MIRROR_PREFIX    Custom proxy prefix (default: https://ghfast.top/)
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
      -f|--with-font|--font)
        INSTALL_FONT=1
        shift
        ;;
      -u|-y|--yes|--unattended)
        UNATTENDED=1
        shift
        ;;
      --skip-chsh)
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
  log_step "Installing Powerlevel10k theme and high-frequency plugins..."

  local zsh_custom="${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}"
  mkdir -p "$zsh_custom/themes" "$zsh_custom/plugins"

  # Powerlevel10k Theme
  clone_or_update \
    "https://github.com/romkatv/powerlevel10k.git" \
    "$zsh_custom/themes/powerlevel10k" \
    "Powerlevel10k Theme"

  # Plugin: zsh-autosuggestions
  clone_or_update \
    "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$zsh_custom/plugins/zsh-autosuggestions" \
    "zsh-autosuggestions"

  # Plugin: zsh-syntax-highlighting
  clone_or_update \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$zsh_custom/plugins/zsh-syntax-highlighting" \
    "zsh-syntax-highlighting"

  # Plugin: zsh-completions
  clone_or_update \
    "https://github.com/zsh-users/zsh-completions.git" \
    "$zsh_custom/plugins/zsh-completions" \
    "zsh-completions"
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

  # 2. Update ZSH_THEME to Powerlevel10k
  if grep -q '^[[:space:]]*ZSH_THEME=' "$zshrc"; then
    sed -i.tmp 's|^[[:space:]]*ZSH_THEME=.*$|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$zshrc"
    rm -f "${zshrc}.tmp"
  else
    printf '\nZSH_THEME="powerlevel10k/powerlevel10k"\n' >> "$zshrc"
  fi

  # 3. Update plugins array idempotently using awk
  local tmp_zshrc
  tmp_zshrc="$(mktemp "${TMPDIR:-/tmp}/zshrc.XXXXXX")"

  awk '
  BEGIN { in_plugins = 0; found_plugins = 0 }
  /^[[:space:]]*plugins=\(/ {
    print "plugins=(\n  git\n  zsh-autosuggestions\n  zsh-syntax-highlighting\n  zsh-completions\n)"
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
      print "\nplugins=(\n  git\n  zsh-autosuggestions\n  zsh-syntax-highlighting\n  zsh-completions\n)"
    }
  }
  ' "$zshrc" > "$tmp_zshrc"

  mv "$tmp_zshrc" "$zshrc"

  # 4. Inject Powerlevel10k instant prompt at the very beginning if missing
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

  # 5. Manage Quick-ZSH initialization block (fpath + p10k config sourcing)
  # Remove previous Quick-ZSH block if present to ensure idempotency
  if grep -q '# >>> Quick-ZSH Initialization >>>' "$zshrc"; then
    awk '
    /# >>> Quick-ZSH Initialization >>>/ { skipping = 1; next }
    /# <<< Quick-ZSH Initialization <<</ { skipping = 0; next }
    !skipping { print }
    ' "$zshrc" > "$tmp_zshrc"
    mv "$tmp_zshrc" "$zshrc"
  fi

  # Append clean Quick-ZSH initialization block
  cat <<'EOF' >> "$zshrc"

# >>> Quick-ZSH Initialization >>>
# Add zsh-completions to fpath
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# <<< Quick-ZSH Initialization <<<
EOF

  log_success "$zshrc configuration updated successfully."
}

# ------------------------------------------------------------------------------
# Fonts Installation (MesloLGS NF)
# ------------------------------------------------------------------------------
query_font_install() {
  if [[ "$INSTALL_FONT" == "1" ]] || [[ "$UNATTENDED" == "1" ]]; then
    return 0
  fi

  # Check if interactive TTY is available
  if [[ -r /dev/tty ]]; then
    printf "\n"
    printf "${CYAN}${BOLD}[?]${RESET} Do you want to download & install recommended ${BOLD}MesloLGS NF${RESET} fonts? [y/N]: "
    local resp=""
    read -r resp </dev/tty || true
    case "$resp" in
      [yY]|[yY][eE][sS])
        INSTALL_FONT=1
        ;;
      *)
        INSTALL_FONT=0
        ;;
    esac
  fi
}

install_fonts() {
  if [[ "$INSTALL_FONT" != "1" ]]; then
    log_info "Font installation skipped."
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
  printf "  ${GREEN}✔${RESET} Powerlevel10k theme\n"
  printf "  ${GREEN}✔${RESET} zsh-autosuggestions (history suggestions)\n"
  printf "  ${GREEN}✔${RESET} zsh-syntax-highlighting (syntax highlighting)\n"
  printf "  ${GREEN}✔${RESET} zsh-completions (enhanced completions)\n"
  if [[ "$INSTALL_FONT" == "1" ]]; then
    printf "  ${GREEN}✔${RESET} MesloLGS NF Fonts\n"
  fi
  printf "\n"
  printf " ${BOLD}Next Steps:${RESET}\n"
  printf "  1. Start using Zsh now by running:\n"
  printf "     ${CYAN}${BOLD}exec zsh -l${RESET}\n\n"
  printf "  2. Configure Powerlevel10k theme prompt at any time:\n"
  printf "     ${CYAN}${BOLD}p10k configure${RESET}\n\n"
  if [[ "$INSTALL_FONT" == "1" ]]; then
    printf "  3. Set your terminal font to ${BOLD}MesloLGS NF${RESET} to ensure all icons display correctly.\n\n"
  fi
  if [[ -n "$BACKUP_ZSHRC" ]]; then
    printf " ${DIM}Note: Your previous configuration was backed up to: %s${RESET}\n\n" "$BACKUP_ZSHRC"
  fi
}

# ------------------------------------------------------------------------------
# Main Execution Entry
# ------------------------------------------------------------------------------
main() {
  parse_args "$@"

  printf "\n"
  printf "${CYAN}${BOLD}  ____             _          _           ______ ____  _   _${RESET}\n"
  printf "${CYAN}${BOLD} / __ \ __  __(_) ____| | __        |___  // ___|| | | |${RESET}\n"
  printf "${CYAN}${BOLD}| |  | | | | | | |/ ___| |/ / _____     / / \___ \| |_| |${RESET}\n"
  printf "${CYAN}${BOLD}| |__| | |_| | | | |__ |   < |_____|   / /   ___) |  _  |${RESET}\n"
  printf "${CYAN}${BOLD} \___\_\\__,_|_|_|\____|_|\_\         /_/   |____/|_| |_|${RESET}\n"
  printf "\n"
  printf "  %sAutomated Production-Grade Zsh Environment Installer%s\n\n" "$BOLD" "$RESET"

  if [[ "$USE_MIRROR" == "1" ]]; then
    log_info "Mirror acceleration enabled (Proxy: $GH_MIRROR_PREFIX)."
  fi

  query_font_install
  install_dependencies
  install_oh_my_zsh
  install_themes_and_plugins
  configure_zshrc
  install_fonts
  change_default_shell
  print_summary
}

main "$@"
