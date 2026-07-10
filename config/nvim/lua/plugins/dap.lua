return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Debug: continue" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Debug: step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Debug: step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Debug: step out" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug: toggle REPL" },
      { "<leader>dq", function() require("dap").terminate() end, desc = "Debug: terminate" },
    },
  },
  {
    -- Configures nvim-dap for Python using debugpy, installed via Mason
    -- (:MasonInstall debugpy) so it lives in an isolated venv rather than
    -- needing debugpy in every project's own environment.
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    ft = "python",
    config = function()
      local python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      if vim.fn.executable(python) == 0 then
        vim.notify(
          "debugpy not installed: run :MasonInstall debugpy to enable Python debugging",
          vim.log.levels.WARN
        )
        return
      end
      require("dap-python").setup(python)
    end,
  },
}
