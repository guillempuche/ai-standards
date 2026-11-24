# Review findings

How to handle a finding from any reviewer: a review tool, a subagent, a review bot, a person, or yourself.
Read this before acting on the findings of a code review.

## Verify

A finding is a hypothesis, not a fact.
Decide whether it holds **in this codebase, for its real callers and inputs**:

- Trace the path from the actual callers, or write a test or probe that triggers it.
- Check whether the triggering input can occur here at all — a type, a validator, or an upstream guard may already rule it out.

## Sort

Put each finding that holds in one of three groups:

- `important` — a bug this branch introduces or makes worse → fix it here.
- `pre-existing` — a bug already on the default branch → leave it out of this change, list it in the PR's `## Review guide`, and offer the user an issue for it.
- `nit` — a minor issue → fix it only when it is a small edit in a hunk you already touch; otherwise drop it.

## Record

Fix the `important` ones and re-run the check that proves each fix.
Keep one line on why for each finding you dismissed.
Carry anything you could not settle either way into the PR's `## Review guide`, rather than leaving it silent.
