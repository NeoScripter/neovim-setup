-- Syntax highlighting

return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()

		-- Highlighting
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				pcall(vim.treesitter.start)
			end,
		})

		-- Folds
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.wo[0][0].foldmethod = "expr"
			end,
		})

		-- Indentation (skip yaml, matching your old `disable = { "yaml" }`)
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				if vim.bo[args.buf].filetype ~= "yaml" then
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
}
