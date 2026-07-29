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
        -- snacks.nvim's terminal style binds a double-<Esc>-within-200ms
        -- shortcut (term_normal) that silently drops the buffer out of
        -- terminal-mode into Neovim's own Normal mode -- swallowing the
        -- second Esc instead of forwarding it to the claude CLI, which uses
        -- double-Esc itself (e.g. to rewind/interrupt). Once stuck in Normal
        -- mode there (invisible, since showmode is off), the next keystroke
        -- meant for the CLI -- e.g. Ctrl-O to toggle expanded tool output --
        -- is instead consumed by Neovim's built-in Normal-mode <C-o> (jump
        -- to older jumplist position), yanking focus to a different window.
        -- Disabling this shortcut makes every Esc pass through raw to the
        -- CLI; ,, (config/keymaps.lua) remains the deliberate way to reach
        -- Normal mode in this terminal.
        snacks_win_opts = {
          keys = {
            term_normal = false,
            -- Per :help terminal-mode, when the running program hasn't enabled
            -- its own mouse reporting (the claude CLI doesn't), any mouse event
            -- over the terminal -- including the scroll wheel -- drops terminal
            -- focus to Neovim's Normal mode instead of being forwarded, leaving
            -- you stuck there (invisibly, since showmode is off) until you press
            -- 'i' again -- and clicks meant for the CLI (e.g. approval prompts)
            -- land as buffer-cursor movement in the meantime. Intercept the
            -- wheel so it scrolls the window and silently returns to terminal
            -- mode, instead of leaving that to the default behavior.
            scroll_up = {
              "<ScrollWheelUp>",
              "<C-\\><C-n><ScrollWheelUp>i",
              mode = "t",
              desc = "Scroll up without leaving terminal mode",
            },
            scroll_down = {
              "<ScrollWheelDown>",
              "<C-\\><C-n><ScrollWheelDown>i",
              mode = "t",
              desc = "Scroll down without leaving terminal mode",
            },
          },
        },
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

      -- claudecode's unified diff buffers pick up treesitter's foldexpr via
      -- the normal FileType autocmd, so they otherwise inherit the global
      -- foldlevelstart and open partially collapsed. Fully expand folds in
      -- these specifically instead of changing the default for all buffers.
      vim.api.nvim_create_autocmd("BufWinEnter", {
        group = vim.api.nvim_create_augroup("ClaudeCodeDiffUnfold", { clear = true }),
        callback = function(args)
          if vim.b[args.buf].claudecode_inline_diff then
            vim.wo.foldlevel = 99
          end
        end,
      })
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
