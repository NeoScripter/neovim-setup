local M = {}

local function get_class_under_cursor()
	local line = vim.api.nvim_get_current_line()

	return line:match("^%s*%.([^{%s]+)")
end

local function convert_class_to_scope(class)
	local bufnr = vim.api.nvim_get_current_buf()
	local current_line = vim.api.nvim_get_current_line()
	local found_class = current_line:match("^%s*%.([^{%s]+)")
	if found_class ~= class then
		return
	end

	local start_row = vim.api.nvim_win_get_cursor(0)[1] -- 1-indexed
	local open_col = current_line:find("{")
	if not open_col then
		return
	end

	vim.api.nvim_win_set_cursor(0, { start_row, open_col - 1 })
	local close_row = vim.fn.searchpairpos("{", "", "}", "nW")[1]
	if close_row == 0 then
		return
	end

	local body_lines = vim.api.nvim_buf_get_lines(bufnr, start_row, close_row - 1, false)

	local new_lines = {}
	table.insert(new_lines, "@scope (." .. class .. ") {")
	table.insert(new_lines, "  :scope {")
	for _, l in ipairs(body_lines) do
		table.insert(new_lines, "  " .. l)
	end
	table.insert(new_lines, "  }")
	table.insert(new_lines, "}")

	vim.api.nvim_buf_set_lines(bufnr, start_row - 1, close_row, false, new_lines)

	local end_row = start_row - 1 + #new_lines
	return end_row
end

function M.run()
	local class = get_class_under_cursor()

	if class == nil then
		return
	end

	convert_class_to_scope(class)
end

return M
