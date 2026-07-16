return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>t", ":Neotree toggle<CR>", desc = "Toggle file explorer" },
      {
        "<leader>cd",
        function()
          vim.cmd("cd " .. vim.fn.fnameescape(vim.fn.expand("%:p:h")))
          vim.cmd("pwd")
          vim.cmd("Neotree dir=" .. vim.fn.fnameescape(vim.fn.getcwd()))
        end,
        desc = "cd to current file's directory and open explorer",
      },
    },
    opts = {},
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>.", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Jump to symbol" },
      { "<leader>;", "<cmd>Telescope buffers<CR>", desc = "Jump to buffer" },
      {
        "<leader>be",
        "<cmd>Telescope buffers sort_mru=true ignore_current_buffer=true<CR>",
        desc = "Jump to buffer (MRU)",
      },
      { "<leader>ag", "<cmd>Telescope live_grep<CR>", desc = "Grep" },
      { "<leader>?", "<cmd>Telescope keymaps<CR>", desc = "Search keybindings" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({})
      telescope.load_extension("fzf")
    end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<leader>/", function() require("flash").jump() end, mode = { "n", "x", "o" }, desc = "Flash jump" },
      { "<leader>s", function() require("flash").jump({ search = { mode = "search" } }) end, mode = { "n", "x", "o" }, desc = "Flash search jump" },
      { "<leader><leader>s", function() require("flash").treesitter() end, mode = { "n", "x", "o" }, desc = "Flash treesitter" },
      { "<leader>f", function() require("flash").jump({ search = { forward = true, wrap = false } }) end, mode = { "n", "x", "o" }, desc = "Flash forward" },
    },
  },

  { "kylechui/nvim-surround", event = { "BufReadPost", "BufNewFile" }, opts = {} },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },

  {
    "echasnovski/mini.align",
    version = "*",
    keys = {
      { "ga=", mode = { "n", "x" }, desc = "Align on =" },
      { "ga:", mode = { "n", "x" }, desc = "Align on :" },
    },
    config = function()
      require("mini.align").setup({
        mappings = { start = "ga", start_with_preview = "" },
      })
    end,
  },

  { "echasnovski/mini.bufremove", version = "*", keys = {
    { "<leader><leader>c", function() require("mini.bufremove").delete(0, false) end, desc = "Close buffer" },
  } },

  {
    "mg979/vim-visual-multi",
    branch = "master",
    keys = { "<C-n>" },
    init = function()
      vim.g.VM_maps = {
        ["Find Under"] = "<C-n>",
        ["Find Subword Under"] = "<C-n>",
      }
    end,
  },

  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    -- Plugin's own default mappings rely on a Vim-only <C-w> terminal escape
    -- that Neovim doesn't support, so :terminal buffers (e.g. claudecode.nvim)
    -- leak the raw keystrokes to the embedded process. Disable them and
    -- define our own, using Neovim's actual terminal-mode escape.
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<CR>" },
      { "<C-j>", "<cmd>TmuxNavigateDown<CR>" },
      { "<C-k>", "<cmd>TmuxNavigateUp<CR>" },
      { "<C-l>", "<cmd>TmuxNavigateRight<CR>" },
      { "<C-h>", "<C-\\><C-n><cmd>TmuxNavigateLeft<CR>", mode = "t" },
      { "<C-j>", "<C-\\><C-n><cmd>TmuxNavigateDown<CR>", mode = "t" },
      { "<C-k>", "<C-\\><C-n><cmd>TmuxNavigateUp<CR>", mode = "t" },
      { "<C-l>", "<C-\\><C-n><cmd>TmuxNavigateRight<CR>", mode = "t" },
    },
  },

  {
    "mattn/emmet-vim",
    ft = { "html", "css" },
    init = function()
      vim.g.user_emmet_install_global = 0
    end,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "html", "css" },
        callback = function() vim.cmd("EmmetInstall") end,
      })
    end,
  },
}
