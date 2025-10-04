return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({
					async = true,
					lsp_format = "fallback",
				})
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},
	opts = {
		notify_on_error = true,
		format_on_save = false,
		formatters = {
			pint = {
				command = "pint.bat",
				args = { "$FILENAME" },
				stdin = false,
			},
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
		formatters_by_ft = {
			lua = { "stylua" },
			php = { "pint" },
			blade = { "blade-formatter" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			javascriptreact = { "prettier" },
			css = { "prettier" },
			stylus = { "prettier" },
			scss = { "prettier" },
			sass = { "prettier" },
			html = { "prettier" },
			vue = { "prettier" },
			json = { "prettier" },
			-- Conform can also run multiple formatters sequentially
			-- python = { "isort", "black" },
			--
			-- You can use 'stop_after_first' to run the first available formatter from the list
			-- javascript = { "prettierd", "prettier", stop_after_first = true },
		},
	},
}
