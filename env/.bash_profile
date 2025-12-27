# fzf functionality
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# XDG config paths
export CLAUDE_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/claude"
export CODEX_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/codex"

# Path additions
export PATH="$HOME/.local/bin:$HOME/.local/scripts:$PATH"

# Aliases
alias inv='nvim $(fd | fzf -m --preview="bat --color=always {}")'
alias rsync="rsync -ahr --partial --partial-dir=/tmp/.rsync-partial --info=progress2 --no-inc-recursive -e 'ssh -T -o Compression=no' -c"
