<div align="center">

# ⚡ Quick-ZSH

**生产级 Zsh + Oh My Zsh + Powerlevel10k + 常用高频插件一键自动化配置工具**

*极速、优雅、开箱即用的终端环境一键自动化配置方案。*

[![CI](https://github.com/donald-trump86/Quick-ZSH/actions/workflows/ci.yml/badge.svg)](https://github.com/donald-trump86/Quick-ZSH/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)](https://github.com/donald-trump86/Quick-ZSH)
[![Shell](https://img.shields.io/badge/shell-bash%20%7C%20zsh-green.svg)](https://www.zsh.org/)

[English Documentation](README_EN.md) | **简体中文**

</div>

---

## 📖 目录

- [✨ 特性亮点](#-特性亮点)
- [🚀 极速安装](#-极速安装)
- [🛠 CLI 参数与环境变量](#-cli-参数与环境变量)
- [📦 集成组件与插件](#-集成组件与插件)
- [🐧 支持的操作系统](#-支持的操作系统)
- [❓ 常见问题 (FAQ)](#-常见问题-faq)
- [📄 开源协议](#-开源协议)

---

## ✨ 特性亮点

- **⚡ 极速全自动**：单行命令完成全套终端工具链配置，自动处理操作系统包依赖。
- **🛡 健壮与幂等**：严格开启 `set -euo pipefail`，支持重复多次执行而不产生脏配置。
- **🔒 安全备份机制**：每次修改 `~/.zshrc` 前，自动创建带精确时间戳的备份文件（如 `~/.zshrc.bak.YYYYMMDD_HHMMSS`）。
- **🚀 国内自适应加速**：内置 `--mirror` 参数与 GitHub 代理镜像加速，解决国内服务器与 VPS 下载超时痛点。
- **🔤 字体自动配置**：提供 MesloLGS NF 官方推荐字体全套自动下载及系统字体库刷新。
- **🌐 多平台全兼容**：原生支持 macOS 以及 Debian/Ubuntu、Arch Linux、Fedora/RHEL、Alpine 等主流 Linux 发行版。

---

## 🚀 极速安装

#### 1. 标准直连安装（海外网络 / 默认）
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)"
```

#### 2. 国内加速安装（推荐中国大陆服务器 / 终端使用）
```bash
bash -c "$(curl -fsSL https://ghfast.top/https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" --mirror
```
> 也可通过环境变量直接指定加速：
> ```bash
> USE_MIRROR=1 bash -c "$(curl -fsSL https://ghfast.top/https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)"
> ```

#### 3. 包含 MesloLGS NF 字体安装
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" --with-font
```

#### 4. 无人值守 / CI 自动化安装
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" --unattended
```

---

## 🛠 CLI 参数与环境变量

你可以通过命令行参数或环境变量灵活调整安装行为：

| CLI 选项 | 环境变量 | 默认值 | 说明 |
| :--- | :--- | :--- | :--- |
| `-m`, `--mirror` | `USE_MIRROR=1` | `0` | 开启 GitHub 下载加速镜像（国内 VPS 推荐） |
| `-f`, `--with-font` | `INSTALL_FONT=1` | `0` | 自动下载并安装 MesloLGS NF 四款字体文件 |
| `-u`, `-y`, `--unattended` | `UNATTENDED=1` | `0` | 无人值守模式（不进行任何交互式提问） |
| `--skip-chsh` | `SKIP_CHSH=1` | `0` | 跳过切换默认 Shell 操作 |
| `-h`, `--help` | - | - | 显示帮助信息并退出 |
| - | `GH_MIRROR_PREFIX` | `https://ghfast.top/` | 自定义 GitHub 代理前缀 |

---

## 📦 集成组件与插件

| 组件 | 类型 | 说明 |
| :--- | :--- | :--- |
| **[Zsh](https://www.zsh.org/)** | 核心 Shell | 现代化、功能强大的交互式 Shell 环境 |
| **[Oh My Zsh](https://ohmyz.sh/)** | 框架 | 驱动插件、主题生态的核心管理框架 |
| **[Powerlevel10k](https://github.com/romkatv/powerlevel10k)** | 主题 | 极速、美观且高度可定制的 Prompt 主题 |
| **[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** | 插件 | 根据历史命令实时给予淡灰色自动输入补全建议（按 `→` 键即可采纳） |
| **[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)** | 插件 | 命令语法有效性实时高亮（绿色为正确命令，红色为错误） |
| **[zsh-completions](https://github.com/zsh-users/zsh-completions)** | 插件 | 额外增加海量常用命令的高级 Tab 自动补全定义 |
| **[MesloLGS NF](https://github.com/romkatv/powerlevel10k-media)** | 字体 | Powerlevel10k 官方定制 Nerd Font 字体（包含图标集） |

---

## 🐧 支持的操作系统

| 操作系统 / 发行版 | 包管理器 | 支持状态 |
| :--- | :--- | :--- |
| **macOS** | Homebrew / 原生 | ✅ 完美支持 |
| **Ubuntu / Debian / Kali / Linux Mint** | `apt-get` | ✅ 完美支持 |
| **Arch Linux / Manjaro / EndeavourOS** | `pacman` | ✅ 完美支持 |
| **Fedora / RHEL / CentOS / Rocky / AlmaLinux** | `dnf` / `yum` | ✅ 完美支持 |
| **Alpine Linux** | `apk` | ✅ 完美支持 |
| **openSUSE / SLES** | `zypper` | ✅ 完美支持 |

---

## ❓ 常见问题 (FAQ)

### Q1: 安装完成后终端显示乱码、方块或图标缺失？
> **原因**：当前终端模拟器使用的字体缺少 Nerd Font 图标字符集。  
> **解决方案**：
> 1. 执行脚本时带上 `--with-font` 或在提示时按 `Y` 安装 MesloLGS NF 字体。
> 2. 打开你所使用的终端软件设置，将字体（Font）修改为 **MesloLGS NF**：
>    - **VS Code**: 设置 -> 搜索 `terminal.integrated.fontFamily` -> 设置为 `'MesloLGS NF'`
>    - **iTerm2**: Preferences -> Profiles -> Text -> Font -> 勾选并在下拉列表中选择 `MesloLGS NF`
>    - **Windows Terminal**: 设置 -> 默认值 -> 外观 -> 字体 -> 选择 `MesloLGS NF`
>    - **Alacritty / Kitty / WezTerm**: 在对应配置文件中将 `font` 设置为 `MesloLGS NF`

---

### Q2: 如何重新触发 Powerlevel10k 配置向导？
> 安装完成后，你随时可以在终端中运行以下命令：
> ```bash
> p10k configure
> ```
> 即可重新进入交互式向导，自由切换 Rainbow、Classic 等不同视觉风格。

---

### Q3: 运行在无 Sudo / 非 Root 的受限服务器环境？
> 如果所在机器没有 root 权限且已预装了 `zsh`, `git`, `curl`，脚本将跳过系统包安装步骤，直接完成当前用户的全套配置。若缺失基础依赖，请联系系统管理员安装对应软件包。

---

### Q4: 修改了配置想找回以前的 `~/.zshrc`？
> 每次执行修改前，脚本都会自动创建安全备份。你可以在家目录下查找历史备份：
> ```bash
> ls -la ~/.zshrc.bak.*
> ```
> 使用以下命令即可还原：
> ```bash
> cp ~/.zshrc.bak.<时间戳> ~/.zshrc
> ```

---

## 📄 开源协议

本项目基于 [MIT License](LICENSE) 协议开源。
