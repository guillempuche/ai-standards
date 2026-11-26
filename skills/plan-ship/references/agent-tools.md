# Tools in each agent

What to use for each action these skills take, in Claude Code, in Codex, and in any other agent.
The action always runs; only the tool changes, so say which row's fallback you used.

| Action                                    | Claude Code                                                                            | Codex                                                                                                                                                     | Any other agent, or none of these                                              |
| ----------------------------------------- | -------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| Ask the user a question                   | `AskUserQuestion`                                                                      | a plain message, then wait                                                                                                                                | a plain message, then wait                                                     |
| Review a diff for correctness bugs        | the `code-review` skill, at the depth below                                            | `codex review --uncommitted` for local changes, `codex review --base <branch>` for a branch                                                               | the agent's own review command, else a fresh reviewer, else a cold self-review |
| Get a fresh reviewer, not anchored on you | a subagent via the `Agent` tool, given only its brief                                  | a subagent, asked for explicitly (Codex spawns them only when asked)                                                                                      | re-read the material cold, once per lens, as a skeptical reviewer              |
| Readability pass                          | the `readability-improver` agent when installed                                        | the `readability-improver` custom agent when it is in `.codex/agents/` or `~/.codex/agents/`, else inline, against the `pr` skill's self-review checklist | inline, against the `pr` skill's self-review checklist                         |
| Run the app to check a change             | a verification skill when present (`run`, `/verify`)                                   | the changed path by hand: the command, the endpoint, or the page                                                                                          | the changed path by hand                                                       |
| Keep watching an open PR after you stop   | suggest the user type `/steward` when the session lists it; only the user can start it | run the `pr` skill again when the review comes in                                                                                                         | run the `pr` skill again when the review comes in                              |

A `roles:` entry in the repo config wins over this table when the session has what it names.
Agents in this plugin's `agents/` folder install only in Claude Code; Codex has one only after it is copied from `codex/agents/` into `.codex/agents/` or `~/.codex/agents/`, and other agents use the fallback in the same row.

## Review depth

A review runs at one of three depths, named the same in every agent.
The request picks it, else the skill's default.

| Depth      | Claude Code                                                                             | Codex                                                                 | Any other agent                                               |
| ---------- | --------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | ------------------------------------------------------------- |
| `quick`    | the self-read checklist; the security role on a sensitive surface                       | the same                                                              | the same                                                      |
| `standard` | the `code-review` skill at `high`                                                       | `codex review`                                                        | the agent's own review command, else a cold self-review       |
| `deep`     | the `code-review` skill at `max`, plus a fresh reviewer told to try to break the change | `codex review`, plus a fresh subagent told to try to break the change | its review command, plus a fresh reviewer with the same brief |

Every depth hands its findings to the rules in [`findings.md`](findings.md); a deeper review finds more, it does not trust more.
