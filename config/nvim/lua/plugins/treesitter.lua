return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local parsers = {
      "javascript",
      "typescript",
      "tsx",
      "svelte",
      "html",
      "css",
      "scss",
      "json",
      "yaml",
      "python",
      "rust",
      "bash",
      "lua",
      "vim",
      "vimdoc",
      "query",
      "markdown",
      "markdown_inline",
      "regex",
    }

    -- Install parsers (skip if the tree-sitter CLI isn't available; parsers
    -- already cached from a previous run on this machine still work fine)
    if vim.fn.executable("tree-sitter") == 1 then
      require("nvim-treesitter").install(parsers)
    else
      vim.notify(
        "tree-sitter CLI not found: skipping install of missing parsers",
        vim.log.levels.WARN
      )
    end

    -- Enable treesitter highlighting, folding, and indentation for
    -- filetypes with an installed parser. Note some filetype names differ
    -- from their parser names (e.g. "bash" parser -> "sh" filetype).
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "javascript",
        "typescript",
        "typescriptreact",
        "javascriptreact",
        "svelte",
        "html",
        "css",
        "scss",
        "json",
        "yaml",
        "python",
        "rust",
        "sh",
        "lua",
        "vim",
        "help",
        "query",
        "markdown",
      },
      callback = function()
        -- Highlighting, provided by Neovim. Falls back to Vim's legacy
        -- syntax/indent if no parser is installed for this filetype.
        if not pcall(vim.treesitter.start) then
          return
        end
        -- Folding, provided by Neovim
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo.foldmethod = "expr"
        -- Indentation, provided by nvim-treesitter
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    -- General fold display settings (not treesitter-specific)
    vim.opt.foldlevel = 2
    vim.opt.foldlevelstart = 2
    vim.opt.foldcolumn = "5"
  end,
}
