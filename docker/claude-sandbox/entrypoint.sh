#!/bin/bash
set -euo pipefail

# Derive the Gitea API hostname from GITEA_API (a full URL) so it can be
# firewall-allowlisted alongside GITEA_SSH_HOST.
gitea_api_host=""
if [ -n "${GITEA_API:-}" ]; then
    gitea_api_host=$(echo "$GITEA_API" | sed -E 's#^[a-zA-Z]+://([^/]+).*#\1#')
fi

# Same for LOKI_URL (also a full URL) - Loki's host needs to be reachable
# for log-shipper.sh to actually deliver anything.
loki_host=""
if [ -n "${LOKI_URL:-}" ]; then
    loki_host=$(echo "$LOKI_URL" | sed -E 's#^[a-zA-Z]+://##; s#[:/].*##')
fi

extra_domains="${GITEA_SSH_HOST:-} ${gitea_api_host} ${loki_host} ${ALLOWED_DOMAINS:-}"

if [ "${ENABLE_FIREWALL:-1}" = "1" ]; then
    # dns-proxy.sh must run first: it repoints /etc/resolv.conf at a local
    # dnsmasq that only resolves allowlisted names, so init-firewall.sh's own
    # dig calls (and everything afterward) go through the same restriction.
    EXTRA_ALLOWED_DOMAINS="${extra_domains}" /usr/local/bin/dns-proxy.sh
    EXTRA_ALLOWED_DOMAINS="${extra_domains}" /usr/local/bin/init-firewall.sh

    # NFLOG groups only exist once init-firewall.sh has run, so ulogd2 (the
    # NFLOG consumer) and the Loki shipper start after it. Both are
    # best-effort visibility on top of the enforcement above, not required
    # for it - log-shipper.sh itself no-ops if LOKI_URL isn't set.
    /usr/sbin/ulogd -d -c /etc/ulogd-sandbox.conf
    /usr/local/bin/log-shipper.sh &
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
