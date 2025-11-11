require("nvim-treesitter.configs").setup({
  -- linguagens que serão instaladas
  ensure_installed = {
    "lua", "ruby", "vim", "vimdoc", "query", "bash", "markdown", "markdown_inline"
  },

  sync_install = false,     -- instala de forma assíncrona
  auto_install = true,      -- instala parsers ausentes ao abrir o arquivo

  highlight = {
    enable = true,          -- ativa o highlight via treesitter
    additional_vim_regex_highlighting = false, -- usa só treesitter
  },
})

