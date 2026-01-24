return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter').install({ "c", "rust", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline",
      "javascript", "typescript", "tsx", "zig" })
  end
}
