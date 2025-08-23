-- Start a live server inside the browser for HTML files

return {
	"barrett-ruth/live-server.nvim",
	build = "npm add -g live-server",
	cmd = { "LiveServerStart", "LiveServerStop" },
	config = function()
		require("live-server").setup({
			args = { "--quiet" }, -- optional: prevent console logs
			open_browser = true, -- or false if you don’t want it auto-opened
			port = 8080, -- customize if needed
		})
	end,
}
