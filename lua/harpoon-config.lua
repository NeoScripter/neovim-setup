local harpoon = require('harpoon')
harpoon.setup()

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
local harpoon = require("harpoon")

-- Add current file to Harpoon list
keymap("n", "<leader>a", function() harpoon:list():add() end, opts)

-- Toggle Harpoon quick menu
keymap("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, opts)

-- Navigate to files 1–4 in list
keymap("n", "<leader>1", function() harpoon:list():select(1) end, opts)
keymap("n", "<leader>2", function() harpoon:list():select(2) end, opts)
keymap("n", "<leader>3", function() harpoon:list():select(3) end, opts)
keymap("n", "<leader>4", function() harpoon:list():select(4) end, opts)
keymap("n", "<leader>5", function() harpoon:list():select(5) end, opts)
keymap("n", "<leader>6", function() harpoon:list():select(6) end, opts)
