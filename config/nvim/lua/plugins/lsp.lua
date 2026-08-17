-- ruff is a prebuilt GitHub release binary, but mason installs basedpyright
-- from PyPI into a venv. Debian ships venv's ensurepip separately
-- (python3-venv), and without it every startup fails the install.
local servers = { "ruff" }

local function has_python_venv()
  if vim.fn.executable("python3") ~= 1 then
    return false
  end
  vim.fn.system({ "python3", "-c", "import ensurepip" })
  return vim.v.shell_error == 0
end

if has_python_venv() then
  table.insert(servers, "basedpyright")
else
  vim.notify("python3 venv unavailable (install python3-venv): skipping LSP server basedpyright", vim.log.levels.WARN)
end

local npm_servers = { "ts_ls", "svelte", "html", "cssls", "bashls" }
local function has_public_npm()
  if vim.fn.executable("npm") ~= 1 then
    return false
  end
  local result = vim.fn.system("npm config get registry")
  return result:find("registry.npmjs.org") ~= nil
end

if has_public_npm() then
  vim.list_extend(servers, npm_servers)
else
  vim.notify(
    "public npm registry unavailable: skipping LSP servers " .. table.concat(npm_servers, ", "),
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
