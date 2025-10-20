return {
  "lervag/wiki.vim",
  lazy = false, -- Carregar imediatamente para funcionar com arquivos .md
  ft = { "markdown" }, -- Ativar apenas em arquivos markdown
  config = function()
    vim.g.wiki_root = "~/Documents/Obsidian"

    -- Configurações básicas
    vim.g.wiki_filetypes = { "md" }
    vim.g.wiki_link_extension = ".md"
    vim.g.wiki_link_target_type = "md"

    -- Templates para novas páginas
    vim.g.wiki_template_default = {
      "# %title",
      "",
      "## Contexto",
      "",
      "",
      "## Notas",
      "",
      "",
      "## Links",
      "- ",
      "",
      "---",
      "*Criado: %date*"
    }

    -- Template para notas diárias (usado pelo scratchpad)
    vim.g.wiki_template_daily = {
      "# %date - %title",
      "",
      "## 📝 Notas do Dia",
      "",
      "",
      "## 🔗 Links",
      "",
      "",
      "## 💡 Ideias",
      "",
      "",
      "---",
      "*Criado: %date %time*"
    }

    -- Configuração de links
    vim.g.wiki_link_toggle_on_follow = 0 -- Não alternar ao seguir link
    vim.g.wiki_completion_enabled = 1    -- Autocompletar links

    -- Mapeamentos de teclado
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        local opts = { buffer = true, silent = true }

        -- Navegação
        vim.keymap.set("n", "<leader>ww", "<cmd>WikiIndex<cr>", opts) -- Ir para index
        vim.keymap.set("n", "<leader>wt", "<cmd>WikiOpen<cr>", opts)  -- Abrir/criar página
        vim.keymap.set("n", "<cr>", "<cmd>WikiLinkFollowSplit<cr>", opts) -- Seguir link (split)
        vim.keymap.set("n", "<c-cr>", "<cmd>WikiLinkFollow<cr>", opts) -- Seguir link (mesmo buffer)
        vim.keymap.set("n", "<bs>", "<cmd>WikiLinkReturn<cr>", opts)   -- Voltar

        -- Criação de links
        vim.keymap.set("v", "<leader>wl", "<cmd>WikiLinkToggleVisual<cr>", opts) -- Criar link visual
        vim.keymap.set("n", "<leader>wl", "<cmd>WikiLinkToggleOperator<cr>", opts) -- Criar link normal

        -- Busca e navegação
        vim.keymap.set("n", "<leader>ws", "<cmd>WikiFzfPages<cr>", opts)  -- Buscar páginas
        vim.keymap.set("n", "<leader>wg", "<cmd>WikiFzfTags<cr>", opts)   -- Buscar tags

        -- Journal/Daily notes  
        vim.keymap.set("n", "<leader>wd", function()
          -- Criar/abrir nota diária no formato que o scratchpad usa
          local date = os.date("%Y-%m-%d")
          local file = vim.g.wiki_root .. "/Notes/" .. date .. ".md"
          vim.cmd("edit " .. file)
        end, opts)

        -- Zettelkasten - criar nova nota com timestamp
        vim.keymap.set("n", "<leader>wz", function()
          local timestamp = os.date("%Y-%m-%d_%H-%M-%S")
          local file = vim.g.wiki_root .. "/Notes/" .. timestamp .. ".md"
          vim.cmd("edit " .. file)
        end, opts)
      end,
    })

    -- Autocomandos úteis
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*/Documents/Obsidian/*.md",
      callback = function()
        -- Ativar spell check para notas
        vim.opt_local.spell = true
        vim.opt_local.spelllang = "pt_br,en_us"

        -- Line wrap para melhor leitura
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
      end,
    })
  end,
}

