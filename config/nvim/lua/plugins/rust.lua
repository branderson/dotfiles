return {
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
    init = function()
      vim.g.rustaceanvim = {
        tools = {},
        server = {
          on_attach = function(_, bufnr)
            vim.keymap.set("n", "<localleader>rr", function()
              vim.cmd.RustLsp("run")
            end, { buffer = bufnr })
          end,
        },
      }
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      automatic_enable = { exclude = { "rust_analyzer" } },
    },
  },
}
