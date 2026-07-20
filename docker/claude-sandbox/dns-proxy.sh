#!/bin/bash
# Restricts DNS resolution itself to an allowlist, rather than only
# filtering the IP connections made afterward: without this, Docker's
# embedded resolver at 127.0.0.11 will still resolve *any* domain even once
# the firewall is locked down (verified: `dig` on a non-allowlisted domain
# resolves fine, only the subsequent connect gets blocked), so a compromised
# session could exfiltrate data by encoding it into query names to an
# attacker-controlled domain. Runs a local dnsmasq bound to 127.0.0.1 with
# no fallback resolver, forwarding only allowlisted names to Docker's real
# resolver; everything else gets no upstream configured at all, so it fails
# outright instead of leaking the query. Must run before init-firewall.sh so
# that script's own dig calls (and everything afterward) go through it.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=fixed-domains.sh
source "$SCRIPT_DIR/fixed-domains.sh"

CONF_FILE=/etc/dnsmasq-sandbox.conf
SERVERS_FILE=/etc/dnsmasq-sandbox-servers.conf
LOG_FILE=/var/log/dnsmasq.log

touch "$LOG_FILE"
chown dnsmasq:dnsmasq "$LOG_FILE" 2>/dev/null || true

# server=/domain/upstream lines live in their own file (rather than the main
# conf) since dnsmasq only re-reads a --servers-file on SIGHUP - lets
# bin/claude-sandbox-allow add a domain to a running session by appending a
# line here and signaling the container's dnsmasq, no restart needed.
{
    for domain in "${FIXED_DOMAINS[@]}" "${GITHUB_DNS_SUFFIXES[@]}" ${EXTRA_ALLOWED_DOMAINS:-}; do
        # Literal IPs (e.g. a monitoring host given as an IP, not a hostname)
        # don't need a DNS entry - there's nothing to resolve.
        if [[ "$domain" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            continue
        fi
        echo "server=/$domain/127.0.0.11"
    done
} > "$SERVERS_FILE"

cat > "$CONF_FILE" <<EOF
no-resolv
no-hosts
bind-interfaces
# IPv6 is blocked outright at the firewall (see init-firewall.sh's
# ip6tables policies) - strip AAAA answers too so nothing wastes a
# connection attempt on an address that can never actually be reached.
filter-AAAA
listen-address=127.0.0.1
port=53
servers-file=$SERVERS_FILE
log-queries
log-facility=$LOG_FILE
user=dnsmasq
pid-file=/var/run/dnsmasq-sandbox.pid
EOF

dnsmasq --conf-file="$CONF_FILE"

# dnsmasq daemonizes and returns almost immediately, but give it a moment to
# actually be answering before repointing resolv.conf at it.
ready=0
for _ in $(seq 1 20); do
    if dig +time=1 +tries=1 @127.0.0.1 api.anthropic.com >/dev/null 2>&1; then
        ready=1
        break
    fi
    sleep 0.2
done
if [ "$ready" -ne 1 ]; then
    echo "ERROR: dnsmasq did not come up in time" >&2
    exit 1
fi

echo "nameserver 127.0.0.1" > /etc/resolv.conf
