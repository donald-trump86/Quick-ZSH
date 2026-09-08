# Quick-ZSH

Install and configure Zsh, Oh My Zsh, and optional Powerlevel10k, plugins, and fonts. Supports Linux and macOS, with download source and component selection during setup.

[![CI](https://github.com/donald-trump86/Quick-ZSH/actions/workflows/ci.yml/badge.svg)](https://github.com/donald-trump86/Quick-ZSH/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)](https://github.com/donald-trump86/Quick-ZSH)

**English** | [简体中文](README.md)

## Contents

- [Quick start](#quick-start)
- [Interactive setup](#interactive-setup)
- [Download failures](#download-failures)
- [Options and environment variables](#options-and-environment-variables)
- [Components](#components)
- [Supported systems](#supported-systems)
- [Configuration and backups](#configuration-and-backups)
- [FAQ](#faq)
- [Repository structure and checks](#repository-structure-and-checks)
- [License](#license)

## Quick start

Run in a terminal without any flags:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)"
```

The installer asks whether to use a mirror for mainland China, then lets you select an installation profile. When configuration backups exist, it first offers installation or restoration. From a local checkout, run:

```bash
bash install.sh
```

If `raw.githubusercontent.com` is unreachable, fetch the installer through the mirror, also without flags:

```bash
bash -c "$(curl -fsSL https://ghfast.top/https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)"
```

Answer `y` at the mirror prompt to use it for subsequent GitHub downloads. The selection only affects later downloads; it cannot change the URL used to fetch the installer itself.

The installer requires Bash, and the remote command requires `curl` beforehand. It checks for and installs missing `zsh`, `git`, and `curl` dependencies. Run as the user whose Zsh environment you want to configure; system package installation uses `sudo` or `doas` when needed.

## Interactive setup

Choose a download source first. Press Enter to use GitHub directly:

```text
Use a GitHub mirror for downloads in mainland China? [y/N]:
```

The mirror uses the GitHub proxy prefix in `GH_MIRROR_PREFIX`, which defaults to `https://ghfast.top/`. It applies to Oh My Zsh, themes, plugins, remote presets, and fonts. System package repositories are not modified.

Then select a profile:

| Option | Theme and plugins | Fonts |
| --- | --- | --- |
| `1` Recommended (default) | Powerlevel10k + all three plugins | Install |
| `2` Standard | Powerlevel10k + all three plugins | Skip |
| `3` Custom | Choose individually | Choose individually |

Custom setup enables the theme and plugins by default; the font default follows your Powerlevel10k selection. Invalid input prompts again, and closed input cancels installation.

Existing options remain available for scripts and CI:

- Explicit `USE_MIRROR=0`, `USE_MIRROR=1`, or `--mirror` skips the download source question.
- Component flags skip the profile menu but still allow interactive mirror selection. `--custom` explicitly opens component selection.
- `--unattended` or no usable terminal skips all setup menus and automatic entry into Zsh. Without explicit options, downloads are direct, the theme and all plugins are enabled, and fonts are skipped.
- Component environment variables supply initial values; interactive profiles or custom choices override them. Use `--unattended` for automation.

## Download failures

File downloads and repository clones or updates for Oh My Zsh, themes, and plugins are attempted up to 3 times on the current source. If they still fail, interactive setup offers to switch between direct access and the mirror; Enter keeps the current source. Accepting the switch applies it to the current resource and subsequent downloads. Each resource can switch once. Unattended mode retries the configured source without switching or waiting for input.

File downloads use a 10-second connection timeout and a 120-second total timeout per attempt. Git aborts transfers that remain below 1 byte per second for 30 seconds. System package installation does not use this retry logic.

Downloads and clones are staged in temporary locations and moved into place only after success. Failed downloads do not replace existing fonts or presets with partial files. Failed repository updates keep the existing version; failed downloads of new required components stop installation. Git updates retry only fetching remote data; a failed fast-forward merge preserves local changes and reports a warning.

## Options and environment variables

Run these examples from a local checkout:

```bash
# Unattended installation with all components; leave the login shell unchanged
bash install.sh --unattended --all --skip-chsh

# Select plugins and skip Powerlevel10k and fonts
bash install.sh --no-p10k --plugins=autosuggestions,syntax-highlighting --no-font

# Select the mirror explicitly for automation
USE_MIRROR=1 bash install.sh --unattended --skip-chsh

# Open individual component selection directly
bash install.sh --custom

# Restore a configuration backup and exit
bash install.sh --restore

# Explicitly replace an existing Powerlevel10k configuration during automation
bash install.sh --unattended --overwrite-p10k --skip-chsh
```

For remote execution, use `--` between the Bash command string and installer arguments:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/donald-trump86/Quick-ZSH/main/install.sh)" -- --unattended --skip-chsh
```

| Option | Environment variable | Default / behavior |
| --- | --- | --- |
| `-m`, `--mirror` | `USE_MIRROR=0/1` | Ask interactively; direct downloads without a terminal |
| `-a`, `--all` | — | Enable theme, all plugins, and fonts |
| `-c`, `--custom` | — | Choose components individually |
| `-u`, `-y`, `--yes`, `--unattended` | `UNATTENDED=1` | Skip setup menus and automatic entry into Zsh |
| `--skip-chsh` | `SKIP_CHSH=1` | Skip changing the default login shell |
| `--restore` | — | Interactively select and restore a configuration backup without installing |
| `--overwrite-p10k` / `--keep-p10k` | `OVERWRITE_P10K=1/0` | Replace / keep an existing preset; keep by default, including unattended mode |
| `--with-p10k` / `--no-p10k` | `ENABLE_P10K=1/0` | Theme and preset enabled by default |
| `--with-autosuggestions` / `--no-autosuggestions` | `ENABLE_AUTOSUGGESTIONS=1/0` | History suggestions enabled by default |
| `--with-syntax-highlighting` / `--no-syntax-highlighting` | `ENABLE_SYNTAX_HIGHLIGHTING=1/0` | Syntax highlighting enabled by default |
| `--with-completions` / `--no-completions` | `ENABLE_COMPLETIONS=1/0` | Extended completions enabled by default |
| `--plugins=<list>` | — | Comma-separated: `autosuggestions,syntax-highlighting,completions`; also accepts `all` / `none` |
| `-f`, `--with-font` / `--no-font` | `INSTALL_FONT=1/0` | Defaults to `0`; enabled by the interactive Recommended profile |
| — | `GH_MIRROR_PREFIX` | Proxy prefix; default `https://ghfast.top/` |
| — | `NO_COLOR=1` | Disable colored installer output |
| `-h`, `--help` | — | Show all options and aliases |

`--unattended` does not imply `--skip-chsh`, and system privilege tools may still request a password. Use both options in CI.

## Components

| Component | Purpose |
| --- | --- |
| [Zsh](https://www.zsh.org/) | Interactive shell; required |
| [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) | Theme and plugin framework; required |
| [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | Optional theme with a bundled Rainbow preset |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Suggestions based on command history |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Command syntax highlighting |
| [zsh-completions](https://github.com/zsh-users/zsh-completions) | Additional Tab completion definitions |
| [MesloLGS NF](https://github.com/romkatv/powerlevel10k-media) | Terminal font with Nerd Font glyphs |

## Supported systems

| System | Dependency installation |
| --- | --- |
| macOS | Homebrew; unnecessary if dependencies are already installed |
| Ubuntu / Debian / Kali / Linux Mint | `apt-get` |
| Arch Linux / Manjaro / EndeavourOS | `pacman` |
| Fedora / RHEL / CentOS / Rocky / AlmaLinux | `dnf` / `yum` |
| Alpine Linux | `apk`; install Bash before running the installer |
| openSUSE / SLES | `zypper` |

CI checks installation and repeated runs in Ubuntu, Debian, Arch Linux, Fedora, and Alpine containers. The macOS and openSUSE installation branches are not included in the current CI matrix.

## Configuration and backups

The installer updates existing repositories and creates `.bak.YYYYMMDD_HHMMSS.XXXXXX` backups before modifying an existing `~/.zshrc` or replacing `~/.p10k.zsh`. The random suffix prevents collisions between operations within the same second. Older backups without the suffix can also be restored.

Existing plugin declarations, comments, aliases, and other user configuration are retained. A managed component block before Oh My Zsh initialization merges the built-in `git` and selected plugins into your list and removes duplicates. For example, `docker` and `kubectl` remain enabled if you already have `plugins=(git docker kubectl)`. Disabling autosuggestions only removes `zsh-autosuggestions` from the final loaded list. `--plugins=none` disables the three optional plugins provided by this project while retaining custom plugins. Disabling a component does not delete downloaded directories.

Enabling Powerlevel10k selects its theme. If `~/.p10k.zsh` already exists, setup asks whether to replace it; Enter keeps it, and unattended mode keeps it automatically. Replacement requires an affirmative answer, `--overwrite-p10k`, or `OVERWRITE_P10K=1`, and creates a backup first. A fresh installation without this file uses the bundled preset.

Run `bash install.sh` and choose `Restore a configuration backup` from the action menu shown when backups exist, or run:

```bash
bash install.sh --restore
```

Select a `.zshrc` or `.p10k.zsh` backup, then confirm to restore the corresponding file. Enter or `0` cancels selection. The current file is backed up before restoration, so you can also undo a restore. Each operation restores one file and exits without installing components, downloading resources, or changing the login shell. Restoration requires a terminal and cannot be combined with `--unattended`. Open a new shell afterward.

You can also inspect and restore backups manually:

```bash
ls -la ~/.zshrc.bak.* ~/.p10k.zsh.bak.*
# Replace the filename below with an actual backup filename
cp ~/.zshrc.bak.YYYYMMDD_HHMMSS.XXXXXX ~/.zshrc
```

## FAQ

**Missing icons or square glyphs?**

After installing MesloLGS NF, select `MesloLGS NF` in your terminal settings. For SSH sessions, install the font on the local computer running the terminal.

**How can I change the Powerlevel10k style?**

Run `p10k configure` inside Zsh, or edit `~/.p10k.zsh`.

**Can I install without administrator privileges?**

If `zsh`, `git`, and `curl` are already available, use `--skip-chsh` to configure the current user environment. Ask an administrator to install any missing system dependencies first.

**Why did the installer not switch to Zsh?**

Unattended execution and sessions without a terminal do not switch automatically. Run `zsh` in your terminal. To change your login shell, run `chsh -s "$(command -v zsh)"` and log in again.

## Repository structure and checks

```text
install.sh                Installer, interactive selection, downloads, and configuration
.p10k.zsh                 Powerlevel10k preset
README.md / README_EN.md  Chinese and English documentation
.github/workflows/ci.yml  ShellCheck and Linux container installation checks
.editorconfig             Editor formatting conventions
LICENSE                   MIT license
```

Local static checks:

```bash
bash -n install.sh
zsh -n .p10k.zsh
shellcheck --severity=warning install.sh
```

## License

[MIT](LICENSE).
