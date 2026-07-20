#!/bin/bash
# Tails dns-proxy.sh's dnsmasq query log and ulogd2's NFLOG-derived JSON
# output, shipping each line to Loki as a raw log stream. Lets DNS lookups
# and firewall allow/reject decisions from inside the sandbox show up
# alongside the rest of the Grafana/Loki setup, labeled by job so they're
# easy to filter. No-op if LOKI_URL isn't set - logging is a bonus on top of
# the firewall/DNS-proxy enforcement, not required for either to work.
set -uo pipefail  # not -e: one bad line or a Loki hiccup shouldn't kill the tailer

LOKI_URL="${LOKI_URL:-}"
if [ -z "$LOKI_URL" ]; then
    exit 0
fi

push() {
    local job="$1" line="$2"
    local ts payload
    ts=$(date +%s%N)
    payload=$(jq -n --arg job "$job" --arg ts "$ts" --arg line "$line" \
        '{streams: [{stream: {job: $job, source: "claude-sandbox"}, values: [[$ts, $line]]}]}')
    curl -s -o /dev/null --max-time 3 -H "Content-Type: application/json" \
        -XPOST "$LOKI_URL/loki/api/v1/push" -d "$payload" || true
}

tail -F -n0 /var/log/dnsmasq.log 2>/dev/null | while IFS= read -r line; do
    push "claude-sandbox-dns" "$line"
done &

tail -F -n0 /var/log/ulogd.json 2>/dev/null | while IFS= read -r line; do
    push "claude-sandbox-net" "$line"
done &

wait
