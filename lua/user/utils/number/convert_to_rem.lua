local M = {}

function M.run()
	local line = vim.api.nvim_get_current_line()
	local _, col = unpack(vim.api.nvim_win_get_cursor(0))

	while col > 1 and line:sub(col - 1, col - 1):match("[%d.]") do
		col = col - 1
	end

	local s, e, num = line:find("([%d.]+)", col)

	if s == nil or e == nil then
		return
	end

    num = tonumber(num)

	if num == nil then
		return
	end

	local value = math.floor((num / 16) * 10) / 10

	local new_line = line:sub(1, s - 1) .. value .. line:sub(e)
    vim.api.nvim_set_current_line(new_line)
end

return M
