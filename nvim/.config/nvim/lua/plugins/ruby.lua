return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Configuração dinâmica baseada no projeto
      local cwd = vim.fn.getcwd()
      
      opts.servers = opts.servers or {}
      
      if cwd:match("nevoa/saude%-publica") then
        -- Projeto legado: usar Solargraph
        opts.servers.solargraph = {
          autostart = true,
        }
        opts.servers.ruby_lsp = {
          autostart = false,
        }
      else
        -- Outros projetos: usar Ruby LSP
        opts.servers.solargraph = {
          autostart = false,
        }
        opts.servers.ruby_lsp = {
          autostart = true,
        }
      end
      
      return opts
    end,
  },
}