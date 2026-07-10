local servers = { "basedpyright", "ruff" }

local npm_servers = { "ts_ls", "svelte", "html", "cssls", "bashls" }
if vim.fn.executable("npm") == 1 then
  vim.list_extend(servers, npm_servers)
else
  vim.notify(
    "npm not found: skipping LSP servers " .. table.concat(npm_servers, ", "),
    vim.log.levels.WARN
  )
end

return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = servers,
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-org/mason-lspconfig.nvim", "saghen/blink.cmp", "saghen/blink.lib" },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true }),
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("v", "ff", function() vim.lsp.buf.format({ async = true }) end, opts)
        end,
      })

      for _, server in ipairs(servers) do
        vim.lsp.config(server, { capabilities = capabilities })
        vim.lsp.enable(server)
      end
    end,
  },
}
