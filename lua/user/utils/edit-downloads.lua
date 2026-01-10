-- Module for editing Downloads directory with Oil plugin
local M = {}

-- Setup function to configure the module
function M.run()
	local previous_buffer = vim.api.nvim_get_current_buf()

	-- Open Oil in the Downloads directory
	require("oil").open("/home/ilya/Downloads/")

	-- Get the Oil buffer that was just opened
	local oil_buffer = vim.api.nvim_get_current_buf()

	-- Set up an autocmd to return to previous buffer when Oil is closed
	vim.api.nvim_create_autocmd("BufWinLeave", {
		buffer = oil_buffer,
		once = true,
		callback = function()
			-- Use vim.schedule to ensure proper timing
			vim.schedule(function()
				-- Check if previous buffer still exists and is valid
				if vim.api.nvim_buf_is_valid(previous_buffer) then
					vim.api.nvim_set_current_buf(previous_buffer)
				end
			end)
		end,
	})
end

return M
