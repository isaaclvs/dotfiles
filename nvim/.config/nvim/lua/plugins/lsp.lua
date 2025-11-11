local map = vim.keymap.set

-- -------------------------------
--  LSP CONDICIONAL (Solargraph ↔ Ruby LSP)
-- -------------------------------
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local current_dir = vim.fn.getcwd()
local workspace_dir = "/home/isaac/workspace/crescer/"

-- Função para verificar se um caminho está dentro de outro
local function is_subdir(path, base)
  return string.sub(path, 1, string.len(base)) == base
end

if is_subdir(current_dir, workspace_dir) then
  -- Usa Solargraph dentro de ~/workspace/crescer/
  vim.lsp.config["solargraph"] = {
    capabilities = capabilities,
    on_attach = function(_, bufnr)
      local bufopts = { buffer = bufnr }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
      vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, bufopts)
      vim.keymap.set("n", "gl", vim.diagnostic.open_float, bufopts)
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, bufopts)
      vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, bufopts)
    end,
  }

  vim.lsp.enable("solargraph")
else
  -- Usa Ruby LSP como padrão
  vim.lsp.config["ruby_lsp"] = {
    capabilities = capabilities,
  }

  vim.lsp.enable("ruby_lsp")
end

