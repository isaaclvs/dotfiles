return {
  -- -- Tokyonight
  -- {
  --   "folke/tokyonight.nvim",
  --   priority = 1000,
  --   opts = {
  --     style = "night", -- Define a variante night
  --     transparent = true, -- mude para true se quiser fundo transparente
  --     terminal_colors = true,
  --     styles = {
  --       comments = { italic = true },
  --       keywords = { italic = true },
  --       functions = {},
  --       variables = {},
  --     },
  --   },
  -- },
  --
  -- -- Night Owl theme (versão mais moderna)
  -- {
  --   "oxfist/night-owl.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("night-owl").setup()
  --   end,
  -- },

  -- Onedark
  -- {
  --   "navarasu/onedark.nvim",
  --   priority = 1000,
  --   opts = {
  --     style = "dark", -- Variantes: dark, darker, cool, deep, warm, warmer
  --   },
  -- },

  -- Kanagawa
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    opts = {
      compile = false,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false,
    },
  },

  -- Nightfox
  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    opts = {
      options = {
        transparent = false,
        terminal_colors = true,
        dim_inactive = false,
        module_default = true,
        styles = {
          comments = "italic",
          keywords = "bold",
        },
      },
    },
  },

  -- Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- Variantes: latte, frappe, macchiato, mocha
      transparent_background = false,
      term_colors = true,
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        keywords = { "italic" },
      },
    },
  },

  -- Configure como tema ativo
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nightfox",
    },
  },
}
