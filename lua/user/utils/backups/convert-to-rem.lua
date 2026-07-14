local M = {}

function M.convert_to_rem()
	local line = vim.api.nvim_get_current_line()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	local j = col + 1

	-- scan left
	while j > 1 and line:sub(j - 1, j - 1):match("[%d.]") do
		j = j - 1
	end

	local i = col + 1
	while i <= #line and line:sub(i, i):match("[%d.]") do
		i = i + 1
	end

	local num = line:sub(j, i - 1)
	if num == "" then return end

	local value = math.floor(tonumber(num) / 2) / 2

	local new_line =
		line:sub(1, j - 1)
		.. value
		.. line:sub(i)

	vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
end


return M
