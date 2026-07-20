#!/usr/bin/env bats
# Fast checks that don't need Docker: catch regressions in the security
# invariants that are visible directly in the repo's files, without paying
# for an image build + container boot. See runtime.bats for everything that
# actually needs a live container.

setup() {
    SANDBOX_DIR="$BATS_TEST_DIRNAME/.."
    REPO_ROOT="$BATS_TEST_DIRNAME/../../.."
}

@test "Dockerfile never installs sudo" {
    run grep -E '^\s*sudo\s*\\?\s*$' "$SANDBOX_DIR/Dockerfile"
    [ "$status" -ne 0 ]
}

@test "Dockerfile never creates a sudoers entry" {
    run grep -i "sudoers" "$SANDBOX_DIR/Dockerfile"
    [ "$status" -ne 0 ]
}

@test "every ipset add in init-firewall.sh is duplicate-safe" {
    # Same bug class that broke firewall startup twice (718f6b7, a86fefc):
    # ipset add without -exist errors on a duplicate entry, and set -e turns
    # that into the whole firewall - and thus the whole container - failing
    # to start with no clear error surfaced to the user. Every "ipset add"
    # line must either pass -exist or already be wrapped so a failure can't
    # propagate (e.g. `|| true`).
    while IFS= read -r line; do
        case "$line" in
            *-exist*) continue ;;
            *"|| true"*) continue ;;
        esac
        echo "unsafe ipset add: $line"
        return 1
    done < <(grep "ipset add" "$SANDBOX_DIR/init-firewall.sh")
}

@test "docker-compose.yml never mounts the Docker socket" {
    run grep -i "docker.sock" "$SANDBOX_DIR/docker-compose.yml"
    [ "$status" -ne 0 ]
}

@test "docker-compose.yml never mounts host SSH/cloud credential directories" {
    run grep -E '\$\{HOME\}/\.(ssh|aws|gcloud|azure)(/|:)' "$SANDBOX_DIR/docker-compose.yml"
    [ "$status" -ne 0 ]
}

@test "~/.claude settings/CLAUDE.md/plugins are layered read-only over the read-write parent mount" {
    grep -qE '^\s*-\s*\$\{HOME\}/\.claude:/home/node/\.claude\s*$' "$SANDBOX_DIR/docker-compose.yml"
    grep -qE '^\s*-\s*\$\{HOME\}/\.claude/settings\.json:.*:ro\s*$' "$SANDBOX_DIR/docker-compose.yml"
    grep -qE '^\s*-\s*\$\{HOME\}/\.claude/CLAUDE\.md:.*:ro\s*$' "$SANDBOX_DIR/docker-compose.yml"
    grep -qE '^\s*-\s*\$\{HOME\}/\.claude/plugins:.*:ro\s*$' "$SANDBOX_DIR/docker-compose.yml"
}

@test "entrypoint runs as root and drops to node via gosu, not a baked-in USER node" {
    # The whole privilege-drop model depends on entrypoint.sh itself starting
    # as root (to set up the firewall) - a stray `USER node` before
    # ENTRYPOINT would silently break that.
    run tail -n 5 "$SANDBOX_DIR/Dockerfile"
    [[ "$output" == *"ENTRYPOINT"* ]]
    ! grep -qE '^\s*USER\s+node\s*$' <(tail -n 8 "$SANDBOX_DIR/Dockerfile")
}

@test "bin/claude-sandbox-allow rejects a domain with shell metacharacters" {
    run "$REPO_ROOT/bin/claude-sandbox-allow" 'evil.com;touch /tmp/pwned'
    [ "$status" -ne 0 ]
    [[ "$output" == *"Not a valid domain"* ]]
}

@test "bin/claude-sandbox-allow rejects a domain with a slash (dnsmasq server= delimiter)" {
    run "$REPO_ROOT/bin/claude-sandbox-allow" 'evil.com/../etc'
    [ "$status" -ne 0 ]
    [[ "$output" == *"Not a valid domain"* ]]
}

@test "bin/claude-sandbox-allow accepts a well-formed domain (passes validation)" {
    # --container points at a name that can't exist, so this can *never*
    # reach a real running claude-sandbox session (and mutate its live
    # firewall) even if the machine running this test happens to have one -
    # it must fail at "container not found", not at validation.
    run "$REPO_ROOT/bin/claude-sandbox-allow" 'crates.io' --container claude-sandbox-test-suite-nonexistent-target
    [ "$status" -ne 0 ]
    [[ "$output" != *"Not a valid domain"* ]]
}
