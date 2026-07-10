# nvim config map

Lua config managed by [lazy.nvim](https://github.com/folke/lazy.nvim). Leader is `,`, local leader is `\`.

## Layout

- `init.lua` — bootstraps lazy.nvim, loads `config/` then `plugins/`
- `lua/config/options.lua` — `vim.opt` settings
- `lua/config/keymaps.lua` — keymaps not tied to a specific plugin
- `lua/config/autocmds.lua` — autocommands
- `lua/plugins/*.lua` — one lazy.nvim spec file per topic (each file returns a plugin spec table; lazy.nvim loads every file in the directory automatically)
- `ftplugin/*.lua` — filetype-specific settings (Python, vimwiki)
- `lua/util.lua` — small helper functions (`ranger()`, `delete_trailing_ws()`) used from keymaps

## Plugins

### Navigation & editing (`plugins/editor.lua`)

- **[neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)** — file explorer sidebar
  - `<leader>t` — toggle
  - `<leader>cd` — cd to current file's directory and open
- **[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)** — fuzzy finder for files/buffers/grep/LSP symbols
  - `<leader>.` — jump to symbol
  - `<leader>;` — jump to buffer
  - `<leader>be` — jump to buffer, sorted by most recently used
  - `<leader>ag` — live grep
- **[flash.nvim](https://github.com/folke/flash.nvim)** — jump to any visible location via search-like labels
  - `<leader>/` — jump
  - `<leader>s` — search jump
  - `<leader><leader>s` — treesitter jump
  - `<leader>f` — forward jump
- **[nvim-surround](https://github.com/kylechui/nvim-surround)** — add/change/delete surrounding pairs (quotes, tags, brackets)
  - `ys`, `cs`, `ds` — plugin defaults
- **[nvim-autopairs](https://github.com/windwp/nvim-autopairs)** — auto-close brackets/quotes, automatic
- **[nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context)** — sticky header showing enclosing function/class while scrolling, automatic
- **[mini.align](https://github.com/echasnovski/mini.nvim)** — align text on a character
  - `ga=`, `ga:`
- **[mini.bufremove](https://github.com/echasnovski/mini.nvim)** — close a buffer without closing its window/split
  - `<leader><leader>c`
- **[vim-visual-multi](https://github.com/mg979/vim-visual-multi)** — multiple cursors
  - `<C-n>` — add cursor on word
- **[vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)** — move between nvim splits and tmux panes; also works from inside `:terminal` buffers (e.g. the Claude Code terminal)
  - `<C-h/j/k/l>` — move left/down/up/right
- **[emmet-vim](https://github.com/mattn/emmet-vim)** — Emmet expansion, HTML/CSS files only

### UI (`plugins/ui.lua`)

- **[gruvbox.nvim](https://github.com/ellisonleao/gruvbox.nvim)** — colorscheme
- **[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)** — statusline
- **[bufferline.nvim](https://github.com/akinsho/bufferline.nvim)** — buffer tabs along the top
- **[indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)** — indent guides
- **[rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim)** — rainbow-colored matching brackets
- **[nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)** — filetype icons (dependency for several plugins above)
- **[alpha-nvim](https://github.com/goolord/alpha-nvim)** — start screen shown on launch, see [Dashboard](#dashboard) below
  - `<leader><leader>o` — reopen

### Completion & LSP

- **[blink.cmp](https://github.com/Saghen/blink.cmp)** — completion engine (LSP, path, buffer sources) — `plugins/completion.lua`
- **[mason.nvim](https://github.com/mason-org/mason.nvim)** / **[mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim)** — installs/manages LSP servers — `plugins/lsp.lua`
- **[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)** — LSP client config for `ts_ls`, `svelte`, `html`, `cssls`, `basedpyright`, `ruff`, `bashls` — `plugins/lsp.lua`
- **[rustaceanvim](https://github.com/mrcjkb/rustaceanvim)** — Rust LSP setup (`rust_analyzer`), replaces the standard lspconfig flow for Rust — `plugins/rust.lua`
  - `<localleader>rr` — cargo run

LSP buffer keymaps (set on `LspAttach`, see `plugins/lsp.lua`):

- `K` — hover
- `gd` — definition
- `gy` — type definition
- `gi` — implementation
- `gr` — references
- `rn` — rename
- `ff` (visual) — format selection

### Formatting & linting (`plugins/format.lua`)

- **[conform.nvim](https://github.com/stevearc/conform.nvim)** — format-on-save (prettier, ruff_format, rustfmt, stylua per filetype)
- **[nvim-lint](https://github.com/mfussenegger/nvim-lint)** — async linting on save/insert-leave (eslint_d, shellcheck)

### Treesitter (`plugins/treesitter.lua`)

**[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)** — syntax highlighting, folding, and indentation for the installed parser list. Uses core Neovim's built-in `vim.treesitter.start()`/foldexpr rather than the old treesitter modules.

### Git (`plugins/git.lua`)

- **[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)** — git change signs in the gutter, hunk stage/preview/blame
- **[vim-fugitive](https://github.com/tpope/vim-fugitive)** — Git commands
  - `:Git`, `:Gdiffsplit`, `:Gvdiffsplit`, `:Gread`, `:Gwrite`, `:Gclog`

### AI (`plugins/ai.lua`)

- **[snacks.nvim](https://github.com/folke/snacks.nvim)** — utility library (terminal provider etc.), dependency for claudecode.nvim
- **[claudecode.nvim](https://github.com/coder/claudecode.nvim)** — Claude Code terminal integration. Diffs render as a single unified (VS Code-style, red/green interleaved) buffer in one new split next to your active pane, and keyboard focus stays in the Claude terminal instead of jumping to the diff.
  - `<leader>ac` — toggle
  - `<leader>af` — focus
  - `<leader>ab` — add current buffer
  - `<leader>as` (visual) — send selection
  - `<leader>aa` / `<leader>ad` — accept/deny diff

### Wiki / notes (`plugins/vimwiki.lua`)

- **[vimwiki](https://github.com/vimwiki/vimwiki)** — personal wiki across 4 notebooks (bradwiki, work, private, shared under `~/synced-notebooks/`)
  - `<leader>m...` — wiki keymaps (`vim.g.vimwiki_map_prefix`)
- **[vim-zettel](https://github.com/michal-h21/vim-zettel)** — Zettelkasten-style note linking on top of vimwiki
- **[vim-table-mode](https://github.com/dhruvasagar/vim-table-mode)** — markdown/wiki table formatting
  - `:TableModeToggle`, or `<leader><leader>t...` prefix
- **[markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)** — live browser preview for markdown/vimwiki
  - `<localleader>v` — toggle preview

### Misc (`plugins/misc.lua`)

- **[aerial.nvim](https://github.com/stevearc/aerial.nvim)** — code outline/symbol sidebar
  - `<leader>ct` — toggle
- **[undotree](https://github.com/jiaoshijie/undotree)** — visual undo history tree
  - `<leader>u` — toggle
- **[persistence.nvim](https://github.com/folke/persistence.nvim)** — session save/restore per project
  - restore from the dashboard's `s` button
- **[which-key.nvim](https://github.com/folke/which-key.nvim)** — keybinding cheatsheet, built from every mapping's `desc`
  - `<leader>?` — browse all keybindings; press a key to drill into a group, `<bs>` to go back up, `<esc>` to close

## Dashboard

The start screen (shown on launch, reopen with `<leader><leader>o`) is [alpha-nvim](https://github.com/goolord/alpha-nvim), configured in `plugins/ui.lua`. It shows a random `fortune | cowthink` header plus buttons:

- `e` — new file
- `f` — find file (Telescope)
- `g` — live grep (Telescope)
- `s` — restore last session (persistence.nvim)
- `q` — quit

## Buffer navigation

`<leader>be` fuzzy-searches open buffers via Telescope, sorted by most recently used, excluding the current buffer. `<leader>;` does the same but in default Telescope order. Both are fuzzy-filterable as you type.
