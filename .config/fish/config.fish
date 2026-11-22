# Fish for interactive Rex tabs. ~/.zshrc execs into it after setting up the environment, so
# this file only adds what is interactive. Per-device Fish config goes in ~/.config/fish/conf.d,
# which is not in the dotfiles repo. The Pure prompt comes from Fisher:
# `fisher update` installs what fish_plugins lists.
set -g fish_greeting

if status is-interactive
    # codex, opencode and pi -w [name]: start in a worktree; see ~/.local/bin/worktree.
    function codex
        worktree codex $argv
    end

    function pi
        worktree pi $argv
    end

    # OpenCode reads its instructions from ~/.config/opencode/AGENTS.md; don't also load
    # ~/.claude/CLAUDE.md, which is the same file.
    function opencode
        OPENCODE_DISABLE_CLAUDE_CODE_PROMPT=1 worktree opencode $argv
    end
    alias oc opencode

    # Share zsh's aliases (ll, gst, ...). Fish only cds into a bare path at the prompt, so the
    # ../.. aliases get an explicit cd.
    for line in (string match -r '^alias .*' < $HOME/.config/zsh/aliases.zsh)
        eval (string replace -r "='\.\." "='cd .." -- $line)
    end

    # Record the current repo's workspace trust before launching Claude; only under ~/dev.
    function claude
        if test "$PWD" = "$HOME/dev"; or string match -q -- "$HOME/dev/*" "$PWD"
            worktree trust --quiet "$PWD" 2>/dev/null
        end
        command claude $argv
    end

    # eza for the zsh listing aliases (fish only; eza rejects ls's -F/-C, so plain ls stays ls).
    if type -q eza
        alias ll 'eza -l --git'
        alias la 'eza -la --git'
        alias l eza
    end

    # fzf: Ctrl-T inserts a file path (previewed with bat), Alt-C cds into a directory. Its
    # Ctrl-R is replaced by atuin below.
    set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
    type -q fzf; and fzf --fish | source

    # atuin owns Ctrl-R: full-screen history search, filterable by directory and exit status.
    # The up arrow keeps fish's own history.
    type -q atuin; and atuin init fish --disable-up-arrow | source

    # lg: lazygit. y: yazi, landing in the directory you were browsing when you quit.
    type -q lazygit; and alias lg lazygit
    if type -q yazi
        function y --description 'Browse files with yazi; cd to where you quit'
            set -l tmp (mktemp -t yazi-cwd.XXXXXX)
            yazi $argv --cwd-file="$tmp"
            set -l cwd (command cat -- $tmp)
            if test -n "$cwd"; and test "$cwd" != "$PWD"
                cd -- $cwd
            end
            rm -f -- $tmp
        end
    end

    # zoxide takes over cd: real paths work as before, and `cd proj` jumps to the most-used
    # directory matching "proj". `cdi` picks among matches with fzf.
    type -q zoxide; and zoxide init fish --cmd cd | source
end
