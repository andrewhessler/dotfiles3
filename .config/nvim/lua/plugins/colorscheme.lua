return {
  {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = { -- set to setup table
    },
  },
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      require('onedark').setup({
        transparent = true
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
    end
  }
}
