-- autoread (options.lua) only reloads a buffer once Vim checks the file's
-- timestamp, which by default only happens on a handful of internal
-- triggers. Force that check on focus/buffer-switch/idle so external edits
-- (e.g. from claudecode.nvim) show up immediately instead of surfacing the
-- stale-buffer prompt later.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("CheckTimeOnFocus", { clear = true }),
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

local augroup = vim.api.nvim_create_augroup("EnterBuffer", { clear = true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPre", "FileReadPre", "BufEnter" }, {
  group = augroup,
  pattern = "Makefile",
  callback = function()
    vim.bo.expandtab = false
    vim.bo.softtabstop = 0
    vim.bo.shiftwidth = 8
  end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPre", "FileReadPre", "BufEnter" }, {
  group = augroup,
  pattern = { "*.asm", "*.S" },
  callback = function()
    vim.bo.softtabstop = 8
    vim.bo.shiftwidth = 8
  end,
})
