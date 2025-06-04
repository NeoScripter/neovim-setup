return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			php = { "pint" },
			javascript = { "eslint_d", stop_after_first = true },
			typescript = { "eslint_d", stop_after_first = true },
			typescriptreact = { "eslint_d", stop_after_first = true },
			css = { "prettierd", "prettier" },
			scss = { "prettierd", "prettier" },
			html = { "prettierd", "prettier" },
			vue = { "prettierd", "prettier" },
			lua = { "stylua" },
		},
		format_on_save = false,
		formatters = {
			prettierd = {
				prepend_args = { "--tab-width", "4" },
			},
			prettier = {
				prepend_args = { "--tab-width", "4" },
			},
			stylua = {
				prepend_args = { "--indent-width", "4" },
			},
		},
	},
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			mode = { "n", "v" },
			desc = "Format buffer or selection",
		},
	},
}
