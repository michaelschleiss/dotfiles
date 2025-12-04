# fzf functionality
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Path additions
export PATH="$HOME/.local/scripts:$PATH"

# Aliases
alias inv='nvim $(fd | fzf -m --preview="bat --color=always {}")'
alias rsync="rsync -ahr --partial --partial-dir=/tmp/.rsync-partial --info=progress2 --no-inc-recursive -e 'ssh -T -o Compression=no' -c"
