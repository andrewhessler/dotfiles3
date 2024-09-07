return {
  -- Used to install LSPs
  {
    'williamboman/mason.nvim',
    lazy = false,
    config = true,
  },
  {
    'mrcjkb/rustaceanvim',
    version = '^6', -- Recommended
    lazy = false,   -- This plugin is already lazy
  },
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    -- Copied from LazyVim/lua/lazyvim/plugins/extras/dap/core.lua and
    -- modified.
    keys = {
      {
        "<leader>db",
        function() require("dap").toggle_breakpoint() end,
        desc = "Toggle Breakpoint"
      },

      {
        "<leader>dc",
        function() require("dap").continue() end,
        desc = "Continue"
      },

      {
        "<leader>dC",
        function() require("dap").run_to_cursor() end,
        desc = "Run to Cursor"
      },

      {
        "<leader>dT",
        function() require("dap").terminate() end,
        desc = "Terminate"
      },
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    ---@type MasonNvimDapSettings
    opts = {
      -- This line is essential to making automatic installation work
      -- :exploding-brain
      handlers = {},
      automatic_installation = {
        -- These will be configured by separate plugins.
        exclude = {
          "delve",
          "python",
        },
      },
      -- DAP servers: Mason will be invoked to install these if necessary.
      ensure_installed = {
        "bash",
        "codelldb",
        "php",
        "python",
      },
    },
    dependencies = {
      "mfussenegger/nvim-dap",
      "williamboman/mason.nvim",
    },
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    event = "VimEnter",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("nvim-dap-virtual-text").setup({})
    end,
  },


  -- Better typescript LSP, bypasses some extra layer, same as vtsls, but more bundled.
  -- Prefer to use LSP rather than this pulgin, but vtsls was giving me problems.
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("typescript-tools").setup({
      })

      vim.keymap.set('n', '<leader>tir', '<cmd>TSToolsRemoveUnusedImports<cr>')
      vim.keymap.set('n', '<leader>tia', '<cmd>TSToolsAddMissingImports<cr>')
    end
  },
  -- Used for live LSP-ish generator while working on nvim config
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- Autocompletion
  {
    'saghen/blink.cmp',

    -- use a release tag to download pre-built binaries
    version = 'v0.7.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = 'super-tab', ['<CR>'] = { 'accept', 'fallback' }, ['<C-l>'] = { 'show' } },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
          treesitter_highlighting = true,
          update_delay_ms = 0,
          window = {
            min_width = 60,
            max_width = 120,
            max_height = 100,
          }
        }
      }
    },
    opts_extend = { "sources.default" }
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'saghen/blink.cmp' },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'j-hui/fidget.nvim',                opts = {} }, -- tells me what's loading in the bottom right
    },
    config = function()
      vim.o.signcolumn = 'yes'

      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP Actions',
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
          vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
          vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
          vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
          vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
          vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
          vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
          vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
          vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
          vim.keymap.set('n', '<leader>k', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
          vim.keymap.set('v', '<leader>k', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
        end
      })

      require('mason-lspconfig').setup({
        -- vtsls does what typescript-tools does and interacts directly with tsserver rather than going through a slew of APIs? Just prefer LSP over plugin
        ensure_installed = { 'eslint', 'typos_lsp', 'lua_ls', 'zls', 'omnisharp', 'cssmodules_ls', 'cssls', 'tailwindcss' },
        automatic_installation = true,
        handlers = {
          -- this first function is the "default handler"
          -- it applies to every language server without a "custom handler"
          function(server_name)
            local capabilities = require('blink-cmp').get_lsp_capabilities()
            require('lspconfig')[server_name].setup({ capabilities = capabilities })
          end,
          ['ts_ls'] = function()
            -- install this just for tsserver or whatever, don't want to use it as lsp, use typescript_tools instead
          end,
          ['rust_analyzer'] = function()
            -- use rustaceanvim instead
          end,
          ['helm_ls'] = function()
            local lspconfig = require('lspconfig')

            lspconfig.helm_ls.setup {
              settings = {
                ['helm-ls'] = {
                  yamlls = {
                    path = "yaml-language-server",
                  }
                }
              }
            }
          end
        }
      })
    end
  }
}
