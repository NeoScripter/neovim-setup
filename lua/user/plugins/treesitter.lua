-- Syntax highlighting

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})
	end,
	init = function()
		local ensure_installed = {
			"lua",
			"vim",
			"vimdoc",
			"query",
			"json",
			"jsonc",
			"yaml",
			"markdown",
			"markdown_inline",
			"typescript",
			"tsx",
			"javascript",
			"jsx",
			"php",
		}

		-- Only install parsers that aren't already installed,
		-- so this doesn't reinstall everything on every startup
		local already_installed = require("nvim-treesitter.config").get_installed()
		local to_install = vim.iter(ensure_installed)
			:filter(function(parser)
				return not vim.tbl_contains(already_installed, parser)
			end)
			:totable()

		if #to_install > 0 then
			require("nvim-treesitter").install(to_install)
		end

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
