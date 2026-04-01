local map = function(mode, lhs, rhs, opts)
  local options = opts or { noremap = true, silent = true }
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local map_callback = function(mode, lhs, rhs)
  vim.api.nvim_set_keymap(mode, lhs, '', { callback = rhs, noremap = true, silent = true })
end

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
      vim.cmd('TSUpdate')
    end
  end
})

vim.pack.add({
  -- Shared
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/sindrets/diffview.nvim",
  -- Features
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/romgrk/barbar.nvim",
  "https://github.com/chrisgrieser/nvim-early-retirement",
  "https://github.com/navarasu/onedark.nvim",
  "https://github.com/catgoose/nvim-colorizer.lua",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/f-person/git-blame.nvim",
  "https://github.com/nullromo/go-up.nvim",
  "https://github.com/lukas-reineke/indent-blankline.nvim",
  "https://github.com/echasnovski/mini.nvim",
  "https://github.com/Isrothy/neominimap.nvim",
  "https://github.com/NeogitOrg/neogit",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/nvim-tree/nvim-tree.lua",
  "https://github.com/itchyny/vim-qfedit",
  "https://github.com/danielfalk/smart-open.nvim",
  "https://github.com/nvim-telescope/telescope-live-grep-args.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim", -- go make in site packages
  "https://github.com/debugloop/telescope-undo.nvim",
  "https://github.com/kkharji/sqlite.lua",
  "https://github.com/folke/trouble.nvim",
  "https://github.com/folke/which-key.nvim",
  -- Testing
  "https://github.com/nvim-neotest/neotest",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/lawrence-laz/neotest-zig",
  "https://github.com/antoinemadec/FixCursorHold.nvim",
  "https://github.com/nvim-neotest/neotest-jest",
  -- LSPs/Completions
  "https://github.com/williamboman/mason.nvim",
  "https://github.com/mrcjkb/rustaceanvim",
  "https://github.com/pmizio/typescript-tools.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/folke/lazydev.nvim",
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range('1.*') }, -- build with :BlinkCmp build
  "https://github.com/williamboman/mason-lspconfig.nvim",
  "https://github.com/j-hui/fidget.nvim",
})

--
-- Features
--
require('nvim-treesitter').install({ "c", "rust", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline",
  "javascript", "typescript", "tsx", "zig", "wgsl" })


require('onedark').setup({
  transparent = true,
  style = 'dark',
  -- highlights = {
  --   htmlTag = { fg = "$purple" },
  --   htmlTagName = { fg = "$purple" },
  --   Special = { fg = "$purple" },
  --   Identifier = { fg = "$purple" },
  --   Normal = { fg = "#abb2bf" },
  --   typescriptBraces = { fg = "#abb2bf" },
  --   typescriptParens = { fg = "#abb2bf" }
  -- }
})

local color_override = "onedark"
vim.cmd.colorscheme(color_override)

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#23344d" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#334444", fg = "none" })
-- vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#334444", fg = "#EE7722" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })


--
-- LSPs
--
local function setup_neotest()
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
  map_callback("n", "<leader>to",
    function() require("neotest").output.open({ enter = true, auto_close = true }) end)
  map_callback("n", "<leader>rt", function() require("neotest").run.run() end)
end

-- Better typescript LSP, bypasses some extra layer, same as vtsls, but more bundled.
-- Prefer to use LSP rather than this plugin, but vtsls was giving me problems.
vim.api.nvim_create_autocmd('FileType', {
  pattern = { "ts", "js", "tsx" },
  once = true,
  callback = function()
    require('typescript-tools').setup({})
    map('n', '<leader>tir', '<cmd>TSToolsRemoveUnusedImports<cr>')
    map('n', '<leader>tia', '<cmd>TSToolsAddMissingImports<cr>')
    setup_neotest()
  end
})


-- Used for live LSP-ish generator while working on nvim config
vim.api.nvim_create_autocmd('FileType', {
  pattern = { "lua" },
  once = true,
  callback = function()
    require('lazydev').setup({
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    })
  end
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { "rs" },
  once = true,
  callback = function()
    require('rustaceanvim')
    setup_neotest()
  end
})


vim.api.nvim_create_autocmd('BufRead', {
  callback = function(args)
    if vim.bo[args.buf].filetype == "oil" then return false end
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

    -- Simple and easy statusline.
    --  You could remove this setup call if you don't like it,
    --  and try some other statusline plugin
    local statusline = require 'mini.statusline'
    -- set use_icons to true if you have a Nerd Font
    statusline.setup { use_icons = vim.g.have_nerd_font }

    -- You can configure sections in the statusline by overriding their
    -- default behavior. For example, here we set the section for
    -- cursor location to LINE:COLUMN
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return '%2l:%-2v'
    end

    require('neominimap')
    map('n', "<leader>mm", "<cmd>Neominimap Toggle<cr>")
    vim.g.neominimap = {
      auto_enable = false,
    }

    require('nvim-autopairs').setup()

    require('barbar').setup()
    map('n', '<A-,>', '<Cmd>BufferPrevious<CR>')
    map('n', '<A-.>', '<Cmd>BufferNext<CR>')
    map('n', '<A-c>', '<Cmd>BufferClose<CR>')

    require('colorizer').setup() -- highlights hexcodes and words with their associated color

    require('blink-cmp').setup({
      keymap = { preset = 'super-tab', ['<CR>'] = { 'accept', 'fallback' }, ['<C-l>'] = { 'show' } },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
          treesitter_highlighting = true,
          update_delay_ms = 100,
          window = {
            min_width = 60,
            max_width = 120,
            max_height = 100,
          }
        }
      },
      fuzzy = { implementation = "prefer_rust" }
    })

    require('conform').setup({
      -- Define your formatters
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
      },
      -- Set default options
      default_format_opts = {
        lsp_format = "fallback",
      },
      -- Set up format-on-save
      format_on_save = { timeout_ms = 1200 },
      -- Customize formatters
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2" },
        },
      },
    })
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

    require('gitsigns').setup({
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 1000
      }
    })
    require('gitblame').setup({
      enabled = false, -- only using this plugin for pulling blame url, git signs will display the blame
    })

    map('n', '<leader>gy', ':GitBlameCopyFileURL<CR>')

    require('go-up').setup({
      respectScrolloff = true
    })

    require('ibl').setup() -- indent blankline, shows line for indents
  end
})
require('mason').setup()
require('mason-lspconfig').setup({
  -- vtsls does what typescript-tools does and interacts directly with tsserver rather than going through a slew of APIs? Just prefer LSP over plugin
  ensure_installed = { 'eslint', 'typos_lsp', 'lua_ls', 'zls', 'omnisharp', 'cssmodules_ls', 'cssls', 'tailwindcss', 'wgsl_analyzer' },
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
require('lspconfig')

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


vim.api.nvim_create_user_command("Neogit", function(opts)
  require("neogit").setup({})
  require("neogit").open(opts.fargs)
end, { nargs = "*" })
map("n", "<leader>gs", ":Neogit<cr>")



-- nvim tree
local function edit_or_open()
  local api = require "nvim-tree.api"
  local node = api.tree.get_node_under_cursor()

  if node.nodes ~= nil then
    -- expand or collapse folder
    api.node.open.edit()
  else
    -- open file
    api.node.open.edit()
  end
end

-- open as vsplit on current node
local function vsplit_preview()
  local api = require "nvim-tree.api"
  local node = api.tree.get_node_under_cursor()

  if node.nodes ~= nil then
    -- expand or collapse folder
    api.node.open.edit()
  else
    -- open file as vsplit
    api.node.open.vertical()
  end

  -- Finally refocus on tree if it was lost
  api.tree.focus()
end

local function my_on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.map.on_attach.default(bufnr)
  vim.keymap.set("n", "l", edit_or_open, opts("Edit Or Open"))
  vim.keymap.set("n", "L", vsplit_preview, opts("Vsplit Preview"))
  vim.keymap.set("n", "h", api.tree.close, opts("Close"))
  vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))

  vim.keymap.set("n", "<C-e>", "<C-w>l", opts("Leave tree for another window"))
end

require("oil").setup()
map("n", "-", "<cmd>Oil<CR>")

require("nvim-tree").setup({
  git = {
    enable = false,
    timeout = 400
  },
  on_attach = my_on_attach,
  view = { adaptive_size = true },
  update_focused_file = {
    enable = true
  },
  diagnostics = {
    enable = true,
  },
})
local api = require("nvim-tree.api")

vim.keymap.set("n", "<C-e>", ":NvimTreeFocus<cr>", { silent = true, noremap = true })

api.events.subscribe(api.events.Event.TreeOpen, function()
  local tree_winid = api.tree.winid()

  if tree_winid ~= nil then
    vim.api.nvim_set_option_value('statusline', ' ', { win = tree_winid })
  end
end)

local function ensure_telescope()
  require("telescope").load_extension("smart_open")

  local telescope = require("telescope")
  local lga_actions = require("telescope-live-grep-args.actions")


  local open_with_trouble = require("trouble.sources.telescope").open

  telescope.setup({
    defaults = {
      mappings = {
        i = { ["<c-t>"] = open_with_trouble },
        n = { ["<c-t>"] = open_with_trouble },
      },
    },
  })

  -- Calling telescope's setup from multiple specs does not hurt, it will happily merge the
  -- configs for us. We won't use data, as everything is in it's own namespace (telescope
  -- defaults, as well as each extension).
  telescope.setup({
    extensions = {
      live_grep_args = {
        auto_quoting = true,
        mappings = {
          i = {
            ["<C-k>"] = lga_actions.quote_prompt(),
            ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
            -- freeze the current list and start a fuzzy search in the frozen list
            ["<C-space>"] = lga_actions.to_fuzzy_refine,
          }
        }
      },
      undo = {
        side_by_side = true,
        layout_strategy = "vertical",
        layout_config = {
          preview_height = 0.8,
        },
      },
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      }
    }
  })
  telescope.load_extension("undo")
  telescope.load_extension("live_grep_args")
  telescope.load_extension("fzf")
end

map_callback('n', '<leader>fp', function()
  ensure_telescope()
  local builtin = require('telescope.builtin')
  builtin.find_files()
end)
map_callback('n', '<C-f>', function()
  ensure_telescope()
  vim.cmd('Telescope smart_open')
end)
-- vim.keymap.set('n', '<C-f>', builtin.git_files, {})
-- vim.keymap.set('n', '<leader>fs', builtin.live_grep, {})
map_callback('n', '<leader>fg', function()
  ensure_telescope()
  vim.cmd("lua require('telescope').extensions.live_grep_args.live_grep_args()")
end)
map_callback('n', '<leader>u', function()
  ensure_telescope()
  vim.cmd('Telescope undo')
end)

map_callback("n", "<leader>ff", function()
  ensure_telescope()
  local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")
  live_grep_args_shortcuts.grep_word_under_cursor()
end)

map_callback("n", "<leader>?", function()
  require("which-key").show({ global = false })
end)
