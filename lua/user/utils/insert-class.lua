local M = {}

function M.insert_class()
	local line = vim.api.nvim_get_current_line()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	local i = col + 1
	local j = col + 1

	-- scan left
	while i > 1 and line:sub(i - 1, i - 1):match("%w") do
		i = i - 1
	end

	-- scan right
	while j <= #line and line:sub(j, j):match("%w") do
		j = j + 1
	end

	local name = line:sub(i, j - 1)
	if name == "" then
		return
	end

	local value = "class={css." .. name .. "}"

	local new_line = line:sub(1, i - 1) .. value .. line:sub(j)

	vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
end


return M
