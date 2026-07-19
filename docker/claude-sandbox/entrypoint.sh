#!/bin/bash
set -euo pipefail

# Derive the Gitea API hostname from GITEA_API (a full URL) so it can be
# firewall-allowlisted alongside GITEA_SSH_HOST.
gitea_api_host=""
if [ -n "${GITEA_API:-}" ]; then
    gitea_api_host=$(echo "$GITEA_API" | sed -E 's#^[a-zA-Z]+://([^/]+).*#\1#')
fi

extra_domains="${GITEA_SSH_HOST:-} ${gitea_api_host} ${ALLOWED_DOMAINS:-}"

if [ "${ENABLE_FIREWALL:-1}" = "1" ]; then
    EXTRA_ALLOWED_DOMAINS="${extra_domains}" /usr/local/bin/init-firewall.sh
fi

# A normal login/ssh session always chowns the allocated pty to the logging
# in user; this container's entrypoint skips that (there's no login/sshd
# involved), leaving the tty root-owned. nvim's clipboard fallback needs to
# write to it directly as node, so fix the ownership up here, before
# dropping privileges.
if [ -t 1 ]; then
    chown node "$(tty)" 2>/dev/null || true
fi

# Point git's github.com credential helper at `gh`, which reads GH_TOKEN -
# only possible now, not at image build time, since that's a runtime
# secret. Combined with the firewall restricting github.com to port 443
# only, this is what makes GitHub read-only from inside the sandbox: no
# write-capable credential for it, and SSH (which could use the forwarded
# agent's real key) can't reach it at all. Skipped if GH_TOKEN isn't set -
# github.com HTTPS still works anonymously for public repos either way.
if [ -n "${GH_TOKEN:-}" ]; then
    gosu node gh auth setup-git
fi

# Drop root -> node for the actual session; node has no sudo/setuid path
# back to root after this, so it can't re-run init-firewall.sh itself to
# widen the allowlist mid-session.
exec gosu node nvim "$@"
