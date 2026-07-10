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
