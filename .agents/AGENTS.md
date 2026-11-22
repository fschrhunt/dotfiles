# Global Agent Instructions

- Preserve unrelated changes: never revert or reformat code you weren't asked
to touch.
- Never expose secrets.

## Working style

- Build complex things as simply as possible: fewer moving parts wins. No
abstraction layers, configuration, or generality beyond what the change in
front of you needs. Reducing complexity while solving the problem is a
valued contribution in itself.
- Propose bold ideas when they could meaningfully improve the work. Don't
self-censor down to safe suggestions; state the risk and let me decide.
- Tests are good; test slop is not. Write focused tests that each pin one
behavior worth protecting. No endless smoke tests, no tests that pin
deleted features or legacy behavior, no asserting that the framework works.
- Comment functions, classes, and modules with a concise note on purpose and
contract — what it's for and how it's meant to be used. Don't comment
line-by-line.
- When you change code, update every comment and doc your change touches.
A stale comment is worse than no comment.

## Git

- Before the first push, make sure the branch name makes sense: it should say
what the commits actually do. Agent branches (`codex/*`, `pi/*`,
`opencode/*`, `ask/*`, `claude/*`, `worktree-*`) keep that name only while local; rename
with `git branch -m` to drop it and describe the work. Never rename a branch
that's already pushed or has an open PR.
