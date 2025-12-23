-- ~/.config/nvim/lua/user/utils/class_floater_wrapper.lua
local M = {}

-- Track which floater is currently active
M._active_floater = nil

function M.toggle()
	-- If a floater is already open, close it using the active floater
	local html_floater = require("user.utils.html_css_class_floater")
	local tsx_floater = require("user.utils.tsx_scss_class_floater")

	-- Check if either floater has an open window
	if html_floater._win and vim.api.nvim_win_is_valid(html_floater._win) then
		html_floater.close_win()
		M._active_floater = nil
		return
	end

	if tsx_floater._win and vim.api.nvim_win_is_valid(tsx_floater._win) then
		tsx_floater.close_win()
		M._active_floater = nil
		return
	end

	-- No floater is open, so open the appropriate one based on filetype
	local filetype = vim.bo.filetype
	local filename = vim.fn.expand("%:t")
	local is_blade = filename:match("%.blade%.php$") ~= nil

	-- Check if HTML or Blade file
	if filetype == "html" or is_blade or filetype == "blade" then
		html_floater.toggle()
		M._active_floater = "html"
	-- Check if TSX/React file
	elseif filetype == "typescriptreact" or filetype == "typescript.tsx" or filetype:match("tsx") then
		tsx_floater.toggle()
		M._active_floater = "tsx"
	end
end

return M
