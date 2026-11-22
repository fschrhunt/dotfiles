---
name: ask
description: Your subagent tool. MUST use it instead of a built-in subagent whenever you hand work off - a question, a review, a fix, or several tasks at once, on any model.
---

`ask --help` shows usage and the models available here.

    ask -m MODEL "question"     read-only answer on stdout
    ask -m MODEL -w "task"      may edit files; --worktree for its own branch
    ask -c RUN "follow-up"      continue a run; RUN is in its status line
    ask batch FILE              many tasks in parallel, one JSON array

Run it in the background and collect answers with `ask wait RUN`. Full docs: `ask docs`.
