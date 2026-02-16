return {
	"mfussenegger/nvim-lint",
	config = function()
		require("lint").linters_by_ft = {
			javascript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescript = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			php = { "phpstan" },
			html = { "djlint" }, -- or another linter if preferred
			vue = { "eslint_d" }, -- works if ESLint is configured for Vue
			css = { "stylelint" },
			scss = { "stylelint" },
		}

		-- Configure diagnostic display
		vim.diagnostic.config({
			virtual_text = {
				prefix = "●",
				spacing = 4,
				source = "if_many", -- Show source (phpstan, eslint, etc.) if multiple
			},
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			float = {
				source = "always",
				border = "rounded",
				header = "",
				prefix = "",
			},
		})
		vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
			callback = function()
				require("lint").try_lint()
			end,
		})
	end,
}
