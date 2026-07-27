#!/usr/bin/env bash
# Claude Code statusLine command: model, dir/branch, context usage, rate limits.
# See: https://code.claude.com/docs/en/statusline

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
WEEK=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Claude Code omits rate_limits when ANTHROPIC_BASE_URL isn't the literal
# api.anthropic.com host (e.g. the dejima sandbox's credential-injecting
# loopback proxy), even though the usage endpoint itself works fine through
# it. Fetch it ourselves in that case, cached briefly to avoid a network
# round-trip on every render.
if [ -z "$FIVE_H" ] && [ -n "${ANTHROPIC_BASE_URL:-}" ] && [ -n "${ANTHROPIC_AUTH_TOKEN:-}" ]; then
    CACHE="${TMPDIR:-/tmp}/claude-statusline-usage-${UID}.json"
    if [ ! -s "$CACHE" ] || [ -n "$(find "$CACHE" -mmin +1 2>/dev/null)" ]; then
        if curl -fsS --max-time 3 "$ANTHROPIC_BASE_URL/api/oauth/usage" \
                -H "Authorization: Bearer $ANTHROPIC_AUTH_TOKEN" \
                -H "anthropic-beta: oauth-2025-04-20" \
                -o "$CACHE.tmp" 2>/dev/null; then
            mv "$CACHE.tmp" "$CACHE"
        fi
    fi
    FIVE_H=$(jq -r '.five_hour.utilization // empty' "$CACHE" 2>/dev/null)
    WEEK=$(jq -r '.seven_day.utilization // empty' "$CACHE" 2>/dev/null)
fi

GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'

if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /▓}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /░}"

BRANCH=""
git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1 && BRANCH=" | 🌿 $(git -C "$DIR" branch --show-current 2>/dev/null)"

LIMITS=""
[ -n "$FIVE_H" ] && LIMITS="5h: $(printf '%.0f' "$FIVE_H")%"
[ -n "$WEEK" ] && LIMITS="${LIMITS:+$LIMITS }7d: $(printf '%.0f' "$WEEK")%"

echo -e "[$MODEL] 📁 ${DIR##*/}${BRANCH}"
if [ -n "$LIMITS" ]; then
    echo -e "${BAR_COLOR}${BAR}${RESET} ${PCT}% | ${LIMITS}"
else
    echo -e "${BAR_COLOR}${BAR}${RESET} ${PCT}%"
fi
