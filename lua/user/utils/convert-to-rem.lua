local M = {}

function M.convert_to_rem()
	local line = vim.api.nvim_get_current_line()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	local i = col + 1

	-- scan left while digit or dot
	while i < #line do
		local c = line:sub(i, i)
		if not c:match("[%d.]") then
			break
		end
		i = i + 1
	end
	local before = line:sub(1, i + 1)
	local s, e, num = before:find("(%d+%.?%d*)$")

	if not num then
		return
	end

	local value = math.floor(tonumber(num) / 2) / 2

	local new_line = line:sub(1, s - 1) .. value .. line:sub(e + 1)

	vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
end

return M
