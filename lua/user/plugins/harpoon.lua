return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		local keymap = vim.keymap.set
		local opts = { noremap = true, silent = true }

		-- Add current file to Harpoon list
		keymap("n", "<leader>a", function()
			harpoon:list():add()
		end, opts)

		-- Toggle Harpoon quick menu
		keymap("n", "<C-e>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, opts)

		-- Navigate to files 1–6 in list
		for i = 1, 6 do
			keymap("n", "<leader>" .. i, function()
				harpoon:list():select(i)
			end, opts)
		end
	end,
}
