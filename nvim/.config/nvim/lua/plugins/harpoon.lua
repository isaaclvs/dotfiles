local map = vim.keymap.set

-- Harpoon
local harpoon = require("harpoon")

-- Inicialização obrigatória
harpoon:setup()

-- Adiciona o arquivo atual
vim.keymap.set("n", "<leader>a", function()
  harpoon:list():add()
end, { desc = "Add current file to Harpoon" })

-- Remover arquivo
vim.keymap.set("n", "<leader>ra", function()
  require("harpoon"):list():remove()
  print("Arquivo atual removido do Harpoon")
end, { desc = "Remove current file from Harpoon" })

-- Limpar Harpoon
vim.keymap.set("n", "<leader>rc", function()
  require("harpoon"):list():clear()
  print("Todos os arquivos removidos do Harpoon")
end, { desc = "Clear all Harpoon marks" })

-- Abre o menu rápido
vim.keymap.set("n", "<leader>e", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Open Harpoon Menu" })

-- Navegação rápida entre arquivos marcados
vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Go to file 1" })
vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Go to file 2" })
vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Go to file 3" })
vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Go to file 4" })

-- Alternar entre arquivos anteriores e próximos
vim.keymap.set("n", "<leader>p", function() harpoon:list():prev() end, { desc = "Previous Harpoon file" })
vim.keymap.set("n", "<leader>n", function() harpoon:list():next() end, { desc = "Next Harpoon file" })

