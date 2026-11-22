/**
 * worktree: OpenCode's worktree plugin (V2). Before each shell command, blocks a `git push` from
 * a local agent branch (like opencode/<name>) with the reason blockReason gives. OpenCode's
 * background service picks up changes to this file on its own.
 */
import { spawnSync } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";

const agentBranch = /^(codex\/|pi\/|opencode\/|ask\/|claude\/|worktree-)/;
const gitPush = /(^|[;&|\s(])git\s+(-C\s+([^\s;&|]+)\s+)?push(\s|$)/;
const leadingCd = /^\s*cd\s+([^\s;&|]+)\s*(&&|;)/;

/**
 * The reason to block `command` run in `cwd`, or undefined to let it through. Agent branch
 * names (codex/*, pi/* and opencode/* from ~/.local/bin/worktree, ask/*, claude/* from Claude
 * Code's WorktreeCreate hook, and older worktree-* branches) are local placeholders, so a
 * `git push` from one is blocked. The push's directory is `git -C DIR`, else a leading `cd DIR &&`,
 * else `cwd`. Any failure lets the command through. The same check lives in OpenCode's and Pi's
 * worktree plugins and in ~/.agents/hooks/worktree (Claude Code and Codex); keep the prefixes in sync.
 */
function blockReason(command: string, cwd: string): string | undefined {
  const push = command.match(gitPush);
  if (!push) return undefined;
  let dir = (push[3] ?? command.match(leadingCd)?.[1] ?? "").replace(/["']/g, "");
  if (!dir) dir = cwd;
  else if (dir.startsWith("~")) dir = homedir() + dir.slice(1);
  else if (!dir.startsWith("/")) dir = join(cwd, dir);
  const git = spawnSync("git", ["-C", dir, "branch", "--show-current"], { encoding: "utf8", timeout: 5000 });
  const branch = git.status === 0 ? git.stdout.trim() : "";
  if (!agentBranch.test(branch)) return undefined;
  return `Blocked: '${branch}' is a local agent branch name. Before the first push, rename it to say what its commits do, without the agent prefix (git branch -m <name>), then push again.`;
}

export default {
  id: "worktree",
  async setup(ctx: any) {
    await ctx.shell.hook("create.before", (event: { command: string; cwd: string }) => {
      const reason = blockReason(event.command, event.cwd);
      if (reason) throw new Error(reason);
    });
  },
};
