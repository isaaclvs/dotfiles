local map = vim.keymap.set
local telescope = require("telescope")
local builtin = require("telescope.builtin")

-- Configuração principal do Telescope
telescope.setup({
  defaults = {
    -- Filtros de performance
    file_ignore_patterns = { "node_modules", ".git", "vendor", "tmp" },

    -- Preview
    preview = {
      hide_on_startup = false,
    },

    -- Layout
    layout_strategy = "horizontal",
    layout_config = {
      prompt_position = "top",
      preview_width = 0.55,
      width = 0.85,
      height = 0.85,
      mirror = false,
    },

    -- Highlight do matching
    sorting_strategy = "ascending",
    color_devicons = true,
  },

  pickers = {
    find_files = {
      hidden = true,   -- mostra arquivos ocultos
      previewer = true, -- garante preview
    },
    buffers = {
      previewer = false, -- preview de buffers normalmente não é necessário
    },
  },
})

-- Fuzzy finder nativo (melhor performance)
telescope.load_extension("fzf")

-- Keymaps
map("n", "<leader>f", function()
  builtin.find_files({ previewer = true, hidden = true })
end, { desc = "Find files with preview" })

map("n", "<leader>g", builtin.live_grep, { desc = "Live grep project" })
map("n", "<leader>b", builtin.buffers, { desc = "List buffers" })
map("n", "<leader>hh", builtin.help_tags, { desc = "Help tags" })
map("n", "<leader>qf", builtin.quickfix, { desc = "Quickfix list" })

