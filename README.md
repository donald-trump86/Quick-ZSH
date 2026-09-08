# Quick-ZSH

一键安装和配置 Zsh、Oh My Zsh，以及可选的 Powerlevel10k 主题、插件和字体。支持 Linux 与 macOS，运行时选择下载源和安装组件。

[![CI](https://github.com/donald-trump86/Quick-ZSH/actions/workflows/ci.yml/badge.svg)](https://github.com/donald-trump86/Quick-ZSH/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)](https://github.com/donald-trump86/Quick-ZSH)

[English](README_EN.md) | **简体中文**

## 目录

- [快速开始](#快速开始)
- [交互式安装](#交互式安装)
- [下载失败处理](#下载失败处理)
- [参数与环境变量](#参数与环境变量)
- [组件](#组件)
- [支持的系统](#支持的系统)
- [配置与备份](#配置与备份)
- [常见问题](#常见问题)
- [仓库结构与检查](#仓库结构与检查)
- [许可证](#许可证)

## 快速开始

在终端执行，无需添加参数：

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)"
```

脚本会询问是否使用国内镜像，再让你选择安装方案。检测到配置备份时，会先提供安装或恢复入口。已有本地仓库时，直接运行：

```bash
bash install.sh
```

如果无法访问 `raw.githubusercontent.com`，可以通过镜像获取脚本，同样无需添加参数：

```bash
bash -c "$(curl -fsSL https://ghfast.top/https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)"
```

下载脚本后，在提示中输入 `y`，后续 GitHub 下载也会使用镜像。运行中的选择只能影响后续下载，无法改变获取安装脚本时使用的地址。

安装器需要 Bash；使用远程命令需要先安装 `curl`。脚本会检查并安装缺失的 `zsh`、`git`、`curl`。请以需要配置 Zsh 的用户运行，安装系统依赖时会按需调用 `sudo` 或 `doas`。

## 交互式安装

首先选择下载源，回车默认直连 GitHub：

```text
Use a GitHub mirror for downloads in mainland China? [y/N]:
```

镜像使用 `GH_MIRROR_PREFIX` 指定的 GitHub 代理前缀，默认是 `https://ghfast.top/`，用于 Oh My Zsh、主题、插件、远程预设和字体的下载。系统包管理器的软件源不会被修改。

随后选择安装方案：

| 选项 | 主题与插件 | 字体 |
| --- | --- | --- |
| `1` Recommended（默认） | Powerlevel10k + 全部三个插件 | 安装 |
| `2` Standard | Powerlevel10k + 全部三个插件 | 跳过 |
| `3` Custom | 逐项选择 | 逐项选择 |

自定义模式中，主题和插件默认启用；字体默认跟随是否选择 Powerlevel10k。输入无效选项会重新提问，输入中断会终止安装。

已有的参数仍可用于脚本和 CI：

- 显式设置 `USE_MIRROR=0`、`USE_MIRROR=1` 或 `--mirror` 时，不再询问下载源。
- 指定组件参数时跳过安装方案菜单，但仍可交互选择镜像；`--custom` 可强制进入组件选择。
- `--unattended` 或没有可用终端时跳过所有安装菜单，也不会自动进入 Zsh。未指定选项时默认直连、启用主题和全部插件、跳过字体。
- 组件环境变量提供初始值；交互式方案或自定义选择会覆盖这些值。自动化场景请使用 `--unattended`。

## 下载失败处理

文件下载、Oh My Zsh、主题和插件的克隆或更新，会在当前下载源上最多尝试 3 次。仍然失败时，交互模式会询问是否切换直连 / 镜像；回车默认不切换。同意后，新下载源会用于当前资源及后续下载，每个资源最多切源一次。无人值守模式按指定源重试，不会自动切源或等待输入。

文件下载设置 10 秒连接超时和 120 秒单次总超时；Git 在传输速度持续 30 秒低于每秒 1 字节时终止尝试。系统包安装不使用这套重试逻辑。

下载和克隆先写入临时位置，成功后再放到目标路径。失败不会用半成品覆盖现有字体或预设；已有仓库更新失败时保留当前版本，新增必需组件下载失败时终止安装。Git 更新只重试获取远程数据，本地无法快进合并时会保留本地修改并提示。

## 参数与环境变量

在本地仓库中运行以下示例：

```bash
# 无人值守，安装全部组件，跳过修改默认 Shell
bash install.sh --unattended --all --skip-chsh

# 仅安装指定插件，跳过 Powerlevel10k 和字体
bash install.sh --no-p10k --plugins=autosuggestions,syntax-highlighting --no-font

# 显式选择镜像，适合自动化环境
USE_MIRROR=1 bash install.sh --unattended --skip-chsh

# 直接进入组件自选
bash install.sh --custom

# 直接进入备份恢复，完成后退出
bash install.sh --restore

# 自动化安装时明确要求替换已有 Powerlevel10k 配置
bash install.sh --unattended --overwrite-p10k --skip-chsh
```

远程执行时，使用 `--` 分隔 Bash 的命令字符串和安装器参数：

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" -- --unattended --skip-chsh
```

| 参数 | 环境变量 | 默认行为 / 说明 |
| --- | --- | --- |
| `-m`, `--mirror` | `USE_MIRROR=0/1` | 交互询问；无终端时默认直连 |
| `-a`, `--all` | — | 启用主题、全部插件和字体 |
| `-c`, `--custom` | — | 逐项选择组件 |
| `-u`, `-y`, `--yes`, `--unattended` | `UNATTENDED=1` | 跳过安装菜单和自动进入 Zsh |
| `--skip-chsh` | `SKIP_CHSH=1` | 跳过修改默认登录 Shell |
| `--restore` | — | 交互式选择并恢复配置备份，不执行安装 |
| `--overwrite-p10k` / `--keep-p10k` | `OVERWRITE_P10K=1/0` | 替换 / 保留已有预设；交互默认保留，无人值守自动保留 |
| `--with-p10k` / `--no-p10k` | `ENABLE_P10K=1/0` | 默认启用 Powerlevel10k 及预设 |
| `--with-autosuggestions` / `--no-autosuggestions` | `ENABLE_AUTOSUGGESTIONS=1/0` | 默认启用历史建议 |
| `--with-syntax-highlighting` / `--no-syntax-highlighting` | `ENABLE_SYNTAX_HIGHLIGHTING=1/0` | 默认启用语法高亮 |
| `--with-completions` / `--no-completions` | `ENABLE_COMPLETIONS=1/0` | 默认启用扩展补全 |
| `--plugins=<list>` | — | 逗号分隔：`autosuggestions,syntax-highlighting,completions`，也支持 `all` / `none` |
| `-f`, `--with-font` / `--no-font` | `INSTALL_FONT=1/0` | 默认 `0`；交互推荐方案会启用 |
| — | `GH_MIRROR_PREFIX` | 代理前缀，默认 `https://ghfast.top/` |
| — | `NO_COLOR=1` | 关闭安装器的彩色输出 |
| `-h`, `--help` | — | 查看完整选项及别名 |

`--unattended` 不会自动设置 `--skip-chsh`，系统权限工具仍可能要求密码；CI 中建议同时指定两者。

## 组件

| 组件 | 用途 |
| --- | --- |
| [Zsh](https://www.zsh.org/) | 交互式 Shell，必装 |
| [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) | 主题与插件框架，必装 |
| [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | 可选主题，附带 Rainbow 预设 |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | 根据历史命令提供输入建议 |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | 命令语法高亮 |
| [zsh-completions](https://github.com/zsh-users/zsh-completions) | 扩展 Tab 补全定义 |
| [MesloLGS NF](https://github.com/romkatv/powerlevel10k-media) | 终端字体，包含 Nerd Font 字形 |

## 支持的系统

| 系统 | 依赖安装工具 |
| --- | --- |
| macOS | Homebrew；已具备依赖时无需 Homebrew |
| Ubuntu / Debian / Kali / Linux Mint | `apt-get` |
| Arch Linux / Manjaro / EndeavourOS | `pacman` |
| Fedora / RHEL / CentOS / Rocky / AlmaLinux | `dnf` / `yum` |
| Alpine Linux | `apk`，运行安装器前需安装 Bash |
| openSUSE / SLES | `zypper` |

CI 在 Ubuntu、Debian、Arch Linux、Fedora 和 Alpine 容器中检查安装与重复运行。macOS 和 openSUSE 的安装分支未包含在当前 CI 矩阵中。

## 配置与备份

脚本会更新已有仓库，并在修改现有 `~/.zshrc`、替换 `~/.p10k.zsh` 前创建 `.bak.YYYYMMDD_HHMMSS.XXXXXX` 备份。随机后缀避免同一秒内多次操作覆盖备份，也支持恢复旧版不带后缀的备份。

原有的插件声明、注释、别名和其他用户配置会保留。脚本在 Oh My Zsh 初始化前插入自己的组件区块，将内置 `git` 和本次选中的插件合并到原列表并去重。例如，已有 `plugins=(git docker kubectl)` 时，`docker` 和 `kubectl` 会保留；禁用自动建议时，仅从最终加载列表中移除 `zsh-autosuggestions`。`--plugins=none` 只禁用本项目提供的三个可选插件，不清空用户自定义插件。禁用组件不会删除已下载目录。

启用 Powerlevel10k 会设置对应主题。已有 `~/.p10k.zsh` 时，会询问是否替换，回车默认保留；无人值守时自动保留。只有明确同意、使用 `--overwrite-p10k` 或设置 `OVERWRITE_P10K=1` 才会备份并替换。新安装没有此文件时，使用仓库预设。

运行 `bash install.sh`，在检测到备份后的操作菜单中选择 `Restore a configuration backup`，或直接执行：

```bash
bash install.sh --restore
```

选择列表中的 `.zshrc` 或 `.p10k.zsh` 备份，确认后恢复对应文件；回车或选择 `0` 可取消。恢复前会再备份当前文件，因此也能撤回这次恢复。恢复操作一次处理一个文件，不安装组件、不下载资源、不修改默认 Shell；需要可用终端，不能与 `--unattended` 一起使用。恢复后请打开新的 Shell。

也可以手动查看和恢复：

```bash
ls -la ~/.zshrc.bak.* ~/.p10k.zsh.bak.*
# 将下面的文件名替换为实际备份文件名
cp ~/.zshrc.bak.YYYYMMDD_HHMMSS.XXXXXX ~/.zshrc
```

## 常见问题

**字体显示为方块或缺少图标？**

安装 MesloLGS NF 后，还需要在终端软件中将字体设为 `MesloLGS NF`。通过 SSH 使用远程服务器时，字体需要安装在运行终端的本地电脑上。

**如何调整 Powerlevel10k 样式？**

进入 Zsh 后运行 `p10k configure`，或编辑 `~/.p10k.zsh`。

**没有管理员权限可以使用吗？**

如果 `zsh`、`git`、`curl` 均已安装，可以加上 `--skip-chsh` 配置当前用户环境。缺失系统依赖时，需要管理员先安装依赖。

**安装后没有切换到 Zsh？**

无人值守和无终端模式不会自动切换。可在终端运行 `zsh`；如需设置默认登录 Shell，运行 `chsh -s "$(command -v zsh)"` 后重新登录。

## 仓库结构与检查

```text
install.sh                安装入口、交互选择、下载与配置逻辑
.p10k.zsh                 Powerlevel10k 预设
README.md / README_EN.md  中英文使用说明
.github/workflows/ci.yml  ShellCheck 与 Linux 容器安装检查
.editorconfig             编辑器格式约定
LICENSE                   MIT 许可证
```

本地静态检查：

```bash
bash -n install.sh
zsh -n .p10k.zsh
shellcheck --severity=warning install.sh
```

## 许可证

[MIT](LICENSE)。
