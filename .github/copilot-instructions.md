# Copilot Instructions for .dotfiles

## Overview
This repository automates the setup and maintenance of a macOS development environment using dotfiles, Homebrew, Oh My Zsh, and Mackup. It is designed for rapid, repeatable configuration of new or existing Macs.

## Key Components
- **fresh.sh**: Main setup script. Installs Oh My Zsh, Homebrew, symlinks config files, installs Brewfile dependencies, and sets up Mackup and Git configs.
- **.zshrc**: Loads Oh My Zsh, sets theme, and sources custom aliases and path modifications from this repo.
- **Brewfile**: Lists all Homebrew and Cask dependencies (CLI tools, apps, fonts). Managed via `brew bundle`.
- **aliases.zsh**: Defines project-specific shell aliases for git, navigation, Docker, and more.
- **.macos**: Customizes macOS system defaults (UI, Finder, Dock, etc.) using shell commands. Run manually after setup if needed.

## Setup Workflow
1. **Clone repo**: `git clone --recursive git@github.com:deviswan/dotfiles.git ~/.dotfiles`
2. **Run setup**: `~/.dotfiles/fresh.sh` (idempotent, safe to re-run)
3. **Restore settings**: `mackup restore` (after iCloud sync)
4. **Restart**: Reboot to finalize system changes

## Project Conventions
- All config files are symlinked from `~/.dotfiles` to `$HOME` (see `fresh.sh`).
- Customizations (aliases, paths, themes) should be made in this repo, not directly in `$HOME`.
- Use `brew bundle` to manage dependencies; edit `Brewfile` for changes.
- Use `mackup backup` and `mackup restore` to sync app settings via iCloud.
- Aliases are defined in `aliases.zsh` and loaded via `.zshrc`.

## Developer Shortcuts
- `reloadshell`: Reload `.zshrc` after changes
- `dotfiles`: Jump to the dotfiles directory
- `ll`: Enhanced `ls` with color and grouping
- Git: `gst` (status), `gb` (branch), `gc` (checkout), `amend`, `nuke`, etc.
- See `aliases.zsh` for more

## System Customization
- To apply macOS defaults, run `.macos` script manually: `~/.dotfiles/.macos`
- Review and edit `.macos` for personal preferences before running

## References
- [README.md](../README.md): Full setup guide and credits
- [fresh.sh](../fresh.sh): Automated setup logic
- [aliases.zsh](../aliases.zsh): Shell shortcuts
- [Brewfile](../Brewfile): Dependency list
- [.macos](../.macos): System tweaks

---
For more, see the README or open an issue for questions about project-specific workflows.
