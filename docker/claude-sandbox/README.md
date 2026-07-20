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
- Optional: `LOKI_URL` (a base URL, e.g. `http://loki.internal:3100`) to ship
  DNS-query and firewall allow/reject logs to a Loki push endpoint - see
  "Network request logging" below. Logging is skipped entirely if unset.

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

## Shared scratch space

`~/shared` inside the container is a read-write bind mount of a real host
directory (`$SANDBOX_SHARE_DIR`, default `~/.local/share/claude-sandbox/shared`,
created automatically) - separate from the project mount, for passing files
(screenshots, temp scripts) back and forth with a sandboxed session without
touching the actual project checkout. It persists across sessions since it's
a real directory, not a container volume. Set `SANDBOX_SHARE_DIR` to point
it somewhere else.

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

sandbox-context.sh also tells the agent the actual workflow to follow
proactively, not just what's blocked: do new work in a `git worktree`
rather than switching branches in the mounted checkout in place (that's the
user's real working copy), then push the feature branch and run
`gitea-pr create` from the worktree.

## Network egress firewall

On start, the container runs an allowlist-only `iptables`/`ipset` firewall
(`init-firewall.sh`), matching the reference dev container. Allowed by
default: DNS resolution via a local DNS proxy (see "DNS is allowlisted too"
below), the Docker host itself (not its whole subnet), GitHub's published IP
ranges (port 443 only - see "GitHub is read-only" below),
`release-assets.githubusercontent.com` (GitHub release assets - e.g. mason's
own registry index - redirect here, a separate CDN from github.com's own
IPs), `registry.npmjs.org`, `pypi.org` and `files.pythonhosted.org` (mason's
Python-based LSP tools - `ruff`, `basedpyright`, `debugpy` - install via
pip), `api.anthropic.com`, and whatever hosts `GITEA_SSH_HOST`/`GITEA_API`
resolve to — that last group isn't port-restricted, so git-over-ssh to Gitea
works without a separate blanket "port 22 to anywhere" rule. Set
`ALLOWED_DOMAINS` (space-separated) in the environment to allow more (e.g.
`crates.io` for a Rust project needing more than what mason/npm already
cover). Everything else is rejected. Set `ENABLE_FIREWALL=0` to disable it
entirely (e.g. for debugging a blocked domain).

IPv6 is blocked outright (`ip6tables` policy DROP on INPUT/OUTPUT/FORWARD,
and dnsmasq strips AAAA answers so nothing wastes a connection attempt on an
address that could never be reached) - there's no IPv6 equivalent of the
allowlist above, so leaving it open would bypass the entire firewall on any
host with IPv6 egress enabled.

If your Gitea host is only resolvable via a LAN-local DNS server, make sure
the Docker host itself can resolve it — containers inherit the host's
resolver by default.

### DNS is allowlisted too

Resolution itself is restricted, not just the IP connections made
afterward: `dns-proxy.sh` runs a local `dnsmasq` bound to 127.0.0.1 with no
fallback resolver, and `/etc/resolv.conf` is repointed at it. Only names
matching the same allowlist as above (plus `github.com`/
`githubusercontent.com`/`githubassets.com`, needed since GitHub is
allowlisted by IP range rather than by resolving those names - see
`fixed-domains.sh`) get forwarded to Docker's real resolver; anything else
gets no upstream configured at all and is refused outright. Without this, a
compromised session could still exfiltrate data by encoding it into query
names to an attacker-controlled domain even though it could never open a
direct connection there - IP-based filtering alone doesn't stop that, since
the DNS query itself was never restricted.

### Adding a domain to a running session

`ALLOWED_DOMAINS` only takes effect at container start. For a domain a
*running* session needs right now, run from the host (not inside the
sandbox — it has no privilege to do this itself):

```sh
bin/claude-sandbox-allow crates.io                # this session only
bin/claude-sandbox-allow crates.io --global       # + persist in config/profile
```

It first adds the domain to the running dnsmasq's allowlist (appends a
`server=` line to its servers-file and sends `SIGHUP` to reload just that
file - no restart), then resolves it through the now-unblocked container
resolver and adds the IP(s) to the running firewall's `ipset`, all via
`docker exec -u root`. `--global` also appends the domain to
`ALLOWED_DOMAINS` in `config/profile` for future sessions; source your shell
(or open a new one) for that part to take effect. If more than one
claude-sandbox container is running, pass `--container <name>` to
disambiguate (`docker ps` to find it).

The sandbox-context.sh `SessionStart` hook tells the agent to ask for this
by name when a task is blocked on a single missing domain, rather than
stopping the whole session over it.

## Network request logging

If `LOKI_URL` is set (see Prerequisites), every DNS query and every new
outbound connection attempt - allowed or rejected - is shipped to that Loki
endpoint. Two sources, both tailed and pushed by `log-shipper.sh`:

- `dns-proxy.sh`'s dnsmasq logs every query and whether it was forwarded
  (allowed) or refused (not on the allowlist) - labeled `job=claude-sandbox-dns`.
- `init-firewall.sh` tags its terminal ACCEPT/REJECT rules with `NFLOG`
  (group 1 for allowed, group 2 for rejected), which `ulogd2`
  (`ulogd.conf`) turns into JSON lines with source/dest IP, port, and an
  `action` field - labeled `job=claude-sandbox-net`. Only new connection
  attempts are logged, not every packet: the firewall's existing
  ESTABLISHED,RELATED rule short-circuits the rest of a connection before it
  ever reaches the tagged rules.

This is visibility on top of the firewall/DNS-proxy enforcement above, not a
substitute for it - nothing about logging changes what's actually allowed to
resolve or connect.

### Viewing logs in Grafana

Nothing sandbox-specific needed on the Grafana side beyond a Loki data
source pointed at wherever `LOKI_URL` resolves to (Connections → Data
sources → Loki, if one isn't already configured against that instance) -
`log-shipper.sh` pushes directly to Loki's HTTP API, there's no Prometheus
scrape target or exporter involved.

In Grafana's Explore view (or a dashboard panel with a Loki query), both
streams are selectable by their `job` label:

```logql
{job="claude-sandbox-dns"}                          # every DNS query + verdict
{job="claude-sandbox-net"}                          # every connection attempt, as JSON
```

Useful filters on top of those:

```logql
# DNS lookups that got refused (not on the allowlist)
{job="claude-sandbox-dns"} |= "REFUSED"

# Rejected connections only (parses ulogd2's JSON, filters on its action field)
{job="claude-sandbox-net"} | json | action="blocked"

# Both streams together, e.g. to watch a live session across sources
{source="claude-sandbox"}
```

`{job="claude-sandbox-net"}` lines are one full ulogd2 JSON object per
connection attempt (`| json` in a query unpacks fields like `dest_ip`,
`dest_port`, `action`) - Loki's Explore view shows these expandable/
pretty-printed by default, no extra parsing setup needed.

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

**Threat model, honestly stated:** this reduces the blast radius of a
misbehaving or prompt-injected coding agent - it does not make it safe to
point at arbitrary untrusted or adversarial input, and it does not turn
`--dangerously-skip-permissions` into something without real risk. Point it
at repositories you already trust. Everything below is about how bad a
compromised session *inside* that trust boundary can get, not a claim that
one can't happen.

- `--dangerously-skip-permissions` removes your chance to review tool calls
  before they run. Only point this at trusted repositories.
- The mounted project itself has **no write protection**. `deny-dangerous-
  bash.sh` and `git-push-guard.sh` are regex pattern-matching on the literal
  Bash command string - a fast-fail guard against an overeager agent doing
  something obviously destructive, not a boundary against one that's
  actively trying to get around them (a different scripting language, an
  encoded command, editing `.git/config` directly all sail right through).
  Nothing here stops a compromised or badly-instructed session from
  modifying or deleting the real working copy it's mounted against.
- Allowing egress to a domain at all creates a channel for exfiltrating data
  through *that service's own request surface* (query strings, lookups,
  etc.), not just to a literal attacker-controlled destination. Domain-level
  allowlisting closes off reaching somewhere new; it can't inspect or
  restrict what gets sent to somewhere already trusted for normal operation
  (installing packages, calling the model API). That's a structural limit of
  allowlist-only firewalls in general, not something specific to this setup,
  and nothing here addresses it.
- This is container-level isolation (Linux namespaces plus a small
  capability set), not VM-level isolation - no gVisor/Firecracker or
  similar. It shares the host kernel, so a container-escape vulnerability
  would defeat every other control described here at once.
- Everything in this document has been verified by hand, at a point in
  time - there's no automated test suite re-checking these properties on
  every change, so a future edit could silently reintroduce a gap. This has
  already happened once in this file's own history (a missing `ipset`
  dedup flag broke firewall startup entirely, twice, on two different
  ipsets, before being caught).
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
- DNS resolution itself is allowlisted (see "DNS is allowlisted too" above),
  not just the IP connections made afterward, closing off exfiltration via
  encoding data into query names to an attacker-controlled domain - verified
  a non-allowlisted domain gets refused outright (`status: REFUSED`) rather
  than resolving and then only failing to connect.
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

## Tests

`test/` has a [bats](https://github.com/bats-core/bats-core) suite covering
the security invariants above - not a substitute for reading this document,
but a way to actually catch a future change silently breaking one of them
instead of finding out the hard way:

```sh
bats docker/claude-sandbox/test/               # everything
bats docker/claude-sandbox/test/static.bats     # fast, no Docker/build needed
SKIP_BUILD=1 bats docker/claude-sandbox/test/runtime.bats   # reuse the current image
```

`static.bats` greps the repo's own files - no sudo in the `Dockerfile`, every
`ipset add` is duplicate-safe, no `docker.sock`/host-credential mounts, the
`~/.claude` read-only overlay lines are present, `bin/claude-sandbox-allow`
rejects a malicious domain argument. `runtime.bats` builds the image, boots
a real container running the actual `entrypoint.sh` (a `SANDBOX_TEST_MODE`
env var makes it stop just short of execing `nvim`, so the suite can attach
to a fully-initialized container instead of reimplementing its own copy of
the setup sequence), and asserts against it: IPv6 blocked, DNS/IP allowlist
enforcement in both directions, GitHub read-only, no working `sudo`/
`iptables`/`init-firewall.sh` as `node`, capabilities actually stripped
(not just absent from a `docker exec` that doesn't have them to begin
with), `ulogd2` unprivileged, and the dynamic-ipset CDN-rotation fix.

Every mutation in `runtime.bats` (firewall rules, `ipset` entries) happens
inside the test container's own network namespace, same as any other
container - none of it touches the host. Container/network names are
derived from bats' own per-run temp directory, not anything guessable or
likely to collide with a real container you have running.

## Files

| File | Purpose |
| --- | --- |
| `Dockerfile` | Base image, dev tools, nvim, Claude Code + wrapper, `gitea-pr` |
| `fixed-domains.sh` | Shared domain list sourced by both `init-firewall.sh` and `dns-proxy.sh` |
| `dns-proxy.sh` | Starts the DNS-allowlisting `dnsmasq`, repoints `resolv.conf` at it |
| `init-firewall.sh` | IPv4/IPv6 egress allowlist firewall, run at container start |
| `ulogd.conf` | `ulogd2` config: turns `init-firewall.sh`'s NFLOG-tagged packets into JSON |
| `log-shipper.sh` | Tails the dnsmasq/ulogd2 logs and ships them to `$LOKI_URL` |
| `entrypoint.sh` | Runs as root: DNS proxy, firewall, logging, drops to `node` via `gosu`, execs `nvim` |
| `claude-wrapper.sh` | Shadows `claude` on `PATH` to always add `--dangerously-skip-permissions` |
| `docker-compose.yml` | Wires up mounts/env; invoked via `bin/claude-sandbox`, not directly |

`bin/claude-sandbox` (repo root `bin/`) is the entry point — it resolves the
project path, checks for a live `ssh-agent`, loads `GITEA_TOKEN`/`GH_TOKEN`
if not already set, and runs `docker compose run`. `bin/claude-sandbox-allow`
adds a domain to a running session's firewall from the host - see "Adding a
domain to a running session" above.
