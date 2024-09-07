vim.o.number = true
vim.o.relativenumber = true

vim.o.showmode = false
vim.o.mouse = 'a'

vim.o.autowrite = true
-- vim.o.clipboard = "unnamedplus" -- commented out to allow for separation of registers and OS clipboard

vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

vim.o.smartindent = true

vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = ""
vim.o.foldcolumn = "0"
vim.o.foldlevelstart = 99
vim.o.foldlevel = 99
vim.o.foldnestmax = 20

vim.o.wrap = false

vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.o.undofile = true

vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.termguicolors = true

vim.o.scrolloff = 8
vim.o.signcolumn = "yes"
vim.o.isfname = vim.o.isfname .. ",@-@"

vim.o.updatetime = 50

vim.o.colorcolumn = ""
vim.o.cursorline = true

vim.g.have_nerd_font = true

vim.diagnostic.config({
  signs = { priority = 9999 },
  underline = true,
  update_in_insert = false, -- false so diags are updated on InsertLeave
  virtual_text = { severity = { min = "INFO", max = "ERROR" } },
  virtual_lines = false,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = true,
    header = "",
  },
})
