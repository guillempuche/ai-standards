# Worktrees, rebasing, and resuming

Read the section you need: where to work (Step 1), rebasing uncommitted work (Step 8, and when resuming), and resuming a run (Step 0).

## Where to work

The first case that applies wins.

1. **Already in a worktree.**
   Some agents start each session in one; compare the paths as absolute, since in a subfolder of the main checkout git prints one absolute and one relative:
   ```bash
   [ "$(git rev-parse --path-format=absolute --git-dir)" != "$(git rev-parse --path-format=absolute --git-common-dir)" ]
   ```
   Reuse it if it has no commits or changes of its own: rebase it onto `$base`, and if it has no branch (Codex starts worktrees on a detached HEAD), create one with `git switch -c <branch>`.
   If it already holds other work, ask the user rather than nesting a new worktree inside it.
   If the repo does not support worktrees (case 3), tell the user the stack may not run here, and ask whether to continue in this worktree or move to the main checkout.
1. **The repo has its own worktree command.**
   Use it instead of `git worktree add`: such commands often also assign ports, databases, or env files, and a bare git worktree would miss them.
   Take it from `worktrees.create` in the config, else look for one:
   ```bash
   grep -inE 'worktree' package.json justfile Makefile Taskfile.yml 2>/dev/null
   ls scripts bin 2>/dev/null | grep -i worktree
   grep -il worktree AGENTS.md CLAUDE.md CONTRIBUTING.md docs/*.md 2>/dev/null
   ```
   Pass it the branch name and `$base` if it takes them; otherwise check that the branch it made starts at `$base`, and rebase it if not.
1. **The repo does not support worktrees.**
   The config says `worktrees.supported: false`, or the repo's docs say so (fixed ports, one shared container or database, absolute paths baked into the setup).
   Ask the user before switching their main checkout to a new branch, and do it only if the checkout is clean:
   ```bash
   test -z "$(git status --porcelain)" && git switch -c <branch> "$base"
   ```
   If it is not clean, ask what to do with those changes; never stash or discard them yourself.
1. **Otherwise** create a plain git worktree inside the repo, so agents that keep the shell's directory only within the project still follow it:
   ```bash
   git worktree add -b <branch> .worktrees/<slug> "$base"
   exclude=$(git rev-parse --git-path info/exclude)
   grep -qxF '/.worktrees/' "$exclude" || echo '/.worktrees/' >> "$exclude"
   ```
   Use `git rev-parse --git-path info/exclude` rather than `.git/info/exclude`: inside a worktree `.git` is a file, not a directory.
   The leading `/` matters: without it the pattern hides a `.worktrees/` folder at any depth, in every worktree.
   If a tool run from the main checkout (a file watcher, a repo-wide lint or test glob) starts picking up `.worktrees/`, put the worktree in a sibling directory instead.

## Rebasing uncommitted work

The work stays uncommitted until the `pr` skill commits it, and `git rebase` refuses to run over uncommitted changes.
`--autostash` handles that, except that it fails while new files are marked with `git add -N`, so unmark them, rebase, and mark them again:

```bash
git fetch --prune "$remote"
new=$(git diff --name-only --diff-filter=A)
[ -n "$new" ] && git reset -q -- $new
git rebase --autostash "$base"
[ -n "$new" ] && git add -N $new
```

## Resuming a run

- Options in the new request override the ones recorded on the plan's `Input:` line.
- Fetch first; if the base moved, rebase as above and re-check the claims that touch files the base changed.
- Continue from the plan's `Status:` line: finish the audit rounds if fewer ran than `--audits` asks.
- After `approved`, compare the worktree's changes with the plan's steps and continue from the first step not done.
