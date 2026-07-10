return {
  { "folke/snacks.nvim", lazy = false },

  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal = {
        provider = "snacks",
        split_side = "right",
        split_width_percentage = 0.30,
      },
      diff_opts = {
        keep_terminal_focus = true,
        -- Unified (single-buffer, VS Code-style) diff instead of side-by-side
        -- splits: it only ever opens one new window, so it can't add a second
        -- split and squish the rest of the layout the way the side-by-side
        -- diff sometimes did.
        layout = "unified",
      },
    },
    config = function(_, opts)
      require("claudecode").setup(opts)

      -- claudecode picks a window for the diff by scanning all windows for the
      -- first non-sidebar/non-terminal one, not the one you're actually
      -- focused on, so the diff could land away from your active pane. Prefer
      -- the current window when it's a normal editing window.
      local diff = require("claudecode.diff")
      local default_find_main_editor_window = diff._find_main_editor_window
      diff._find_main_editor_window = function()
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_win_get_buf(win)
        local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
        local win_config = vim.api.nvim_win_get_config(win)
        local is_floating = win_config.relative and win_config.relative ~= ""
        local is_diff_win = vim.api.nvim_win_get_option(win, "diff")
        if not is_floating and not is_diff_win and buftype ~= "terminal" and buftype ~= "prompt" then
          return win
        end
        return default_find_main_editor_window()
      end
    end,
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<CR>", desc = "Toggle Claude Code" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<CR>", desc = "Focus Claude Code" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<CR>", desc = "Add buffer to Claude Code" },
      { "<leader>as", "<cmd>ClaudeCodeSend<CR>", mode = "v", desc = "Send selection to Claude Code" },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<CR>", desc = "Accept Claude Code diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<CR>", desc = "Deny Claude Code diff" },
    },
  },
}
