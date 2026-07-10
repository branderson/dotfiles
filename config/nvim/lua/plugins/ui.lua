return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    opts = {
      italic = { strings = true, comments = true, operators = false, folds = true },
      invert_selection = true,
      invert_signs = false,
    },
    config = function(_, opts)
      require("gruvbox").setup(opts)
      vim.o.background = "dark"
      local ok = pcall(vim.cmd.colorscheme, "gruvbox")
      if not ok then
        vim.cmd.colorscheme("desert")
      end
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = { theme = "gruvbox" },
    },
  },

  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {},
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
  },

  { "nvim-tree/nvim-web-devicons", opts = {} },

  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VimEnter",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      local function fortune_header()
        local cows = vim.fn.systemlist("cowsay -l")
        local cow = "default"
        if #cows > 1 then
          cow = cows[math.random(2, #cows)]
        end
        local moods = { "b", "d", "g", "p", "s", "t", "w", "y" }
        local mood = moods[math.random(#moods)]
        local cmd = string.format(
          "fortune -a -s | fmt -80 -s | cowthink -%s -f %s -n",
          mood,
          cow
        )
        local ok, lines = pcall(vim.fn.systemlist, cmd)
        if not ok or #lines == 0 then
          return { "Welcome to Neovim" }
        end
        return lines
      end

      dashboard.section.header.val = fortune_header()
      dashboard.section.buttons.val = {
        dashboard.button("e", "  New file", ":enew<CR>"),
        dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
        dashboard.button("g", "  Live grep", ":Telescope live_grep<CR>"),
        dashboard.button("s", "  Restore session", ":lua require('persistence').load()<CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
      }
      alpha.setup(dashboard.opts)

      vim.keymap.set("n", "<leader><leader>o", ":Alpha<CR>")
    end,
  },
}
