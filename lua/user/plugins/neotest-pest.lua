-- Plugin for Pest tests

return {
	"nvim-neotest/neotest",
	lazy = true,
	dependencies = {
		"nvim-neotest/nvim-nio",
		"olimorris/neotest-phpunit",
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-phpunit")({
					phpunit_cmd = function()
						return "vendor/bin/phpunit"
					end,
					root_files = { "composer.json", "phpunit.xml", ".gitignore" },
					filter_dirs = { ".git", "node_modules" },
					env = {},
					dap = nil,
				}),
			},
		})
	end,
}
