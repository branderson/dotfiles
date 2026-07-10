vim.g.vimwiki_list = {
  {
    path = "~/synced-notebooks/bradwiki/",
    syntax = "markdown",
    ext = ".md",
    diary_rel_path = "daily_notes/",
    diary_index = "index",
    diary_header = "Daily Notes",
    auto_tags = 1,
    auto_diary_index = 1,
    auto_generate_links = 1,
    auto_generate_tags = 1,
  },
  {
    path = "~/synced-notebooks/work_notebook/",
    syntax = "markdown",
    ext = ".md",
    diary_rel_path = "daily_notes/",
    diary_index = "index",
    diary_header = "Daily Notes",
    auto_tags = 1,
    auto_diary_index = 1,
    auto_generate_links = 1,
    auto_generate_tags = 1,
  },
  { path = "~/synced-notebooks/privatewiki/", syntax = "markdown", ext = ".md" },
  { path = "~/synced-notebooks/sharedwiki/", syntax = "markdown", ext = ".md" },
}
vim.g.vimwiki_map_prefix = "<Leader>m"
vim.g.vimwiki_folding = "list"
vim.g.markdown_folding = 1

vim.g.zettel_options = {
  {},
  {
    front_matter = { { "tags", "" }, { "type", "note" } },
    template = "~/work_notebook/templates/daily_note.tpl",
  },
}

vim.g.table_mode_map_prefix = "<Leader><Leader>t"

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("VimwikiFiletype", { clear = true }),
  pattern = "vimwiki",
  callback = function()
    vim.opt_local.breakindent = true
    vim.opt_local.breakindentopt = "shift:2"
  end,
})

return {
  { "vimwiki/vimwiki", lazy = false },
  { "michal-h21/vim-zettel", dependencies = { "vimwiki/vimwiki" }, lazy = false },
  { "dhruvasagar/vim-table-mode", cmd = "TableModeToggle" },
  {
    "iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end,
    ft = { "markdown", "vimwiki" },
    keys = {
      { "<localleader>v", "<Plug>MarkdownPreviewToggle", ft = { "markdown", "vimwiki" }, desc = "Toggle markdown preview" },
    },
  },
}
