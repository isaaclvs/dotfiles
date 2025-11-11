-- Core
require("core.options")
require("core.keymaps")
require("core.lazy")

-- Plugins (vamos modularizar um por um)
require("plugins.treesitter")
require("plugins.telescope")
require("plugins.harpoon")
require("plugins.lsp")
require("plugins.cmp")

print("💻 Welcome to the Matrix... or Neovim. Same thing, right?")
