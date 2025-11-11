local map = vim.keymap.set

-- Comandos básicos
map("n", "<leader>w", ":w<CR>", { silent = true })
map("n", "<leader>q", ":q<CR>", { silent = true })
map("n", "<leader>h", ":nohlsearch<CR>", { silent = true })

-- Abre a documentação do init.lua
map("n", "<leader>d", function()
  vim.cmd("tabnew ~/.config/nvim/docs/keybinds.md")
end, { desc = "Abrir keybinds" })
