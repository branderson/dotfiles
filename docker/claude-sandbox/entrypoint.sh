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
    sudo EXTRA_ALLOWED_DOMAINS="${extra_domains}" /usr/local/bin/init-firewall.sh
fi

exec nvim "$@"
