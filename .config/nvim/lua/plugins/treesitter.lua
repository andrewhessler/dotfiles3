return {
  "nvim-treesitter/nvim-treesitter",
  build = function()
    require("nvim-treesitter.install").update({ with_sync = true })()
  end,
  config = function()
    require 'nvim-treesitter.configs'.setup {
      ensure_installed = { "c", "rust", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "javascript", "typescript", "zig" },
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    }
  end
}
