# Interactive zsh, the same on every machine. Per-device environment (Homebrew, caches, host
# extras) goes in that machine's ~/.zprofile, which is not in the dotfiles repo.

# Use Mosh's adaptive local echo to smooth latency while limiting speculative redraws.
export MOSH_PREDICTION_DISPLAY=adaptive

export PATH="$HOME/.local/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

autoload -Uz compinit && compinit -C

# Rex renders the terminal; zsh supplies inline command suggestions and completion.
# Prefer recent history, then zsh's completion engine. Tab accepts a visible suggestion
# and falls back to normal completion when there is no suggestion to accept.
autosuggestions=${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
if [[ "${TERM_PROGRAM:-}" == rex && -r $autosuggestions ]]; then
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  source $autosuggestions
  if (( ! ${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[(I)expand-or-complete]} )); then
    ZSH_AUTOSUGGEST_ACCEPT_WIDGETS+=(expand-or-complete)
  fi
fi
unset autosuggestions

[[ -f "$HOME/.config/zsh/aliases.zsh" ]] && source "$HOME/.config/zsh/aliases.zsh"
alias oc='opencode'

# Pure: two-line prompt with async git status, dirty marker and exit code.
# Skip git integration under coding agents; nothing reads the prompt there and
# `git fetch` can stall inside a sandbox.
if [[ -n $AI_AGENT$CLAUDECODE$CURSOR_AGENT$GEMINI_CLI$OPENCODE ]]; then
  zstyle :prompt:pure:git show no
fi

autoload -Uz promptinit && promptinit
prompt pure 2>/dev/null || PROMPT=$'❯ '

# codex, opencode and pi -w [name]: start in a worktree; see ~/.local/bin/worktree.
# Claude's own -w works in .claude/worktrees/<name> on branch worktree-<name>.
codex() { worktree codex "$@"; }
pi() { worktree pi "$@"; }
# OpenCode reads its instructions from ~/.config/opencode/AGENTS.md; don't also load ~/.claude/CLAUDE.md,
# which is the same file.
opencode() {
  OPENCODE_DISABLE_CLAUDE_CODE_PROMPT=1 worktree opencode "$@"
}
# Claude and Codex key workspace trust on each git repository root, and ~/dev's trust does not
# cover the repositories nested under it. Pi walks up to a parent. Record the current repo's trust
# before launch so the agent does not stop for the dialog; a worktree uses its main checkout's
# root. Only under ~/dev.
claude() {
  if [[ $PWD == $HOME/dev || $PWD == $HOME/dev/* ]]; then
    worktree trust --quiet "$PWD" 2>/dev/null || true
  fi
  command claude "$@"
}

# Interactive Rex tabs run Fish (with Pure; see ~/.config/fish/config.fish). zsh stays the login
# shell, so agents and scripts get zsh, and Fish inherits the environment set up above.
if [[ -o interactive && -o login && ${TERM_PROGRAM:-} == rex ]] && command -v fish >/dev/null; then
  exec fish --login
fi
