# Based on the official Anthropic reference dev container:
# https://github.com/anthropics/claude-code/tree/main/.devcontainer
FROM node:22

ARG TZ
ENV TZ="$TZ"

ARG CLAUDE_CODE_VERSION=latest

# Install basic development tools, iptables/ipset (for the egress firewall),
# openssh-client (for git-over-ssh and agent forwarding), and the toolchain
# nvim's plugin config (config/nvim, telescope/treesitter/mason) expects.
RUN apt-get update && apt-get install -y --no-install-recommends \
  less \
  git \
  openssh-client \
  procps \
  sudo \
  fzf \
  zsh \
  man-db \
  unzip \
  gnupg2 \
  gh \
  iptables \
  ipset \
  iproute2 \
  dnsutils \
  aggregate \
  jq \
  nano \
  vim \
  ripgrep \
  fd-find \
  build-essential \
  python3 \
  python3-pip \
  python3-venv \
  xz-utils \
  && apt-get clean && rm -rf /var/lib/apt/lists/* \
  && ln -s "$(command -v fdfind)" /usr/local/bin/fd

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

ARG USERNAME=node

# Persist bash history.
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Disable non-essential network traffic (telemetry/error reporting) so the
# firewall allowlist can stay small.
ENV CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# Lets Claude Code (and the SessionStart hook in ~/.claude/hooks) know it's
# running inside this container rather than directly on the host.
ENV CLAUDE_SANDBOX=1

# Create the ssh directory and set permissions. The project directory itself
# is bind-mounted at runtime at its real host path (see docker-compose.yml),
# not a fixed /workspace, so it can share ~/.claude project/session history
# with the host. ~/.claude is bind-mounted too, not baked in here.
RUN mkdir -p /home/node/.ssh && \
  chown -R node:node /home/node/.ssh && \
  chmod 700 /home/node/.ssh

# Pre-create the nvim data/state/cache dirs owned by node, since they're
# mounted as named volumes in docker-compose.yml: Docker seeds a fresh
# named volume from whatever already exists at the mount path in the
# image, ownership included, so this is what keeps those volumes
# node-writable instead of defaulting to root.
RUN mkdir -p /home/node/.local/share/nvim /home/node/.local/state/nvim /home/node/.cache/nvim && \
  chown -R node:node /home/node/.local /home/node/.cache

ARG GIT_DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  sudo dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

# Install the latest stable Neovim release. Debian's packaged version is too
# old for this config's plugins (blink.cmp etc. need a recent Neovim), so
# fetch the current release from GitHub directly rather than pinning a
# version that may go stale.
RUN asset_url=$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest \
    | jq -r '[.assets[] | select(.name | test("linux.*x86_64.*\\.tar\\.gz$"))][0].browser_download_url') && \
  wget -O nvim.tar.gz "$asset_url" && \
  tar -C /usr/local --strip-components=1 -xzf nvim.tar.gz && \
  rm nvim.tar.gz

# Set up non-root user
USER node

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Set the default shell to zsh rather than sh
ENV SHELL=/bin/zsh

# Set the default editor and visual
ENV EDITOR=nano
ENV VISUAL=nano

# Default powerline10k theme
ARG ZSH_IN_DOCKER_VERSION=1.2.0
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Copy and set up firewall + entrypoint scripts, the gitea-pr helper from
# this repo's bin/ directory, the claude wrapper that pins
# --dangerously-skip-permissions, and this user's real nvim config.
COPY docker/claude-sandbox/init-firewall.sh /usr/local/bin/
COPY docker/claude-sandbox/entrypoint.sh /usr/local/bin/
COPY docker/claude-sandbox/claude-wrapper.sh /usr/local/bin/claude
COPY bin/gitea-pr /usr/local/bin/gitea-pr
COPY config/nvim /home/node/.config/nvim

USER root
RUN chmod +x /usr/local/bin/init-firewall.sh /usr/local/bin/entrypoint.sh /usr/local/bin/gitea-pr /usr/local/bin/claude && \
  chown -R node:node /home/node/.config/nvim && \
  echo "node ALL=(root) NOPASSWD:SETENV: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/node-firewall && \
  chmod 0440 /etc/sudoers.d/node-firewall
USER node

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
