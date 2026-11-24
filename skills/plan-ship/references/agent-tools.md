# Tools in each agent

What to use for each action these skills take, in Claude Code, in Codex, and in any other agent.
The action always runs; only the tool changes, so say which row's fallback you used.

| Action                                    | Claude Code                                           | Codex                                                                                       | Any other agent, or none of these                                              |
| ----------------------------------------- | ----------------------------------------------------- | ------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| Ask the user a question                   | `AskUserQuestion`                                     | a plain message, then wait                                                                  | a plain message, then wait                                                     |
| Review a diff for correctness bugs        | the `code-review` skill, at the level asked           | `codex review --uncommitted` for local changes, `codex review --base <branch>` for a branch | the agent's own review command, else a fresh reviewer, else a cold self-review |
| Get a fresh reviewer, not anchored on you | a subagent via the `Agent` tool, given only its brief | a subagent, asked for explicitly (Codex spawns them only when asked)                        | re-read the material cold, once per lens, as a skeptical reviewer              |
| Readability pass                          | the `readability-improver` agent when installed       | inline, against the `pr` skill's self-review checklist                                      | inline, against the `pr` skill's self-review checklist                         |
| Run the app to check a change             | a verification skill when present (`run`, `/verify`)  | the changed path by hand: the command, the endpoint, or the page                            | the changed path by hand                                                       |

A `roles:` entry in the repo config wins over this table when the session has what it names.
Agents in this plugin's `agents/` folder load only in Claude Code; in other agents, use the fallback in the same row.
