# Ticket IDs

How the `commit` and `pr` skills tie work to a ticket so the tracker links it by itself.
The per-repo values (`tickets.tracker`, `tickets.pattern`, `tickets.close`) are in [`repo-config.md`](repo-config.md).

## Find the ID

A ticket is optional.
Plenty of work has none, so never ask for an ID or hold a commit or PR back for lack of one.

Take it from the user's request, or match `tickets.pattern` against the branch name (`git branch --show-current`).
**Never guess one** — not from a similar ticket, not from the topic of the change.
No ID found means no prefix and no trailer, not a placeholder.
If the branch names several tickets, ask which one the work closes.

Write the ID in the tracker's canonical case: `eng-12` in a Linear branch becomes `ENG-12` in the subject.

## Where it goes

| Place          | Form                                  |
| -------------- | ------------------------------------- |
| Commit subject | `PROJ-12/feat(api): add health check` |
| PR title       | Same as the lead commit's subject     |
| Branch         | The tracker's shape, table below      |
| PR body        | A link or close line, table below     |

The prefix counts toward the 72-character subject limit.
An ID of the form `#12` (GitHub, GitLab) never leads a subject: git drops lines starting with `#` as comments when a message is edited or reworded, so it goes in a trailer only.
If the history already places IDs another way (`[PROJ-12] feat: …`, `feat: … (PROJ-12)`), match the history.
A repo that runs commitlint may reject the prefix; check its config before adopting the form.

## What each tracker reads

| Tracker | Branch name                                      | Commit message                                                         | PR title             | PR body                                                       |
| ------- | ------------------------------------------------ | ---------------------------------------------------------------------- | -------------------- | ------------------------------------------------------------- |
| Linear  | Links; any case (`user/eng-12-slug`)             | Links only after a magic word (`Refs ENG-12`), if commit linking is on | Links                | Magic word + ID links or closes                               |
| Jira    | Links; key must be uppercase (`PROJ-12-slug`)    | Links on the bare key; `PROJ-12 #done` transitions (smart commit)      | Links                | Not read for linking                                          |
| GitHub  | Does not link                                    | `#12` links; a closing word closes once it reaches the default branch  | Not read for closing | `#12` links; a closing word closes on merge to default branch |
| GitLab  | Does not link (use `12-slug`, GitLab's own form) | `#12` links; a closing word closes once it reaches the default branch  | Not read for closing | `#12` links; a closing word closes on merge to default branch |

The Linear and Jira rows hold whether the code lives on GitHub or GitLab.
Linear's two GitHub apps, Linear and Linear Code, read IDs the same way.
Linear's commit linking is off until a workspace admin turns it on and adds the push webhook, so on a repo where commits don't show up in Linear the PR is what links.

Words, by tracker:

- **Linear** — link: `Refs`, `References`, `Part of`, `Contributes to`, `Toward` (moves the ticket through its started states, never to done).
  Relate: `Relates to`, `Related to` (links with no status change).
  Close: `Fixes`, `Closes`, `Resolves`, `Completes`, `Implements`.
  A magic word works in the PR title or body, never in a PR comment.
- **Jira** — no link words; the key is the link.
  Closing is a smart commit, `PROJ-12 #<transition>` (`#done`, `#close` — the workflow's own transition names), and runs only when the committer's email matches one Jira user.
  Never put a smart-commit command in a PR title: it lands in the merge commit and runs again.
- **GitHub** — link: a bare `#12` or `Refs #12`; another repo is `owner/repo#12`.
  Close: `Closes`, `Fixes`, `Resolves`.
- **GitLab** — link: a bare `#12` or `Related to #12`.
  Close: `Closes`, `Fixes`, `Resolves`, `Implements`; a project can turn auto-closing off.

## Link versus close

Linking ties the work to the ticket; closing moves it to done.
Choose per `tickets.close`:

| Policy             | Commits         | PRs                                                 |
| ------------------ | --------------- | --------------------------------------------------- |
| `commit` (default) | Close words OK  | Close words OK                                      |
| `pr`               | Link words only | Close words OK                                      |
| `last-pr`          | Link words only | Link words, except the PR that finishes the ticket  |
| `never`            | Link words only | Link words only — a person or a tracker rule closes |

Under any policy, use a close word only where that commit or PR finishes the ticket.
When you can't tell whether this PR is the last one, link and ask the user.

**Linear treats a PR linked by branch or title as closing**: by default, merging it moves the ticket to done.
Linear's docs don't say a link word in the body overrides that, so for a PR that must not close, leave the ID out of the title and write `Part of ENG-12` in the body.
If the branch already carries the ID, tell the user the ticket may still close on merge.
Linear waits for every linked PR to merge before moving the ticket, but a PR merged before the next one is opened is the only one linked at that moment.

**Jira closes nothing on its own.**
Under `commit`, close with a smart-commit transition, and only where the history shows the repo uses them; otherwise leave closing to Jira's automation.
