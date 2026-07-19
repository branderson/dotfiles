# claude-sandbox

Runs Claude Code inside a Docker container with `--dangerously-skip-permissions`
(no permission prompts, all tool use auto-accepted) against a project mounted
from the host. Based on
[Anthropic's reference dev container](https://github.com/anthropics/claude-code/tree/main/.devcontainer):
same base image, non-root user, and egress-firewall approach, adapted to run
via `docker compose` directly instead of through a VS Code dev container, and
extended with this user's own nvim config and a `gitea-pr` helper for
opening/iterating on PRs.

This directory (`docker/claude-sandbox/`) only holds the tooling. It is
**not** where any project lives — the project you point it at is bind-mounted
into the container at runtime from wherever it actually sits on disk.

## Prerequisites

- Docker with the `docker compose` v2 plugin.
- `ssh-agent` running with the key for your Gitea remote(s) added
  (`ssh-add -l` should list it). The container never sees your private key,
  only a forwarded agent socket.
- `GITEA_SSH_HOST` and `GITEA_API` exported in your shell (same variables
  `bin/gitea-pr` already needs — see its `require_config`), and a token
  available either via `GITEA_TOKEN` in the environment or at
  `~/.config/gitea/token`.

## Usage

```sh
bin/claude-sandbox                        # sandbox the current directory
bin/claude-sandbox ~/repos/some-project
bin/claude-sandbox ~/repos/some-project src/foo.py   # open a specific file
```

The entry point is nvim, opened on the bind-mounted project directory, using
this user's real nvim config (`config/nvim`, including
[claudecode.nvim](https://github.com/coder/claudecode.nvim) — `<leader>ac`
toggles a Claude Code terminal). `claude` is also on `PATH` directly for use
from any shell/terminal inside the container. Either way it always runs with
`--dangerously-skip-permissions`, regardless of how it's invoked.

Typical loop: open the project, ask Claude to implement something and open a
PR (it has `gitea-pr` on `PATH`); from the host, `gitea-pr comments <PR#>` to
pull review feedback, feed it back in, repeat.

## Config parity with your host Claude Code setup

`~/.claude` and `~/.claude.json` are bind-mounted read-write from the host
into the container, so global `CLAUDE.md`, settings, hooks, plugins, MCP
server config, and your existing login/credentials all carry over
automatically — the container is a faithful copy of this setup, not a
separate identity. There's no separate first-run login.

The project directory is mounted at the *same absolute path* inside the
container as on the host (not a fixed `/workspace`), so Claude Code's
project/session-history keying lines up between host and container. A
session started in the sandbox can be resumed on the host afterward with
`claude --resume <session-id>`.

Caveat: MCP servers or hooks that shell out to host-specific binaries (e.g. a
browser for Playwright, a language runtime not installed in this image) may
not work inside the container unless that tooling is also added to the
`Dockerfile`.

## Sandbox self-awareness

A `SessionStart` hook (`~/.claude/hooks/sandbox-context.sh`, registered in
`~/.claude/settings.json`) checks for the `CLAUDE_SANDBOX` environment
variable this container sets, and when present, injects a reminder that the
session is running in a disposable, firewalled container and should stay
within the task at hand — and that if a task genuinely needs to break out of
the sandbox (broader network access, host-level changes, GUI/hardware), it
should stop and tell the user rather than trying to work around the
firewall, since the same session can be resumed unrestricted on the host via
`claude --resume`. It's a no-op outside the container. This is on top of the
existing `deny-dangerous-bash.sh` `PreToolUse` hook, which also applies here
since `~/.claude` is shared.

## Network egress firewall

On start, the container runs an allowlist-only `iptables`/`ipset` firewall
(`init-firewall.sh`), matching the reference dev container. Allowed by
default: DNS, SSH (port 22, for git-over-ssh to any host), the Docker
bridge/host subnet, GitHub's published IP ranges, `registry.npmjs.org`,
`api.anthropic.com`, and whatever hosts `GITEA_SSH_HOST`/`GITEA_API` resolve
to. Set `ALLOWED_DOMAINS` (space-separated) in the environment to allow
more (e.g. `crates.io` for a Rust project needing more than what mason/npm
already cover). Everything else is rejected. Set `ENABLE_FIREWALL=0` to
disable it entirely (e.g. for debugging a blocked domain).

If your Gitea host is only resolvable via a LAN-local DNS server, make sure
the Docker host itself can resolve it — containers inherit the host's
resolver by default.

## Security notes

- `--dangerously-skip-permissions` removes your chance to review tool calls
  before they run. Only point this at trusted repositories.
- Because `~/.claude` (including `.credentials.json`) is bind-mounted in,
  anything reachable from inside the container (the allowed domains above)
  is a potential exfiltration path for those credentials if a malicious repo
  manages to manipulate a session. The firewall limits this to
  Anthropic/npm/GitHub/your Gitea host, not the open internet.
- Don't mount other host secrets (`~/.ssh` private keys, cloud credential
  files) into the container. Git push auth goes through the forwarded SSH
  agent instead, which never exposes the key material itself.

## Files

| File | Purpose |
| --- | --- |
| `Dockerfile` | Base image, dev tools, nvim, Claude Code + wrapper, `gitea-pr` |
| `init-firewall.sh` | Egress allowlist firewall, run at container start |
| `entrypoint.sh` | Runs the firewall, then execs `nvim` |
| `claude-wrapper.sh` | Shadows `claude` on `PATH` to always add `--dangerously-skip-permissions` |
| `docker-compose.yml` | Wires up mounts/env; invoked via `bin/claude-sandbox`, not directly |

`bin/claude-sandbox` (repo root `bin/`) is the entry point — it resolves the
project path, checks for a live `ssh-agent`, loads `GITEA_TOKEN` if not
already set, and runs `docker compose run`.
