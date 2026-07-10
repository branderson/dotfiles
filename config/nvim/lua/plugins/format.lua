return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        css = { "prettier" },
        svelte = { "prettier" },
        pcss = { "prettier" },
        html = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        python = { "ruff_format" },
        rust = { "rustfmt" },
        lua = { "stylua" },
      },
      format_on_save = {
        lsp_format = "fallback",
        timeout_ms = 2000,
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "BufReadPost", "InsertLeave" },
    config = function()
      require("lint").linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        svelte = { "eslint_d" },
      }

      if vim.fn.executable("shellcheck") == 1 then
        require("lint").linters_by_ft.sh = { "shellcheck" }
      else
        vim.notify("shellcheck not found: skipping shell linting", vim.log.levels.WARN)
      end

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
