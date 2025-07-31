return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			php = { "pint" },
			javascript = { "prettierd", "prettier"},
			typescript = { "prettierd", "prettier"},
			typescriptreact = { "prettierd", "prettier" },
			css = { "prettierd", "prettier" },
			stylus = { "prettierd", "prettier" },
			scss = { "prettierd", "prettier" },
			sass = {},
			html = { "prettierd", "prettier" },
			vue = { "prettierd", "prettier" },
			lua = { "stylua" },
		},
		format_on_save = false,
		formatters = {
			prettier = {
				prepend_args = {
					"--tab-width",
					"4",
					"--print-width",
					"80",
					"--single-quote",
					"true",
					"--trailing-comma",
					"es5",
					"--html-whitespace-sensitivity",
					"css",
					"--prose-wrap",
					"always",
					"--jsx-single-quote",
					"false",
					"--bracket-same-line",
					"false",
					"--jsx-bracket-same-line",
					"false",
					"--single-attribute-per-line",
					"true",
				},
				command = "prettier",
				args = { "--stdin-filepath", "$FILENAME", "--config-precedence", "prefer-file" },
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
