local M = {}

function M.run()
	local item = vim.v.completed_item
	if not item or vim.tbl_isempty(item) then
		return
	end
	if item.word == nil or item.word == "" then
		return
	end
	if item.word:sub(-2, -1) ~= "()" then
		return
	end

	-- Wait 100ms before checking
	vim.defer_fn(function()
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		local line = vim.api.nvim_get_current_line()

		-- Check character under cursor (col is 0-based, string is 1-based)
		local char_under = line:sub(col + 1, col + 1)

		if char_under == "(" then
			-- Check if next char is ')'
			local next_char = line:sub(col + 2, col + 2)
			if next_char == ")" then
				-- Remove '()' starting at cursor position
				local new_line = line:sub(1, col) .. line:sub(col + 3)
				vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
				vim.api.nvim_win_set_cursor(0, { row, col })
			end
		elseif char_under == ")" then
			-- Check if previous char is '('
			local prev_char = line:sub(col, col)
			if prev_char == "(" then
				-- Remove '()' starting before cursor
				local new_line = line:sub(1, col - 1) .. line:sub(col + 2)
				vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
				vim.api.nvim_win_set_cursor(0, { row, col - 1 })
			end
		end
	end, 100)
end

return M
