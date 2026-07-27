local opt = vim.opt

-- Completion / buffers
opt.omnifunc = "syntaxcomplete#Complete"
opt.hidden = true
opt.autoread = true

-- No swap/backup files
opt.swapfile = false
opt.backup = false

opt.number = true

-- matchit is built into Neovim's runtime already; no `runtime macros/matchit.vim` needed

opt.encoding = "utf-8"
opt.lazyredraw = true
opt.backspace = { "indent", "eol", "start" }
opt.history = 700
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.scrolloff = 15

opt.wildmode = { "longest", "list", "full" }
opt.wildmenu = true
opt.wildcharm = vim.api.nvim_replace_termcodes("<C-Z>", true, true, true):byte()

opt.mouse = "a"

-- Tabs
opt.tabstop = 4
opt.softtabstop = 4
opt.expandtab = true
opt.shiftwidth = 4

opt.wrap = true
opt.linebreak = true
opt.list = false

opt.ruler = true
opt.showmatch = true

opt.viewoptions:remove("options")

opt.shortmess:append("I")

opt.laststatus = 2
opt.showmode = false

opt.termguicolors = true
vim.g.enable_bold_font = 1

-- Have vrm extend background color to full terminal screen
vim.cmd("set t_ut=")

opt.splitbelow = true
opt.splitright = true

opt.updatetime = 300
opt.shortmess:append("c")

-- Clipboard: copy-only, via dotfiles/bin/clipboard-copy. This is a small
-- script (rather than nvim's built-in raw-OSC-52-only provider) because
-- reaching the real clipboard needs more than a raw OSC 52 write: it picks
-- pbcopy/xclip/wl-copy when nvim is running locally, and when none of those
-- are available (nvim on a remote host with no local display) sends a
-- single plain OSC 52 write. Any tmux hops between here and the real
-- terminal relay that onward themselves via the pane-set-clipboard hook in
-- tmux.conf, so this works whether nvim is local or several ssh/tmux hops
-- deep, on any machine sharing this dotfiles repo, without needing to know
-- how many hops there are. Paste is intentionally left as a no-op: OSC 52
-- read support is inconsistent across terminals and can hang waiting for a
-- reply, so use the terminal's own native paste (e.g. Ctrl-Shift-V)
-- instead. Guarded on executable() rather than assumed present - not every
-- machine this config runs on has the rest of dotfiles checked out too
-- (e.g. dejima mounts in only this nvim config directory), and
-- without the guard vim.g.clipboard would point at a script that isn't
-- there, erroring on every yank instead of just falling back to nvim's
-- default clipboard handling.
local clipboard_copy = vim.fn.expand("~/dotfiles/bin/clipboard-copy")
if vim.fn.executable(clipboard_copy) == 1 then
  vim.g.clipboard = {
    name = "clipboard-copy (copy-only)",
    copy = {
      ["+"] = { clipboard_copy },
      ["*"] = { clipboard_copy },
    },
    paste = {
      ["+"] = function() return {} end,
      ["*"] = function() return {} end,
    },
  }
end
