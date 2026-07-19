#!/usr/bin/env bash
# SessionStart hook: when running inside the claude-sandbox Docker container
# (see ~/dotfiles/docker/claude-sandbox), inject a reminder of the sandbox's
# constraints and how to escape it. No-op outside the container.

if [ -z "${CLAUDE_SANDBOX:-}" ]; then
    exit 0
fi

session_id=$(jq -r '.session_id // empty')
resume_id="${session_id:-<unknown-session-id>}"

context=$(cat <<EOF
You are running inside the claude-sandbox Docker container
(~/dotfiles/docker/claude-sandbox), not directly on the user's machine, with
--dangerously-skip-permissions active (no tool-use confirmations).

What this means:
- The workspace directory is bind-mounted read-write and is the real
  project, but everything else in the container besides ~/.claude is
  disposable: installed system packages, anything outside the mounted
  paths, and the container itself go away when this run ends.
- Outbound network is restricted to an allowlist (Anthropic's API, the npm
  registry, GitHub, the configured Gitea host, plus anything set via
  ALLOWED_DOMAINS). Requests to anything else will simply fail to connect.
- Stay within the task you were given. Since there are no permission
  prompts here, be more conservative than usual about anything destructive,
  irreversible, or outside the project directory.

If a task genuinely needs something the sandbox can't provide - broader
network access, host-level or system changes, GUI/hardware access, or
anything blocked by the firewall - stop and explain clearly to the user what
you need and why, instead of trying to work around the firewall or sandbox
yourself. They can continue this exact session outside the container by
running on the host:

  claude --resume $resume_id

(session history is shared via the bind-mounted ~/.claude, so it will pick
up right where this left off).
EOF
)

jq -n --arg context "$context" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $context
  }
}'
