-- Automatically add closing brackets, quotes, etc.

return {
	"nvim-mini/mini.pairs",
	version = false,
	enabled = false,
	config = function()
		require("mini.pairs").setup()
	end,
}
