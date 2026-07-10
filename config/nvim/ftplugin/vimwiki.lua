local map = function(mode, lhs, rhs)
  vim.keymap.set(mode, lhs, rhs, { buffer = true })
end

map("n", "<leader>mm", "<Plug>VimwikiIndex")
map("n", "<leader>mw", "<Plug>VimwikiUISelect")
map("n", "<leader>mhelp", ":verbose map ,m<CR>")
map("n", "<leader>mg", "<Plug>VimwikiGoto")
map("n", "<leader>mf", "<Plug>VimwikiUISelect1<CR>")
map("n", "<leader>m<Space>", "<Plug>VimwikiUISelect2<CR>")
map("n", "<leader>mp", "<Plug>VimwikiUISelect3<CR>")
map("n", "<leader>ms", "<Plug>VimwikiUISelect4<CR>")

map("n", "<leader>m-", "<Plug>VimwikiSplitLink")
map("n", "<leader>m<Bar>", "<Plug>VimwikiVSplitLink")

map("n", "<leader>mnt", "<Plug>VimwikiNextTask")
map("n", "<leader>mnl", "<Plug>VimwikiNextLink")
map("n", "<leader>mNl", "<Plug>VimwikiPrevLink")

map({ "n", "i", "v" }, "<Tab>", "<Plug>VimwikiIncreaseLvlSingleItem")
map({ "n", "i", "v" }, "<S-Tab>", "<Plug>VimwikiDecreaseLvlSingleItem")

map("i", "<C-Space>", "<Esc><Plug>VimwikiToggleListItemA")
map("n", "<C-d><C-Space>", "<Plug>VimwikiRemoveSingleCB")
map("i", "<C-d><C-Space>", "<Esc><Plug>VimwikiRemoveSingleCBa")
map("n", "<leader>mb", "<Plug>VimwikiBackLinks")
map("n", "<leader>mqtoc", "<Plug>VimwikiTOC")
map("n", "<leader>mqgtl", "<Plug>VimwikiRebuildTags<CR><Plug>VimwikiGenerateTagLinks<CR>")

map("v", "<leader>mk", 'c[]<Esc>Pea()<Esc>"+P')
map("i", "<leader>mk", '<Esc>viW<C-k>ea')
map("n", "<leader>mk", 'ciw[]<Esc>Pea()<Esc>"+P')

map("n", "<leader>mag", ":ZettelOpen<CR>")
map("n", "<leader>mat", ":ZettelOpen<CR>title:")
