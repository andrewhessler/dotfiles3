return {
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    opts = {
      enabled = false, -- only using this plugin for pulling blame url, git signs will display the blame
    },
    keys = {
      {
        "<leader>gy",
        ":GitBlameCopyFileURL<cr>",
        mode = "n",
        desc = "Copy commit URL",
      },
    }
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 1000
      }
    },
  }
}
