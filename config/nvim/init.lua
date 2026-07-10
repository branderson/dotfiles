-- Version guard: native LSP config (vim.lsp.config/vim.lsp.enable, added in
-- 0.11) and the pinned nvim-treesitter (hard-requires 0.12 in its own health
-- check) both need a current Neovim. Older versions -- e.g. Debian's apt
-- package, which lags upstream by a long way even fully updated -- don't
-- fail here; they fail later with a confusing cascade of lspconfig and
-- mason-lspconfig errors. Check up front instead, before anything else in
-- this file runs (some of it, like vim.uv below, doesn't exist pre-0.10).
if vim.fn.has("nvim-0.12") == 0 then
  local ok, v = pcall(vim.version)
  local current = ok and string.format("%d.%d.%d", v.major, v.minor, v.patch) or "an older version"

  -- vim.loop (not vim.uv -- that alias doesn't exist pre-0.10) to detect the
  -- machine's arch, since Neovim ships separate release assets per arch and
  -- the install command below needs to name the right one.
  local machine = (vim.loop.os_uname() or {}).machine or ""
  local asset_arch = ({ x86_64 = "x86_64", amd64 = "x86_64", aarch64 = "arm64", arm64 = "arm64" })[machine]

  if not asset_arch then
    vim.api.nvim_echo({
      {
        "This config requires Neovim 0.12.0 or newer (found "
          .. current
          .. "). No prebuilt Neovim release is published for this machine's architecture ("
          .. (machine ~= "" and machine or "unknown")
          .. "); check https://github.com/neovim/neovim/releases/latest for a build, or install from source.\n",
        "ErrorMsg",
      },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end

  local asset = "nvim-linux-" .. asset_arch
  vim.api.nvim_echo({
    { "This config requires Neovim 0.12.0 or newer (found " .. current .. ", " .. machine .. ").\n\n", "ErrorMsg" },
    { "Install a current build -- locally, no root needed:\n", "None" },
    { "  curl -LO https://github.com/neovim/neovim/releases/latest/download/" .. asset .. ".tar.gz\n", "None" },
    { "  tar xzf " .. asset .. ".tar.gz\n", "None" },
    { "  rm -rf ~/.local/nvim && mv " .. asset .. " ~/.local/nvim\n", "None" },
    { "  mkdir -p ~/.local/bin && ln -sf ~/.local/nvim/bin/nvim ~/.local/bin/nvim\n", "None" },
    { "  rm " .. asset .. ".tar.gz\n", "None" },
    { "  # then make sure ~/.local/bin is on your PATH\n\n", "Comment" },
    { "Or system-wide (needs root):\n", "None" },
    { "  curl -LO https://github.com/neovim/neovim/releases/latest/download/" .. asset .. ".tar.gz\n", "None" },
    { "  tar xzf " .. asset .. ".tar.gz\n", "None" },
    { "  sudo rm -rf /opt/nvim && sudo mv " .. asset .. " /opt/nvim\n", "None" },
    { "  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim\n", "None" },
    { "  rm " .. asset .. ".tar.gz\n", "None" },
  }, true, {})
  vim.fn.getchar()
  os.exit(1)
end

-- Leader keys MUST be set before lazy.setup() so lazy-loaded `keys = {...}`
-- specs resolve <leader> correctly when they register their keymaps.
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("config.options")
require("config.keymaps")
require("config.autocmds")

require("lazy").setup("plugins", {
  change_detection = { notify = false },
})
