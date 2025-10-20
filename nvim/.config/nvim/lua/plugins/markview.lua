return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  priority = 49,

  config = function()
    require("markview").setup({
      preview = {
        -- Ativar apenas para arquivos markdown no diretório Obsidian
        filetypes = { "md", "markdown" },
        modes = { "n", "no", "c" }, -- Normal, operator-pending, command

        -- Hybrid mode: editar e visualizar ao mesmo tempo
        hybrid_modes = { "i" }, -- Insert mode mostra código

        -- Configuração para melhor performance
        debounce = 50,
      },

      -- Configurar para funcionar bem com suas notas
      markdown = {
        enable = true,
        headings = {
          enable = true,
          shift_width = 0, -- Sem indentação extra
        },
        list_items = {
          enable = true,
        },
        block_quotes = {
          enable = true,
        },
        code_blocks = {
          enable = true,
        },
        tables = {
          enable = true,
        },
      },

      -- Links do tipo wiki [[link]]
      markdown_inline = {
        enable = true,
        internal_links = {
          enable = true,
        },
        hyperlinks = {
          enable = true,
        },
        images = {
          enable = true,
        },
      },
    })

    -- Ativar automaticamente apenas no diretório Obsidian
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*/Documents/Obsidian/*.md",
      callback = function()
        vim.cmd("Markview enable")
      end,
    })

    -- Keybindings úteis
    vim.keymap.set("n", "<leader>mv", "<cmd>Markview toggle<cr>", { desc = "Toggle Markview" })
    vim.keymap.set("n", "<leader>mh", "<cmd>Markview hybridToggle<cr>", { desc = "Toggle Hybrid Mode" })
  end,
}
