return {
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>ct", "<cmd>AerialToggle<CR>", desc = "Toggle symbol outline" },
    },
    opts = {},
  },

  {
    "jiaoshijie/undotree",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>u", function() require("undotree").toggle() end, desc = "Toggle undo tree" },
    },
    opts = {},
  },

  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
