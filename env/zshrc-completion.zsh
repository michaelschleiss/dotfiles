#
# Zsh completion + UI settings exported from ~/.zshrc
# Date: Dec 5, 2025
#

# Use custom completions (Codex, Claude, etc.)
fpath=("$HOME/.zsh/completions" $fpath)

# Better completion UI: menu with selection
zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''

# Smarter matching: case-insensitive + flexible separators
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Z}' \
  'r:|[._-]=* r:|=*'

# Initialize completion system
autoload -Uz compinit
compinit

# Codex completion (requires codex CLI installed)
eval "$(codex completion zsh)"

