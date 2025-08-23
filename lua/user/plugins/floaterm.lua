--- Floating terminal

return {
	"voldikss/vim-floaterm",
	keys = {
		{ "<leader>tt", ":FloatermToggle<CR>" },
		{ "<leader>tt", "<Esc>:FloatermToggle<CR>", mode = "i" },
		{ "<leader>tt", "<C-\\><C-n>:FloatermToggle<CR>", mode = "t" },
		{ "<Esc>", "<C-\\><C-n>", mode = "t" },
		{ "<leader>td", "<C-\\><C-n>:bd!<CR>", mode = "t" },
	},
	cmd = { "FloatermToggle" },
	init = function()
		vim.g.floaterm_width = 0.8
		vim.g.floaterm_height = 0.8
        vim.g.floaterm_shell = "/usr/bin/zsh"
	end,
}
