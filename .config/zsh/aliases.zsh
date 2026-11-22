# Aliases shared by zsh and Fish: ~/.zshrc sources this file and ~/.config/fish/config.fish
# reads its alias lines, so keep each one a single `alias name='...'` line.

alias ll='ls -lhF'   # Detailed list (human-readable sizes, no hidden files)
alias la='ls -lAhF'  # List all (including hidden, except . and ..)
alias l='ls -CF'     # Compact list
alias n='nvim'
alias ...='../..'
alias ....='../../..'
alias .....='../../../..'
alias ......='../../../../..'
alias md='mkdir -p'
alias rd=rmdir
alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gbd='git branch -d'
alias gc='git commit -v'
alias gcmsg='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gl='git pull'
alias gp='git push'
alias gst='git status'
alias gss='git status -s'
alias glo='git log --oneline --decorate'
alias glg='git log --stat'
alias glgp='git log --stat -p'

# Keep `ls` restrained: regular files use the foreground while file types get
# semantic accents (directories blue, links cyan, executables green).
export CLICOLOR=1
export LSCOLORS="exgxcxdxcxexexabagacad"
