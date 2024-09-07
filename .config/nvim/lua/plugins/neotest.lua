return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "lawrence-laz/neotest-zig",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-jest",
  },
  config = function()
    require("neotest").setup({
      discovery = {
        enabled = false,
      },
      adapters = {
        require('neotest-jest')({
          jestCommand = "node node_modules/.bin/jest",
          jestConfigFile = function(file)
            if string.find(file, "/apps/") then
              return string.match(file, "(.-/[^/]+/)src") .. "jest.config.ts"
            end

            if string.find(file, "/libs/") then
              return string.match(file, "(.-/[^/]+/)src") .. "jest.config.ts"
            end

            return vim.fn.getcwd() .. "/jest.config.ts"
          end,
          env = { CI = true },
          cwd = function(path)
            return vim.fn.getcwd()
          end,
        }),
        require('neotest-zig')({
          dap = {
            adapter = "lldb",
          }
        }),
        require('rustaceanvim.neotest')
      },
      output = { open_on_run = true },
    })
    vim.keymap.set("n", "<leader>to",
      function() require("neotest").output.open({ enter = true, auto_close = true }) end)
    vim.keymap.set("n", "<leader>rt", function() require("neotest").run.run() end)
  end
}
