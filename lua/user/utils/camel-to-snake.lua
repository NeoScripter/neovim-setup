local M = {}

function M.camel_to_snake()
	local line = vim.api.nvim_get_current_line()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	local j = col + 1

	-- scan left
	while j > 1 and line:sub(j - 1, j - 1):match("[%S]") do
		j = j - 1
	end

	local i = col + 1
	while i <= #line and line:sub(i, i):match("[%S]") do
		i = i + 1
	end

	local variable = line:sub(j, i - 1)
	if variable == "" then
		return
	end

	local value = string.gsub(variable, "%u", function(match)
		return "_" .. string.lower(match)
	end)

	value = string.gsub(value, "^_", "")

	local new_line = line:sub(1, j - 1) .. value .. line:sub(i)

	vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
end

return M
