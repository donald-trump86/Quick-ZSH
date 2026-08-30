<div align="center">

# ⚡ Quick-ZSH

**Production-Ready Automated Zsh + Oh My Zsh + Powerlevel10k + Essential Plugins Installer**

*Blazing fast, elegant, and out-of-the-box terminal environment setup with a single command.*

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
- [🛠 CLI Options & Environment Variables](#-cli-options--environment-variables)
- [📦 Included Components](#-included-components)
- [🐧 Supported Operating Systems](#-supported-operating-systems)
- [❓ FAQ & Troubleshooting](#-faq--troubleshooting)
- [📄 License](#-license)

---

## ✨ Features

- **⚡ Fast & Automated**: Complete terminal toolchain setup with automatic package dependency resolution.
- **🛡 Robust & Idempotent**: Uses `set -euo pipefail`. Re-running multiple times will never pollute or corrupt your environment.
- **🔒 Safe Backup Mechanism**: Automatically backs up existing `~/.zshrc` with a timestamp before making modifications (`~/.zshrc.bak.YYYYMMDD_HHMMSS`).
- **🚀 Mirror Acceleration**: Built-in `--mirror` flag to route GitHub traffic through fast reverse proxies in high-latency regions.
- **🔤 Font Installation**: Automatic MesloLGS NF font installer with font cache refresh.
- **🌐 Cross-Platform**: Native support for macOS and major Linux distributions (Debian, Ubuntu, Arch Linux, Fedora, Alpine, openSUSE).

---

## 🚀 Quick Start

#### 1. Standard Installation (Global / Default)
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

#### 3. Install with MesloLGS NF Fonts
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" --with-font
```

#### 4. Unattended / Automated CI Mode
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" --unattended
```

---

## 🛠 CLI Options & Environment Variables

You can customize the installation behavior via CLI flags or environment variables:

| CLI Option | Environment Variable | Default | Description |
| :--- | :--- | :--- | :--- |
| `-m`, `--mirror` | `USE_MIRROR=1` | `0` | Enable GitHub proxy/mirror acceleration |
| `-f`, `--with-font` | `INSTALL_FONT=1` | `0` | Download and install MesloLGS NF font family |
| `-u`, `-y`, `--unattended` | `UNATTENDED=1` | `0` | Unattended mode (skip all interactive prompts) |
| `--skip-chsh` | `SKIP_CHSH=1` | `0` | Skip changing default login shell |
| `-h`, `--help` | - | - | Show help message and exit |
| - | `GH_MIRROR_PREFIX` | `https://ghfast.top/` | Custom GitHub proxy prefix |

---

## 📦 Included Components

| Component | Type | Description |
| :--- | :--- | :--- |
| **[Zsh](https://www.zsh.org/)** | Core Shell | Modern, interactive, and powerful shell environment |
| **[Oh My Zsh](https://ohmyz.sh/)** | Framework | Framework for managing Zsh plugins, themes, and configuration |
| **[Powerlevel10k](https://github.com/romkatv/powerlevel10k)** | Theme | Blazing fast, beautiful, and customizable prompt theme |
| **[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** | Plugin | Fish-like autosuggestions based on command history (press `→` to accept) |
| **[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)** | Plugin | Real-time syntax highlighting for shell commands |
| **[zsh-completions](https://github.com/zsh-users/zsh-completions)** | Plugin | Additional advanced completion definitions for Zsh |
| **[MesloLGS NF](https://github.com/romkatv/powerlevel10k-media)** | Font | Official Powerlevel10k font with complete Nerd Font glyphs |

---

## 🐧 Supported Operating Systems

| OS / Distribution | Package Manager | Status |
| :--- | :--- | :--- |
| **macOS** | Homebrew / Native | ✅ Fully Supported |
| **Ubuntu / Debian / Kali / Linux Mint** | `apt-get` | ✅ Fully Supported |
| **Arch Linux / Manjaro / EndeavourOS** | `pacman` | ✅ Fully Supported |
| **Fedora / RHEL / CentOS / Rocky / AlmaLinux** | `dnf` / `yum` | ✅ Fully Supported |
| **Alpine Linux** | `apk` | ✅ Fully Supported |
| **openSUSE / SLES** | `zypper` | ✅ Fully Supported |

---

## ❓ FAQ & Troubleshooting

### Q1: Icons/glyphs appear as broken boxes or question marks?
> **Cause**: The current terminal font does not support Nerd Font icon glyphs.  
> **Solution**:
> 1. Run the installer with `--with-font` (or answer `y` when prompted).
> 2. Set your terminal font to **MesloLGS NF**:
>    - **VS Code**: `Settings` -> Search `terminal.integrated.fontFamily` -> Set to `'MesloLGS NF'`
>    - **iTerm2**: `Preferences` -> `Profiles` -> `Text` -> `Font` -> Select `MesloLGS NF`
>    - **Windows Terminal**: `Settings` -> `Defaults` -> `Appearance` -> `Font face` -> Select `MesloLGS NF`
>    - **Alacritty / Kitty / WezTerm**: Set `font` to `MesloLGS NF` in configuration file.

---

### Q2: How do I re-run the Powerlevel10k configuration wizard?
> You can re-run the prompt configuration wizard at any time:
> ```bash
> p10k configure
> ```

---

### Q3: Running in restricted non-root / no-sudo environments?
> If root permissions are unavailable but `zsh`, `git`, and `curl` are already present, the script skips package manager steps and performs user-level setup directly. If base packages are missing, please ask your system administrator to install them.

---

### Q4: How to restore my previous `~/.zshrc`?
> Before making modifications, Quick-ZSH creates a timestamped backup:
> ```bash
> ls -la ~/.zshrc.bak.*
> ```
> To restore:
> ```bash
> cp ~/.zshrc.bak.<TIMESTAMP> ~/.zshrc
> ```

---

## 📄 License

Distributed under the [MIT License](LICENSE).
