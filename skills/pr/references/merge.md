# Merge

Choosing rebase or squash, checking that each commit builds, and landing stacked pull requests.
Read this from Step 9 of the `pr` skill.

Decide using the size rule and the build check below, then post the commit trail with a one-line summary per commit, recommend squash or rebase with the reason, and confirm before merging:

```bash
git log <default-branch>..HEAD --oneline
```

**Size decides the starting point.**
A short trail — a handful of commits, each a focused topic — rebases.
A long one is a sign the work sprawled, and squashing to one commit is usually the better end state; the individual commits stay visible on the PR page either way, so squashing costs a reviewer nothing.

**Then check the trail is worth keeping, because a rebase puts every commit on the default branch forever.**
The reason to prefer rebase is that someone can later bisect to the commit that broke something, and that only works if each commit builds on its own.
Verify it rather than assuming:

```bash
for sha in $(git rev-list --reverse <default-branch>..HEAD); do
  git checkout -q $sha
  <typecheck gate> >/dev/null 2>&1 && echo "OK   $(git log --oneline -1)" || echo "FAIL $(git log --oneline -1)"
done
git checkout -q -
```

If commits fail, **squash**: rebasing them puts broken revisions on the mainline, which is worse than one honest commit, because a bisect lands on a build failure and tells you nothing.

This bites hardest after regrouping a sprawling trail by topic.
Splitting by area is the natural way to make a big PR readable, and it reliably produces commits that do not build alone, because a file in one group references something that only arrives in another.
Regrouping is still worth doing — it buys readability, not bisectability.
Do not offer bisect as its justification.

If squashing, draft the squashed message through the `commit` skill first so it is reviewable.

```bash
gh pr merge <N> --rebase --delete-branch    # or --squash --delete-branch
```

**Never `--delete-branch` a PR that another open PR is stacked on.**
GitHub closes the child instead of retargeting it, and a PR closed because its base branch was deleted cannot be reopened or retargeted — it has to be recreated from scratch.
To land a stack: merge each parent **without** `--delete-branch`, retarget the child and rebase it onto the mainline, then delete the orphaned branches once nothing targets them.

If the rebase hits conflicts, pause and surface it: rebase locally, force-push, then retry the rebase merge.
Never fall back to a merge commit.

`--delete-branch` removes the remote branch only.
Afterwards drop the local one, and if the work was done in a worktree, remove and prune it.
