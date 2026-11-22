## Getting a project

    gh repo clone <owner>/<repo> ~/dev/<repo>

## The main checkout stays on main

`~/dev/<repo>` is the reference checkout: it stays on the repository's primary branch and is never
a work target. `worktree sync` fetches and fast-forwards it; `worktree sync --all` does every
project under `~/dev`.

An agent launch in the main checkout is refused unless it is a worktree (`-w`). Pass `--here` for
a deliberate read-only look there, and `--base REF` to start a worktree from an explicit ref. A
`-w` launch also refuses to start while the main checkout is on another branch; run `worktree sync`
first, or pass `--base`.

## Creating a worktree

From inside the project, start your worktree with `-w`:

    <agent> -w <name>   # claude, codex, opencode or pi: works in .<agent>/worktrees/<name>

For example, `codex -w add-search` works in `.codex/worktrees/add-search` on a new local branch,
`codex/add-search`, based on the latest `origin/main` (the remote's default branch), not on
whatever the checkout had checked out. The helper fetches first; `--no-fetch` uses the refs it
already has, and a failed fetch says so and falls back to them. Leave out the name to get a
made-up one like `bright-running-fox`. Run it again to
come back to it. To stack a worktree on the current branch instead of main, pass `--base HEAD`.

Claude's built-in `-w` uses the same convention through its `WorktreeCreate` hook:
`.claude/worktrees/<name>` on branch `claude/<name>`. Reopening an older `worktree-<name>`
worktree renames that branch to `claude/<name>`.

Rename the branch to say what it does before the first push.

Agents: if you are already running, do not start another agent with `-w`. Create your worktree
with git, using your own name for `<agent>`, then work only inside it:

    git worktree add .<agent>/worktrees/<name> -b <agent>/<name> origin/main

## Agent workspace trust

Claude and Codex key workspace trust on each git repository root, and a parent folder's trust does
not cover the repositories nested under it. Pi walks up to the nearest parent entry. OpenCode has
no workspace-trust store; its permissions already decide what it may do.

`worktree trust --all` marks `~/dev` and every repository under it trusted in Claude
(`~/.claude.json`), Codex (`~/.codex/config.toml`) and Pi (`~/.pi/agent/trust.json`). The `claude`
shell function does it for the current repository before launch, and `worktree` does it for
codex/pi worktree launches. A worktree uses its main checkout's root for Claude and Codex; Pi's
parent trust covers it.

This bypasses the trust dialogs. Only use it for repositories you trust. To undo, set the
repository's trust back to `false` or remove its entry from the relevant file.

## Multi-repo tasks

Use the same branch name in each repository's own `.<agent>/worktrees/<name>`; the branch name is
the grouping. Do not create a `~/dev/.<task>/` directory of clones or worktrees — that layout is
what `worktree clean --tasks` cleans up, and it duplicates a checkout per repository. If you want
a group view, keep a short manifest or a folder of symlinks, not copies.

## Writing with ask

`ask -w` (write) runs in its own worktree because `~/.ask/settings.json` sets `"worktree": true`;
`ask -w "..."` is enough. A write follow-up to a run that started in a plain checkout is refused,
and a write outside a git repository is refused. Do not use `ask -w` in `~/dev/<repo>`.

## Cleaning up

`worktree clean` cleans the current repository, or everything under `~/dev` when run outside one.
`worktree clean --all` cleans every repository and task clone under `~/dev`, plus the current
repository; `--tasks` cleans task clones only, and `--root DIR` changes the managed root. Locked
worktrees (an active agent), dirty worktrees, and unlanded branches stay. A live ask run keeps
every ask worktree; direct agent sessions are git-locked while they run. Add `--superseded` to
also remove worktrees whose work was reworked into main but is not an exact patch, or
`--contained` for work whose commits another branch still holds (the worktree goes; its branch
stays). Without `--yes`/`-y` it only prints the plan and a summary. `ask clean` does the same for
ask's own worktrees, with `--contained` and `--superseded`, and removes old run records; use
`worktree clean` for worktrees a run no longer records.
