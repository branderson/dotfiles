# Global preferences

## Development Guidelines

- ALWAYS implement minimal changes to accomplish your task, nothing unecessary
- NEVER introduce unecessary complexity or side-effects on other code
- NEVER write unecessary comments, only minimal comments to describe functionality which isn't obvious from reading the code
- ALWAYS respect the existing style of the repository
- ALWAYS implement the best possible solution to a problem you can find
- NEVER reinvent the wheel. if there's an established, accepted way to do something which doesn't introduce unecessary complexity, use it
- NEVER include co-authorship lines in a git commit
- NEVER commit to a git repository except when bootstrapping your own fresh repositories


## Spec documents

When a skill or workflow (e.g. brainstorming) would write a design spec/plan document
to a project-local path like `docs/superpowers/specs/`, write it to `~/specs/` instead,
using the same `YYYY-MM-DD-<topic>-design.md` naming convention. Do not commit spec
documents into project git repositories unless explicitly asked to.

## Gitea PR review workflow

For repos whose `origin` remote is on `gitbox.bradina.localdomain`: when the
finishing-a-development-branch skill's "Push and create PR" option is chosen,
after pushing, also run `gitea-pr create` (from dotfiles `bin/`) to actually
open the PR, and report the printed URL back. Always pass `--title`/`--body`
with a real summary of the changes, the reasoning behind them, and what was
tested — never placeholder or throwaway text, even for a call made mainly to
test other behavior (e.g. testing that a duplicate-PR check short-circuits):
if it turns out to actually create a PR, that text ships as the PR
description.

When asked to check or address PR feedback, run `gitea-pr comments <PR#>`,
make the requested changes, commit, push, and report back. Repeat for as many
rounds as needed. Only check feedback when explicitly asked — do not poll
proactively.

Never run `gitea-pr merge` unless explicitly instructed to merge in that turn.
