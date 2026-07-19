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
- Optional: a **read-only** fine-grained GitHub PAT (GitHub → Settings →
  Developer settings → Fine-grained tokens → generate, with Contents and
  Metadata set to read-only, no write scopes) for `gh`/private-repo HTTPS
  access, available via `GH_TOKEN` in the environment or at
  `~/.config/gh/sandbox-token`. Don't use a normal `gh auth login` session
  here — that's write-capable, which defeats the point (see "GitHub is
  read-only" below). Without it, public GitHub repos still clone/fetch fine
  anonymously over HTTPS; only private repos and `gh` API calls need it.

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

`git-push-guard.sh` (also `PreToolUse`/`Bash`, also `CLAUDE_SANDBOX`-gated)
blocks any `git push` whose resolved remote isn't the Gitea host, and any
push to `main`/`master` even there — the sandbox workflow is feature branch
+ `gitea-pr create`, never a direct push. Like the other hooks, this is a
fast-fail guard against an overeager agent, not a hard security boundary: a
sandbox session has full shell access and could in principle edit
`.git/config` to route around it. For "never pushes to GitHub" specifically,
the firewall backs this up with real enforcement (see below); for "never
pushes to main/master", the authoritative version of that is branch
protection on the Gitea repo itself, which this doesn't set up for you.

## Network egress firewall

On start, the container runs an allowlist-only `iptables`/`ipset` firewall
(`init-firewall.sh`), matching the reference dev container. Allowed by
default: DNS resolution via Docker's embedded resolver (loopback only, so
never leaves the container), the Docker host itself (not its whole subnet),
GitHub's published IP ranges (port 443 only - see "GitHub is read-only"
below), `release-assets.githubusercontent.com` (GitHub release assets - e.g.
mason's own registry index - redirect here, a separate CDN from github.com's
own IPs), `registry.npmjs.org`, `pypi.org` and `files.pythonhosted.org`
(mason's Python-based LSP tools - `ruff`, `basedpyright`, `debugpy` - install
via pip), `api.anthropic.com`, and whatever hosts `GITEA_SSH_HOST`/
`GITEA_API` resolve to — that last group isn't port-restricted, so
git-over-ssh to Gitea works without a separate blanket "port 22 to anywhere"
rule. Set `ALLOWED_DOMAINS` (space-separated) in the environment to allow
more (e.g. `crates.io` for a Rust project needing more than what mason/npm
already cover). Everything else is rejected. Set `ENABLE_FIREWALL=0` to
disable it entirely (e.g. for debugging a blocked domain).

If your Gitea host is only resolvable via a LAN-local DNS server, make sure
the Docker host itself can resolve it — containers inherit the host's
resolver by default.

## GitHub is read-only

The sandbox can read from GitHub (clone, fetch, `gh` API calls) but can
never push there, and this is enforced at the network layer, not just by the
`git-push-guard.sh` hook above: GitHub's IP ranges are only allowlisted on
port 443. Port 22 is unreachable, so SSH-based push (which could otherwise
use the forwarded agent's real key - agent forwarding doesn't distinguish
"push" from "pull") has no transport to use at all, regardless of what any
hook does or doesn't catch. HTTPS access itself has no write-capable
credential either: `gh auth setup-git` (run at container start if `GH_TOKEN`
is set - see Prerequisites) points git's github.com credential helper at
`gh`, which only ever holds whatever token `GH_TOKEN` provides. Use a
read-only PAT there and even a push attempt over HTTPS gets rejected by
GitHub itself (403), not just blocked locally.

## Security notes

- `--dangerously-skip-permissions` removes your chance to review tool calls
  before they run. Only point this at trusted repositories.
- Because `~/.claude` (including `.credentials.json`) is bind-mounted in,
  anything reachable from inside the container (the allowed domains above)
  is a potential exfiltration path for those credentials if a malicious repo
  manages to manipulate a session. The firewall limits this to
  Anthropic/npm/GitHub/your Gitea host, not the open internet.
- `settings.json`, `CLAUDE.md`, and `plugins/` under `~/.claude` are
  layered back read-only on top of the (otherwise read-write) `~/.claude`
  mount. Hooks execute automatically with no separate approval step, so
  without this a compromised session could plant a backdoored hook, rewrite
  `CLAUDE.md` with injected instructions, or tamper with plugin code -
  something that would then run **unsandboxed on the host** the next time
  Claude Code starts there, turning a single compromised sandbox session
  into persistent host compromise. Everything else under `~/.claude`
  (session/project history, credentials refresh, caches) stays read-write,
  since it's runtime state Claude Code needs to update.
  `~/.claude.json` is a single file mixing that same kind of live state with
  config (e.g. `mcpServers`, if ever set) and can't be split at the mount
  level, so it's left fully read-write - accepted as a residual risk rather
  than solved.
- DNS resolution itself isn't filtered, only the IP connections made
  afterward - Docker's embedded resolver will still resolve arbitrary
  domains under lockdown (verified: `dig` on a non-allowlisted domain
  resolves fine, only the subsequent connect is blocked). A compromised
  session could still exfiltrate data by encoding it into DNS query names
  to an attacker-controlled domain, even though it can't open a direct
  connection anywhere off the allowlist. Not mitigated here.
- Don't mount other host secrets (`~/.ssh` private keys, cloud credential
  files) into the container. Git push auth goes through the forwarded SSH
  agent instead, which never exposes the key material itself - though note
  the agent will sign for *any* Gitea repo your key has access to, not just
  the mounted project, and the firewall's Gitea allowlist is host-based
  rather than repo-scoped, so a compromised session can still reach (and
  push to) other repos on that host you have access to. This doesn't extend
  to GitHub: port 22 there is blocked outright, so the forwarded agent has
  no transport to use for it at all (see "GitHub is read-only" above).
- The `node` user has no `sudo`/setuid path back to root once the container
  is up: `entrypoint.sh` runs as root, sets up the firewall directly, then
  drops to `node` via `gosu` before execing `nvim`. A compromised session
  can't re-run `init-firewall.sh` with a wider allowlist to open its own
  exfiltration path. Verified: capabilities (`NET_ADMIN`/`NET_RAW`) are
  cleared from the effective/permitted sets on the `gosu` drop, and `node`
  gets a permission error running `iptables` directly.

## Files

| File | Purpose |
| --- | --- |
| `Dockerfile` | Base image, dev tools, nvim, Claude Code + wrapper, `gitea-pr` |
| `init-firewall.sh` | Egress allowlist firewall, run at container start |
| `entrypoint.sh` | Runs as root: sets up the firewall, drops to `node` via `gosu`, execs `nvim` |
| `claude-wrapper.sh` | Shadows `claude` on `PATH` to always add `--dangerously-skip-permissions` |
| `docker-compose.yml` | Wires up mounts/env; invoked via `bin/claude-sandbox`, not directly |

`bin/claude-sandbox` (repo root `bin/`) is the entry point — it resolves the
project path, checks for a live `ssh-agent`, loads `GITEA_TOKEN`/`GH_TOKEN`
if not already set, and runs `docker compose run`.
