return {
  'nullromo/go-up.nvim',
  opts = {
    respectScrolloff = true
  }, -- specify options here
  config = function(_, opts)
    local goUp = require('go-up')
    goUp.setup(opts)
  end,
}
