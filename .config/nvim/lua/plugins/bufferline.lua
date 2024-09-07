return {
  {
    'romgrk/barbar.nvim',
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {
      -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
      -- animation = true,
      -- insert_at_start = true,
      -- …etc.
    },
    version = '^1.0.0', -- optional: only update when a new 1.x version is released
    config = function(opts)
      require("barbar").setup(opts);
      local map = vim.api.nvim_set_keymap
      local options = { noremap = true, silent = true }

      map('n', '<A-,>', '<Cmd>BufferPrevious<CR>', options)
      map('n', '<A-.>', '<Cmd>BufferNext<CR>', options)
      map('n', '<A-c>', '<Cmd>BufferClose<CR>', options)
      -- harpoon uses this now
      -- map('n', '<C-p>', '<Cmd>BufferPick<CR>', options)
    end

  },
  {
    "chrisgrieser/nvim-early-retirement",
    config = true,
    event = "VeryLazy",
  },
}
