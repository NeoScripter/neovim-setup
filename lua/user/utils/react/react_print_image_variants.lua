local M = {}

function M.run()
	vim.ui.input({
		prompt = "Enter the filename: ",
		default = "",
	}, function(filename)
		if filename == nil then
			vim.api.nvim_echo({
				{ "\n ✗ Process aborted", "ErrorMsg" },
			}, false, {})
			return
		end

		local utils = require("user.utils.images.utils")
		local string_utils = require("user.utils.string.utils")
		local root = utils.get_project_root()
		local matched_files = vim.fn.globpath(root, "**/*" .. filename .. "*", false, true)

		matched_files = vim.tbl_filter(function(file)
			return vim.fn.isdirectory(file) == 0
		end, matched_files)

		if next(matched_files) == nil then
			vim.api.nvim_echo({
				{ "\n ✗ Could not find any files with this name", "ErrorMsg" },
			}, false, {})
			return
		end

		local new_lines = {}

		for _, path in ipairs(matched_files) do
			path = path:gsub(root, "")
			path = "@" .. path:gsub("/public", "")
			local file_slug = path:match("([%w-]+%.%w+)$")
			if file_slug ~= nil then
				file_slug = file_slug:gsub("%.", "-")
			end
			file_slug = string_utils.kebab_to_pascal(file_slug)
			local import = "import " .. file_slug .. " from '" .. path .. "'"
			table.insert(new_lines, import)
		end

		local start_row = vim.api.nvim_win_get_cursor(0)[1]

		vim.api.nvim_buf_set_lines(
			vim.api.nvim_get_current_buf(),
			start_row - 1,
			start_row - 1 + #new_lines,
			false,
			new_lines
		)
	end)
end

return M
