return {
	"EdenEast/nightfox.nvim",
	lazy = false,
	priority = 1000, -- load before others
	config = function()
		require("nightfox").setup({
			options = {
				transparent = false,
				terminal_colors = true,
				dim_inactive = false,
				styles = {
					comments = "italic",
					keywords = "bold",
					types = "italic,bold",
				},
			},
		})

		-- Load your preferred theme from the Nightfox family
		vim.cmd("colorscheme duskfox")
	end,
}
