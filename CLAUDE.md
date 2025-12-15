# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a dotfiles/dev environment repository that manages configuration files and installation scripts for a macOS/Linux development setup. It uses a custom deployment system to copy configs to their standard XDG locations.

## Key Commands

### Deploy configurations to system
```bash
./dev-env           # Copy all configs to ~/.config, ~/.local, and ~
./dev-env --dry     # Preview what would be copied (dry run)
```

### Run installation scripts
```bash
./run               # Run all executable scripts in runs/
./run neovim        # Run only scripts matching "neovim"
./run --dry         # Preview what would run
```

## Repository Structure

- `.config/` - XDG config files copied to `~/.config/`
  - `nvim/` - Neovim config (Lua-based, uses lazy.nvim)
  - `tmux/` - tmux config with TPM plugin manager
  - `gh/` - GitHub CLI config
  - `git/` - Global git ignores
  - `aerospace/` - AeroSpace window manager (macOS)
  - `ghostty/` - Ghostty terminal config

- `.local/` - Files copied to `~/.local/`

- `env/` - Shell profiles copied directly to `~`
  - `.zsh_profile`, `.bash_profile` - Shell customizations (fzf, aliases, PATH)
  - `.fdignore` - fd ignore patterns
  - `zshrc-completion.zsh` - Zsh completion config

- `runs/` - Installation scripts (run via `./run`)
  - `neovim` - Build Neovim v0.11.0 from source
  - `tmux` - Build tmux 3.5a from source with TPM
  - `zsh` - Configure zsh to source `.zsh_profile`
  - `libs` - Install ripgrep, fd, and fzf
  - `ai` - Install Claude Code and OpenAI Codex CLI tools

- `zotcite-patches/` - Patches for the zotcite Neovim plugin (LaTeX/Zotero citation completion)

## Architecture Notes

**Deployment flow**: `dev-env` uses rsync to sync directories from `.config/` and `.local/` to their targets. Most directories sync with `--delete` (removes files not in source), but `claude/` and `codex/` directories sync without `--delete` to preserve local state. Shell profiles from `env/` are copied individually to `$HOME`.

**Neovim**: Entry point is `.config/nvim/init.lua`. Has separate paths for VSCode-Neovim mode vs regular Neovim. Plugin management via lazy.nvim configured in `lua/config/lazy.lua`.

**tmux**: Uses `C-a` prefix (not default `C-b`). Has vim-tmux-navigator for seamless pane/vim navigation. Session persistence via tmux-resurrect and tmux-continuum.
