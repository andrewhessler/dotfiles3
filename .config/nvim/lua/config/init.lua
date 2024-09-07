vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.lazy-bootstrap")


-- Setup options between lazy bootstrap and lazy require
require("config.remap")
require("config.options")
require("config.autocommands")


--

require("config.lazy")
