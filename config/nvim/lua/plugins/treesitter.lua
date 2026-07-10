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

    -- Install parsers
    require("nvim-treesitter").install(parsers)

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
        -- Highlighting, provided by Neovim
        vim.treesitter.start()
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
