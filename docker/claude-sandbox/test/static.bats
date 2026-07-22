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

@test "Dockerfile creates a SANDBOX_USER matching the host user, not a hardcoded node" {
    grep -qE '^ARG SANDBOX_USER=node\s*$' "$SANDBOX_DIR/Dockerfile"
    grep -qE '^ARG SANDBOX_UID=1000\s*$' "$SANDBOX_DIR/Dockerfile"
    grep -qE '^ARG SANDBOX_GID=1000\s*$' "$SANDBOX_DIR/Dockerfile"
    grep -qE '^ARG SANDBOX_HOME=/home/node\s*$' "$SANDBOX_DIR/Dockerfile"
    grep -q 'useradd -u "$SANDBOX_UID" -g "$SANDBOX_GID" -m -d "$SANDBOX_HOME"' "$SANDBOX_DIR/Dockerfile"
    grep -qE '^ENV SANDBOX_USER=\$SANDBOX_USER\s*$' "$SANDBOX_DIR/Dockerfile"
    grep -qE '^ENV SANDBOX_HOME=\$SANDBOX_HOME\s*$' "$SANDBOX_DIR/Dockerfile"
    # No literal "USER node" anywhere - the mid-build USER switch must use
    # the parametrized variable, not the old hardcoded name.
    run grep -E '^USER\s+node\s*$' "$SANDBOX_DIR/Dockerfile"
    [ "$status" -ne 0 ]
    grep -qE '^USER\s+\$SANDBOX_USER\s*$' "$SANDBOX_DIR/Dockerfile"
}

@test "entrypoint.sh drops privilege via SANDBOX_USER, not a literal node" {
    run grep -E 'gosu node\b' "$SANDBOX_DIR/entrypoint.sh"
    [ "$status" -ne 0 ]
    grep -q 'gosu "$SANDBOX_USER"' "$SANDBOX_DIR/entrypoint.sh"
}

@test "Playwright is installed and require()-able globally" {
    # A global npm install only puts the CLI on PATH, not the module on
    # Node's require() resolution path - NODE_PATH is what makes
    # require("playwright") work from any script, not just one with its own
    # local node_modules (see runtime.bats for the actual launch test).
    grep -q 'npm install -g playwright' "$SANDBOX_DIR/Dockerfile"
    grep -qE '^\s*ENV\s+NODE_PATH=' "$SANDBOX_DIR/Dockerfile"
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
    # Anchored to the *source* side of a mount (right after the leading
    # "- ") - the container's own $HOME legitimately contains .ssh/known_hosts
    # as a *destination* path now that it mirrors the host's $HOME, which
    # isn't the same thing as mounting the host's real ~/.ssh directory in.
    run grep -E '^\s*-\s*\$\{HOME\}/\.(ssh|aws|gcloud|azure)(/|:)' "$SANDBOX_DIR/docker-compose.yml"
    [ "$status" -ne 0 ]
}

@test "~/.claude settings/CLAUDE.md/plugins are layered read-only over the read-write parent mount" {
    grep -qE '^\s*-\s*\$\{HOME\}/\.claude:\$\{HOME\}/\.claude\s*$' "$SANDBOX_DIR/docker-compose.yml"
    # settings.json specifically comes from a generated $SANDBOX_SETTINGS_FILE
    # (see below), not the real file directly - it still has to be read-only
    # in the container, just from a different, sandbox-specific source.
    grep -qE '^\s*-\s*\$\{SANDBOX_SETTINGS_FILE.*\}:\$\{HOME\}/\.claude/settings\.json:ro\s*$' "$SANDBOX_DIR/docker-compose.yml"
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
    grep -qE '^\s*-\s*\$\{SANDBOX_GITCONFIG_DIR.*\}:\$\{HOME\}/\.gitconfig-sandbox\s*$' "$SANDBOX_DIR/docker-compose.yml"
    grep -qE '^\s*GIT_CONFIG_GLOBAL:\s*\$\{HOME\}/\.gitconfig-sandbox/\.gitconfig\s*$' "$SANDBOX_DIR/docker-compose.yml"
    grep -q 'mktemp -d.*gitconfig' "$REPO_ROOT/bin/claude-sandbox"
}

@test "docker-compose.yml never hardcodes /home/node - the container home is host-parametrized" {
    # ${HOME:-/home/node} (the SANDBOX_HOME build arg's own default value,
    # mirroring the Dockerfile's default) is the one legitimate exception -
    # it's a fallback expression, not a hardcoded container path.
    run bash -c "grep -v '^\s*#' '$SANDBOX_DIR/docker-compose.yml' | grep -v '\${HOME:-/home/node}' | grep '/home/node'"
    [ "$status" -ne 0 ]
}

@test "docker-compose.yml builds with a per-user image tag and passes the host identity as build args" {
    grep -qE '^\s*image:\s*claude-sandbox:\$\{SANDBOX_USER:-node\}\s*$' "$SANDBOX_DIR/docker-compose.yml"
    grep -qE '^\s*SANDBOX_USER:\s*\$\{SANDBOX_USER:-node\}\s*$' "$SANDBOX_DIR/docker-compose.yml"
    grep -qE '^\s*SANDBOX_UID:\s*\$\{SANDBOX_UID:-1000\}\s*$' "$SANDBOX_DIR/docker-compose.yml"
    grep -qE '^\s*SANDBOX_GID:\s*\$\{SANDBOX_GID:-1000\}\s*$' "$SANDBOX_DIR/docker-compose.yml"
    grep -qE '^\s*SANDBOX_HOME:\s*\$\{HOME:-/home/node\}\s*$' "$SANDBOX_DIR/docker-compose.yml"
}

@test "bin/claude-sandbox exports the host user identity for the build" {
    grep -q 'SANDBOX_USER="$(id -un)"' "$REPO_ROOT/bin/claude-sandbox"
    grep -q 'SANDBOX_UID="$(id -u)"' "$REPO_ROOT/bin/claude-sandbox"
    grep -q 'SANDBOX_GID="$(id -g)"' "$REPO_ROOT/bin/claude-sandbox"
}

@test "dotfiles is mounted once now that the container home matches the host home" {
    count=$(grep -c '\${HOME}/dotfiles:' "$SANDBOX_DIR/docker-compose.yml")
    [ "$count" -eq 1 ]
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

@test "the dedicated SSH key mount is optional, not a hard requirement" {
    grep -qE '^\s*-\s*\$\{SANDBOX_SSH_KEY_FILE:-/dev/null\}:\$\{HOME\}/\.ssh-sandbox-key-src:ro\s*$' "$SANDBOX_DIR/docker-compose.yml"
    grep -qE '^\s*-\s*\$\{SSH_AUTH_SOCK:-/dev/null\}:/ssh-agent\s*$' "$SANDBOX_DIR/docker-compose.yml"
}

@test "entrypoint.sh deletes the plaintext dedicated-key copy after loading it into the agent" {
    grep -q 'gosu "$SANDBOX_USER" ssh-add' "$SANDBOX_DIR/entrypoint.sh"
    grep -q 'rm -f "$SANDBOX_HOME/.ssh/sandbox-key"' "$SANDBOX_DIR/entrypoint.sh"
    ssh_add_line=$(grep -n 'gosu "$SANDBOX_USER" ssh-add' "$SANDBOX_DIR/entrypoint.sh" | head -1 | cut -d: -f1)
    rm_line=$(grep -n 'rm -f "$SANDBOX_HOME/.ssh/sandbox-key"' "$SANDBOX_DIR/entrypoint.sh" | head -1 | cut -d: -f1)
    [ "$rm_line" -gt "$ssh_add_line" ]
}

@test "bin/claude-sandbox allows a dedicated SANDBOX_SSH_KEY in place of a forwarded agent" {
    grep -q 'SANDBOX_SSH_KEY' "$REPO_ROOT/bin/claude-sandbox"
    grep -q 'export SANDBOX_SSH_KEY_FILE' "$REPO_ROOT/bin/claude-sandbox"
}
