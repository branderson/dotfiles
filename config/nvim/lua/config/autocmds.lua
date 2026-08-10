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

-- dejima sets DEJIMA, never present on a normal host session, so this only
-- fires inside the sandbox: open claudecode.nvim's terminal on startup
-- rather than requiring <leader>ac, since starting a Claude session is the
-- entire point of being in there.
-- :ClaudeCode is defined by the plugin itself, so it doesn't exist until
-- claudecode.nvim has actually loaded - it's lazy-loaded on the <leader>ac
-- keymap only (no `cmd` in its lazy.nvim spec), so force that load first.
if vim.env.DEJIMA then
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.schedule(function()
        require("lazy").load({ plugins = { "claudecode.nvim" } })
        vim.cmd("ClaudeCode")
        -- :ClaudeCode leaves the terminal window focused, so `tab split` gives
        -- the same terminal buffer a full-screen window in its own tab while
        -- the original tab keeps the narrow split next to the editor - one tab
        -- to work in Claude, one to work side-by-side. Window-local options are
        -- inherited by the split, and snacks' auto_insert (buffer-local) puts
        -- the new window back into terminal mode on entry.
        local claude_buf = require("claudecode.terminal").get_active_terminal_bufnr()
        if claude_buf and vim.api.nvim_get_current_buf() == claude_buf then
          vim.cmd("tab split")
        end
      end)
    end,
  })
end
