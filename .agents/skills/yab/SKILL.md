---
name: yab
description: Yab is the user's own browser, signed in to their sites. Use it for anything on the web: opening, reading or searching pages, filling forms, clicking through sites, downloads, screenshots. Also whenever a task needs their accounts, open tabs, history, mail, files or preferences.
---

# Yab

Run `yab guide` before using Yab, and follow it.

`yab exec -f steps.js --json` drives tabs (`exec --help` lists limits and exit codes); `yab "task"`
hands a whole job to the model set for Tasks in Yab; `yab https://…` only opens a page.

If `yab` isn't on PATH, the user can add it in Yab › Settings › Developers. If `yab guide` reports a
newer skill version, tell the user — don't run `yab setup`, which would install a second
`yab-browser` skill beside this one.
