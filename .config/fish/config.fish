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
end
