<div align="center">

# ⚡ Quick-ZSH

**Production-Ready Modular Zsh + Oh My Zsh + Powerlevel10k + Essential Plugins Installer**

*Blazing fast, elegant, and modular out-of-the-box terminal environment setup.*

[![CI](https://github.com/donald-trump86/Quick-ZSH/actions/workflows/ci.yml/badge.svg)](https://github.com/donald-trump86/Quick-ZSH/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)](https://github.com/donald-trump86/Quick-ZSH)
[![Shell](https://img.shields.io/badge/shell-bash%20%7C%20zsh-green.svg)](https://www.zsh.org/)

**English** | [简体中文文档](README.md)

</div>

---

## 📖 Table of Contents

- [✨ Features](#-features)
- [🚀 Quick Start](#-quick-start)
- [🎛 Modular Profiles & Component Selection](#-modular-profiles--component-selection)
- [🛠 CLI Options & Environment Variables](#-cli-options--environment-variables)
- [📦 Included Components & Plugins](#-included-components--plugins)
- [🐧 Supported Operating Systems](#-supported-operating-systems)
- [❓ FAQ & Troubleshooting](#-faq--troubleshooting)
- [📄 License](#-license)

---

## ✨ Features

- **⚡ Fast & Automated**: Complete terminal toolchain setup with automatic package dependency resolution.
- **🎛 Modular & Customizable**: Interactively or via CLI flags choose whether to install Powerlevel10k and specific plugins.
- **🛡 Robust & Idempotent**: Uses `set -euo pipefail`. Safely re-run multiple times or switch configurations without generating dirty configs.
- **🔒 Safe Backup Mechanism**: Automatically backs up existing `~/.zshrc` and `~/.p10k.zsh` with timestamps before making modifications.
- **🚀 Mirror Acceleration**: Built-in `--mirror` flag to route GitHub traffic through fast reverse proxies in high-latency regions.
- **🔤 Font Installation**: Automatic MesloLGS NF font installer with font cache refresh.
- **🌐 Cross-Platform**: Native support for macOS and major Linux distributions (Debian, Ubuntu, Arch Linux, Fedora, Alpine, openSUSE).

---

## 🚀 Quick Start

#### 1. Standard Recommended Installation (Global / Default)
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)"
```

#### 2. Mirror Acceleration (Optimized for Mainland China)
```bash
bash -c "$(curl -fsSL https://ghfast.top/https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" --mirror
```
> Or via environment variable:
> ```bash
> USE_MIRROR=1 bash -c "$(curl -fsSL https://ghfast.top/https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)"
> ```

#### 3. Interactive Custom Setup (Select components step-by-step)
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" --custom
```

#### 4. Unattended / Automated CI Mode
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" --unattended
```

---

## 🎛 Modular Profiles & Component Selection

When running interactively, Quick-ZSH presents an easy-to-use profile menu:

```text
Please select an installation profile:
  [1] Recommended : Powerlevel10k + All 3 Plugins + MesloLGS NF Fonts (Default)
  [2] Standard    : Powerlevel10k + All 3 Plugins (Skip Fonts)
  [3] Custom      : Choose theme, plugins, and fonts individually
```

### CLI Flag Examples:

```bash
# Skip Powerlevel10k theme (use OMZ default robbyrussell theme):
bash -c "$(curl -fsSL https://.../install.sh)" --no-p10k

# Install only specific plugins:
bash -c "$(curl -fsSL https://.../install.sh)" --plugins=autosuggestions,syntax-highlighting

# Install everything including fonts:
bash -c "$(curl -fsSL https://.../install.sh)" --all
```

---

## 🛠 CLI Options & Environment Variables

### 1. Core Options
| CLI Flag | Environment Variable | Default | Description |
| :--- | :--- | :--- | :--- |
| `-m`, `--mirror` | `USE_MIRROR=1` | `0` | Enable GitHub proxy/mirror acceleration |
| `-a`, `--all` | - | - | Enable all features (P10k + 3 plugins + fonts) |
| `-c`, `--custom` | - | - | Enter step-by-step interactive custom selection |
| `-u`, `-y`, `--unattended` | `UNATTENDED=1` | `0` | Run in non-interactive mode |
| `--skip-chsh` | `SKIP_CHSH=1` | `0` | Skip changing default login shell |
| `-h`, `--help` | - | - | Show help message and exit |

### 2. Theme & Plugins Selection
| CLI Flag | Environment Variable | Default | Description |
| :--- | :--- | :--- | :--- |
| `--with-p10k` / `--no-p10k` | `ENABLE_P10K=1/0` | `1` | Enable / disable Powerlevel10k theme |
| `--with-autosuggestions` / `--no-autosuggestions` | `ENABLE_AUTOSUGGESTIONS=1/0` | `1` | Enable / disable `zsh-autosuggestions` |
| `--with-syntax-highlighting` / `--no-syntax-highlighting` | `ENABLE_SYNTAX_HIGHLIGHTING=1/0` | `1` | Enable / disable `zsh-syntax-highlighting` |
| `--with-completions` / `--no-completions` | `ENABLE_COMPLETIONS=1/0` | `1` | Enable / disable `zsh-completions` |
| `--plugins=<list>` | - | - | Comma-separated list of plugins (e.g. `--plugins=autosuggestions,syntax-highlighting`) |

### 3. Font Options
| CLI Flag | Environment Variable | Default | Description |
| :--- | :--- | :--- | :--- |
| `-f`, `--with-font` / `--no-font` | `INSTALL_FONT=1/0` | Prompt | Download and install MesloLGS NF fonts |

---

## 📦 Included Components & Plugins

| Component | Type | Description |
| :--- | :--- | :--- |
| **[Zsh](https://www.zsh.org/)** | Core Shell | Modern, interactive, and powerful shell environment |
| **[Oh My Zsh](https://ohmyz.sh/)** | Framework | Framework for managing Zsh plugins, themes, and configuration |
| **[Powerlevel10k](https://github.com/romkatv/powerlevel10k)** | Theme (Optional) | Blazing fast prompt theme with customized Rainbow preset |
| **[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** | Plugin (Optional) | Fish-like autosuggestions based on command history |
| **[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)** | Plugin (Optional) | Real-time syntax highlighting for shell commands |
| **[zsh-completions](https://github.com/zsh-users/zsh-completions)** | Plugin (Optional) | Additional advanced completion definitions for Zsh |
| **[MesloLGS NF](https://github.com/romkatv/powerlevel10k-media)** | Font (Optional) | Official Powerlevel10k font with complete Nerd Font glyphs |

---

## 🐧 Supported Operating Systems

- **macOS** (Apple Silicon & Intel)
- **Ubuntu / Debian / Kali / Linux Mint** (`apt-get`)
- **Arch Linux / Manjaro / EndeavourOS** (`pacman`)
- **Fedora / RHEL / CentOS / Rocky / AlmaLinux** (`dnf`/`yum`)
- **Alpine Linux** (`apk`)
- **openSUSE / SLES** (`zypper`)

---

## ❓ FAQ & Troubleshooting

### Q1: Icons/glyphs appear as broken boxes or question marks?
> **Cause**: The current terminal font does not support Nerd Font icon glyphs.  
> **Solution**:
> 1. Run the installer with `--with-font` (or select font in the menu).
> 2. Set your terminal font to **MesloLGS NF**:
>    - **VS Code**: `Settings` -> Search `terminal.integrated.fontFamily` -> Set to `'MesloLGS NF'`
>    - **iTerm2**: `Preferences` -> `Profiles` -> `Text` -> `Font` -> Select `MesloLGS NF`
>    - **Windows Terminal**: `Settings` -> `Defaults` -> `Appearance` -> `Font face` -> Select `MesloLGS NF`
>    - **Alacritty / Kitty / WezTerm**: Set `font` to `MesloLGS NF` in configuration file.

---

### Q2: How do I re-run the Powerlevel10k configuration wizard?
> If Powerlevel10k is installed, run:
> ```bash
> p10k configure
> ```

---

### Q3: How to restore my previous `~/.zshrc`?
> Before making modifications, Quick-ZSH creates a timestamped backup:
> ```bash
> ls -la ~/.zshrc.bak.*
> cp ~/.zshrc.bak.<TIMESTAMP> ~/.zshrc
> ```

---

## 📄 License

Distributed under the [MIT License](LICENSE).
