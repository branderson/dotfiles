local map = vim.keymap.set

-- Insert/command-mode escape via ,,
map("i", ",,", "<Esc>", { desc = "Escape insert mode" })
map("c", ",,", "<Esc><Esc>", { desc = "Escape command mode" })

-- Move by display line, not physical line
map("n", "j", "gj", { desc = "Move down by display line" })
map("n", "k", "gk", { desc = "Move up by display line" })

-- Clear search highlight
map("n", "<leader><leader><Esc>", ":nohl<CR>", { desc = "Clear search highlight" })

-- Hex mode
map("n", "<leader>\\he", ":%!xxd<CR>", { desc = "Hex dump buffer" })
map("n", "<leader>\\hd", ":%!xxd -r<CR>", { desc = "Undo hex dump" })

-- Toggle whitespace display
map("n", "<leader><leader>lw", ":set list!<CR>", { desc = "Toggle whitespace display" })
-- List registers / marks
map("n", "<leader><leader>lr", ":reg<CR>", { desc = "List registers" })
map("n", "<leader><leader>lm", ":marks<CR>", { desc = "List marks" })

-- Prev/next buffer
map("n", "<leader>q", ":bp<CR>", { desc = "Previous buffer" })
map("n", "<leader>w", ":bn<CR>", { desc = "Next buffer" })

-- System clipboard
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map({ "n", "v" }, "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
map({ "n", "v" }, "<leader>P", '"+P', { desc = "Paste before from system clipboard" })
map({ "n", "v" }, "<leader>x", '"+x', { desc = "Cut to system clipboard" })
map("n", "<leader>dd", '"+dd', { desc = "Delete line to system clipboard" })

-- Make split
map("n", "<leader>-", ":sp<Space>", { desc = "Horizontal split" })
map("n", "<leader><Bar>", ":vsp<Space>", { desc = "Vertical split" })

-- Open init.lua
map("n", "<leader>v", ":e $MYVIMRC<CR>", { desc = "Edit init.lua" })

-- Low-light / daylight mode
map("n", "<leader><leader>ll", ":set background=dark<CR>", { desc = "Dark background" })
map("n", "<leader><leader>LL", ":set background=light<CR>", { desc = "Light background" })

-- Ranger / trailing whitespace utilities
map("n", "<leader>ra", function() require("util").ranger() end, { desc = "Open ranger" })
map("n", "<leader>rw", function() require("util").delete_trailing_ws() end, { desc = "Delete trailing whitespace" })

-- Terminal-mode Ctrl-Z otherwise goes straight to the embedded process (e.g.
-- suspending the claude CLI inside claudecode.nvim's terminal with no way to
-- fg it back) instead of suspending Neovim itself, like Ctrl-Z does by
-- default in Normal mode.
map("t", "<C-z>", "<C-\\><C-n><C-z>", { desc = "Suspend Neovim" })
