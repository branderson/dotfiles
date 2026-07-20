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
    # settings.json specifically comes from a generated $SANDBOX_SETTINGS_FILE
    # (see below), not the real file directly - it still has to be read-only
    # in the container, just from a different, sandbox-specific source.
    grep -qE '^\s*-\s*\$\{SANDBOX_SETTINGS_FILE.*\}:/home/node/\.claude/settings\.json:ro\s*$' "$SANDBOX_DIR/docker-compose.yml"
    grep -qE '^\s*-\s*\$\{HOME\}/\.claude/CLAUDE\.md:.*:ro\s*$' "$SANDBOX_DIR/docker-compose.yml"
    grep -qE '^\s*-\s*\$\{HOME\}/\.claude/plugins:.*:ro\s*$' "$SANDBOX_DIR/docker-compose.yml"
}

@test "gitconfig is a throwaway copy in its own directory, not a single-file mount" {
    # entrypoint.sh's `gh auth setup-git` writes a credential-helper entry
    # via git's write-temp-then-rename pattern, which fails with "Device or
    # resource busy" on a single-file bind mount at ~/.gitconfig directly -
    # a real regression this guards against (Linux won't let a bind mount's
    # backing inode be replaced, only a file *within* a mounted directory
    # can be freely renamed over). Must be a directory mount, with
    # GIT_CONFIG_GLOBAL pointing git at the file inside it.
    grep -qE '^\s*-\s*\$\{SANDBOX_GITCONFIG_DIR.*\}:/home/node/\.gitconfig-sandbox\s*$' "$SANDBOX_DIR/docker-compose.yml"
    grep -qE '^\s*GIT_CONFIG_GLOBAL:\s*/home/node/\.gitconfig-sandbox/\.gitconfig\s*$' "$SANDBOX_DIR/docker-compose.yml"
    grep -q 'mktemp -d.*gitconfig' "$REPO_ROOT/bin/claude-sandbox"
}

@test "bin/claude-sandbox forces sandbox.enabled to false in the generated settings.json" {
    # Claude Code's own internal per-command sandboxing is redundant on top
    # of this container and can't actually function inside it (bwrap can't
    # create a namespace here) - settings.json is read-only precisely so it
    # can't be patched from inside, so this has to happen in the generation
    # step on the host, before the container starts.
    grep -qE '\.sandbox\.enabled\s*=\s*false' "$REPO_ROOT/bin/claude-sandbox"
}

@test "Dockerfile never installs bubblewrap or socat" {
    # Nothing needs them now that sandbox.enabled is forced off - if they
    # come back, it's worth asking why before just re-adding them.
    run grep -E '^\s*(bubblewrap|socat)\s*\\?\s*$' "$SANDBOX_DIR/Dockerfile"
    [ "$status" -ne 0 ]
}

@test "sandbox-context.sh never tells the agent to worktree outside the mounted project" {
    # ../<branch> (a sibling of the mounted project) or anything under $HOME
    # lands in container-local ephemeral storage, not real host storage -
    # the worktree, and whatever work went into it, silently vanishes when
    # the session ends. Regression check for exactly this bug.
    run grep -E '(worktree add|git worktree)[^\\n]*\.\./' "$REPO_ROOT/config/claude/hooks/sandbox-context.sh"
    [ "$status" -ne 0 ]
    grep -q '.worktrees/' "$REPO_ROOT/config/claude/hooks/sandbox-context.sh"
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
