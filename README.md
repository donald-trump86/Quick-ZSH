<div align="center">

# ⚡ Quick-ZSH

**生产级 Zsh + Oh My Zsh + Powerlevel10k + 常用高频插件一键自动化配置工具**

*Production-ready, one-click automated installer for Zsh, Oh My Zsh, Powerlevel10k, and high-frequency plugins.*

[![CI](https://github.com/donald-trump86/Quick-ZSH/actions/workflows/ci.yml/badge.svg)](https://github.com/donald-trump86/Quick-ZSH/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)](https://github.com/donald-trump86/Quick-ZSH)
[![Shell](https://img.shields.io/badge/shell-bash%20%7C%20zsh-green.svg)](https://www.zsh.org/)

[简体中文](#-简体中文) | [English](#-english)

</div>

---

## 📖 目录 / Table of Contents

- [简体中文](#-简体中文)
  - [✨ 特性亮点](#-特性亮点)
  - [🚀 极速安装](#-极速安装)
  - [🛠 CLI 参数与环境变量](#-cli-参数与环境变量)
  - [📦 集成组件](#-集成组件)
  - [🐧 支持的操作系统](#-支持的操作系统)
  - [❓ 常见问题 (FAQ)](#-常见问题-faq)
- [English](#-english)
  - [✨ Features](#-features)
  - [🚀 Quick Start](#-quick-start)
  - [🛠 CLI Options & Environment Variables](#-cli-options--environment-variables)
  - [📦 Included Components](#-included-components)
  - [🐧 Supported OS](#-supported-os)
  - [❓ FAQ](#-faq)

---

# 🇨🇳 简体中文

Quick-ZSH 是一套开箱即用的终端环境一键配置方案。它能够自动检测系统环境、安装依赖、部署 Oh My Zsh、配置顶级主题 Powerlevel10k，并集成语法高亮、历史自动建议、代码补全等高频生产力插件。

### ✨ 特性亮点

- **⚡ 极速全自动**：单行命令完成全套终端工具链配置，自动处理包依赖。
- **🛡 健壮与幂等**：严格开启 `set -euo pipefail`，支持重复执行而不产生脏配置。
- **🔒 安全备份**：每次修改 `~/.zshrc` 均自动生成带精确时间戳的备份文件（如 `~/.zshrc.bak.YYYYMMDD_HHMMSS`）。
- **🚀 国内加速镜像**：内置 `--mirror` 模式，支持一键切换 GitHub 代理镜像源，解决国内服务器与 VPS 下载超时痛点。
- **🔤 字体自动配置**：提供 MesloLGS NF 官方推荐字体下载及系统字体库刷新。
- **🌐 多平台全兼容**：原生支持 macOS 以及 Debian/Ubuntu、Arch Linux、Fedora/RHEL、Alpine 等主流 Linux 发行版。

---

### 🚀 极速安装

#### 1. 标准直连安装（海外网络 / 默认）
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)"
```

#### 2. 国内加速安装（推荐中国大陆机器使用）
```bash
bash -c "$(curl -fsSL https://ghfast.top/https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" -- --mirror
```

#### 3. 包含字体安装
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" -- --with-font
```

#### 4. 无人值守 / CI 自动化安装
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" -- --unattended
```

---

### 🛠 CLI 参数与环境变量

你可以通过命令行参数或环境变量灵活调整安装行为：

| CLI 选项 | 环境变量 | 默认值 | 说明 |
| :--- | :--- | :--- | :--- |
| `-m`, `--mirror` | `USE_MIRROR=1` | `0` | 开启 GitHub 下载加速镜像 |
| `-f`, `--with-font` | `INSTALL_FONT=1` | `0` | 自动下载并安装 MesloLGS NF 四款字体文件 |
| `-u`, `-y`, `--unattended` | `UNATTENDED=1` | `0` | 无人值守模式（不进行交互式提问） |
| `--skip-chsh` | `SKIP_CHSH=1` | `0` | 跳过切换默认 Shell 操作 |
| `-h`, `--help` | - | - | 显示帮助信息 |
| - | `GH_MIRROR_PREFIX` | `https://ghfast.top/` | 自定义 GitHub 代理前缀 |

---

### 📦 集成组件

| 组件 | 类型 | 说明 |
| :--- | :--- | :--- |
| **[Zsh](https://www.zsh.org/)** | 核心 Shell | 现代强大的交互式 Shell 环境 |
| **[Oh My Zsh](https://ohmyz.sh/)** | 框架 | 驱动插件、主题生态的核心框架 |
| **[Powerlevel10k](https://github.com/romkatv/powerlevel10k)** | 主题 | 极速、华丽且高度可定制的 Prompt 主题 |
| **[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** | 插件 | 根据历史命令实时给予淡灰色自动输入补全建议 |
| **[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)** | 插件 | 命令有效性实时语法高亮（绿色为正确命令，红色为错误） |
| **[zsh-completions](https://github.com/zsh-users/zsh-completions)** | 插件 | 额外增加海量命令的高级 Tab 补全库 |
| **[MesloLGS NF](https://github.com/romkatv/powerlevel10k-media)** | 字体 | Powerlevel10k 官方定制 Nerd Font 字体 |

---

### 🐧 支持的操作系统

| 操作系统 / 发行版 | 包管理器 | 支持状态 |
| :--- | :--- | :--- |
| **macOS** | Homebrew / 原生 | ✅ 完美支持 |
| **Ubuntu / Debian / Kali / Mint** | `apt-get` | ✅ 完美支持 |
| **Arch Linux / Manjaro** | `pacman` | ✅ 完美支持 |
| **Fedora / RHEL / CentOS / Rocky** | `dnf` / `yum` | ✅ 完美支持 |
| **Alpine Linux** | `apk` | ✅ 完美支持 |
| **openSUSE / SLES** | `zypper` | ✅ 完美支持 |

---

### ❓ 常见问题 (FAQ)

#### Q1: 安装完成后终端显示乱码、方块或图标缺失？
> **原因**：当前终端模拟器使用的字体缺少 Nerd Font 图标字符集。  
> **解决步骤**：
> 1. 执行脚本时带上 `--with-font` 或在提示时按 `Y` 安装 MesloLGS NF 字体。
> 2. 打开你所使用的终端软件设置，将字体（Font）修改为 **MesloLGS NF**：
>    - **VS Code**: 设置 -> 搜索 `terminal.integrated.fontFamily` -> 设置为 `'MesloLGS NF'`
>    - **iTerm2**: Preferences -> Profiles -> Text -> Font -> 勾选并在下拉列表中选择 `MesloLGS NF`
>    - **Windows Terminal**: 设置 -> 默认值 -> 外观 -> 字体 -> 选择 `MesloLGS NF`
>    - **Alacritty / Kitty / WezTerm**: 在对应配置文件中将 `font` 设置为 `MesloLGS NF`

#### Q2: 如何重新触发 Powerlevel10k 配置向导？
> 安装完成后，你随时可以在终端中运行：
> ```bash
> p10k configure
> ```
> 即可重新进行交互式样式配置（彩虹样式、经典样式、图标集选择等）。

#### Q3: 运行在无 Sudo / 非 Root 的受限服务器环境？
> 如果所在机器没有 root 权限且已预装了 `zsh`, `git`, `curl`，脚本将跳过包安装步骤直接完成用户级配置。若缺失依赖，请联系系统管理员安装基础包。

#### Q4: 修改了配置想找回以前的 `~/.zshrc`？
> 每次执行修改前，脚本都会备份。你可以在家目录下查找：
> ```bash
> ls -la ~/.zshrc.bak.*
> ```
> 使用 `cp ~/.zshrc.bak.<timestamp> ~/.zshrc` 即可瞬间还原。

---

# 🇺🇸 English

Quick-ZSH is an automated, out-of-the-box shell environment installer that configures Zsh, Oh My Zsh, the Powerlevel10k theme, and essential productivity plugins with a single command.

### ✨ Features

- **⚡ Fast & Automated**: Complete terminal toolchain setup with automatic dependency resolution.
- **🛡 Robust & Idempotent**: Uses `set -euo pipefail` and safe configuration checks. Re-running will never corrupt your environment.
- **🔒 Safe Backups**: Automatically backs up existing `~/.zshrc` with timestamps before making changes (`~/.zshrc.bak.YYYYMMDD_HHMMSS`).
- **🚀 Mirror Acceleration**: Built-in `--mirror` flag to route GitHub traffic through fast proxies in high-latency regions.
- **🔤 Font Installation**: Automatic MesloLGS NF font installer with font cache refresh.
- **🌐 Cross-Platform**: Full support for macOS and major Linux distros (Ubuntu, Debian, Arch, Fedora, Alpine, openSUSE).

---

### 🚀 Quick Start

#### 1. Standard Installation (Global / Default)
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)"
```

#### 2. Mirror Acceleration (Optimized for Mainland China)
```bash
bash -c "$(curl -fsSL https://ghfast.top/https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" -- --mirror
```

#### 3. Install with MesloLGS NF Fonts
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" -- --with-font
```

#### 4. Unattended / CI Mode
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" -- --unattended
```

---

### 🛠 CLI Options & Environment Variables

| CLI Flag | Environment Variable | Default | Description |
| :--- | :--- | :--- | :--- |
| `-m`, `--mirror` | `USE_MIRROR=1` | `0` | Enable GitHub proxy mirror acceleration |
| `-f`, `--with-font` | `INSTALL_FONT=1` | `0` | Download and install MesloLGS NF font family |
| `-u`, `-y`, `--unattended` | `UNATTENDED=1` | `0` | Run in non-interactive mode |
| `--skip-chsh` | `SKIP_CHSH=1` | `0` | Skip changing default shell |
| `-h`, `--help` | - | - | Show help message and exit |
| - | `GH_MIRROR_PREFIX` | `https://ghfast.top/` | Custom GitHub proxy prefix |

---

### 📦 Included Components

| Component | Type | Description |
| :--- | :--- | :--- |
| **[Zsh](https://www.zsh.org/)** | Shell | Powerful interactive shell environment |
| **[Oh My Zsh](https://ohmyz.sh/)** | Framework | Framework for managing Zsh plugins and themes |
| **[Powerlevel10k](https://github.com/romkatv/powerlevel10k)** | Theme | Blazing fast, customizable prompt theme |
| **[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** | Plugin | Fish-like autosuggestions based on command history |
| **[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)** | Plugin | Real-time syntax highlighting for shell commands |
| **[zsh-completions](https://github.com/zsh-users/zsh-completions)** | Plugin | Additional completion definitions for Zsh |
| **[MesloLGS NF](https://github.com/romkatv/powerlevel10k-media)** | Font | Official Powerlevel10k font with Nerd Font icons |

---

### 🐧 Supported OS

- **macOS** (Apple Silicon & Intel)
- **Ubuntu / Debian / Kali / Linux Mint** (`apt`)
- **Arch Linux / Manjaro** (`pacman`)
- **Fedora / RHEL / CentOS / Rocky Linux** (`dnf`/`yum`)
- **Alpine Linux** (`apk`)
- **openSUSE / SLES** (`zypper`)

---

### ❓ FAQ

#### Q1: Icons/glyphs appear as broken boxes or questions marks?
> **Fix**: Set your terminal font to **MesloLGS NF**.
> - **VS Code**: `Preferences` -> `Settings` -> Search `terminal.integrated.fontFamily` -> Set to `'MesloLGS NF'`.
> - **iTerm2**: `Preferences` -> `Profiles` -> `Text` -> `Font` -> Choose `MesloLGS NF`.
> - **Windows Terminal**: `Settings` -> `Defaults` -> `Appearance` -> `Font face` -> `MesloLGS NF`.

#### Q2: How do I reconfigure Powerlevel10k?
> Run the following command in your terminal at any time:
> ```bash
> p10k configure
> ```

#### Q3: How to restore previous `~/.zshrc`?
> Quick-ZSH creates a timestamped backup before touching `~/.zshrc`:
> ```bash
> ls -la ~/.zshrc.bak.*
> cp ~/.zshrc.bak.<timestamp> ~/.zshrc
> ```

---

## 📄 License

Distributed under the [MIT License](LICENSE).
