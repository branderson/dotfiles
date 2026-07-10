local map = vim.keymap.set

-- Insert/command-mode escape via ,,
map("i", ",,", "<Esc>")
map("c", ",,", "<Esc><Esc>")

-- Move by display line, not physical line
map("n", "j", "gj")
map("n", "k", "gk")

-- Clear search highlight
map("n", "<leader><leader><Esc>", ":nohl<CR>")

-- Hex mode
map("n", "<leader>\\he", ":%!xxd<CR>")
map("n", "<leader>\\hd", ":%!xxd -r<CR>")

-- Toggle whitespace display
map("n", "<leader><leader>lw", ":set list!<CR>")
-- List registers / marks
map("n", "<leader><leader>lr", ":reg<CR>")
map("n", "<leader><leader>lm", ":marks<CR>")

-- Prev/next buffer
map("n", "<leader>q", ":bp<CR>")
map("n", "<leader>w", ":bn<CR>")

-- System clipboard
map({ "n", "v" }, "<leader>y", '"+y')
map({ "n", "v" }, "<leader>Y", '"+Y')
map({ "n", "v" }, "<leader>p", '"+p')
map({ "n", "v" }, "<leader>P", '"+P')
map({ "n", "v" }, "<leader>x", '"+x')
map("n", "<leader>dd", '"+dd')

-- Make split
map("n", "<leader>-", ":sp<Space>")
map("n", "<leader><Bar>", ":vsp<Space>")

-- Open init.lua
map("n", "<leader>v", ":e $MYVIMRC<CR>")

-- Low-light / daylight mode
map("n", "<leader><leader>ll", ":set background=dark<CR>")
map("n", "<leader><leader>LL", ":set background=light<CR>")

-- Ranger / trailing whitespace utilities
map("n", "<leader>ra", function() require("util").ranger() end)
map("n", "<leader>rw", function() require("util").delete_trailing_ws() end)
