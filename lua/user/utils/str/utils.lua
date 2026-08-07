local M = {}

function M.snake_to_camel(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end

	str = str:gsub("%_%l", string.upper)
	str = str:gsub("[-_]", "")
	return str
end

function M.camel_to_snake(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end

	return str:gsub("%u", function(char)
		return "_" .. string.lower(char)
	end)
end

function M.camel_to_kebab(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end

	return str:gsub("%u", function(char)
		return "-" .. string.lower(char)
	end)
end

function M.kebab_to_camel(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end

	str = str:gsub("%-%l", string.upper)
	str = str:gsub("[-_]", "")
	return str
end

function M.pascal_to_kebab(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end

	str = str:gsub("^%u", string.lower)

	return str:gsub("%u", function(char)
		return "-" .. string.lower(char)
	end)
end

function M.pascal_to_snake(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end

	str = str:gsub("^%u", string.lower)

	return str:gsub("%u", function(char)
		return "_" .. string.lower(char)
	end)
end

function M.kebab_to_pascal(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end

	str = str:gsub("^%l", string.upper)

	str = str:gsub("%-%l", string.upper)
	return str:gsub("[-_]", "")
end

function M.insert_import(str)
	local found = vim.fn.search(str, "wn")
	if found > 0 then
		vim.cmd([[normal! <C-o>]])
		return
	end

	vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, 0, false, { str })
end

--- Return the visually selected text as an array with an entry for each line
---
--- @return string[]|nil lines The selected text as an array of lines.

function M.get_visual_selection_text()
	local _, srow, scol = unpack(vim.fn.getpos("v"))
	local _, erow, ecol = unpack(vim.fn.getpos("."))

	-- visual line mode
	if vim.fn.mode() == "V" then
		if srow > erow then
			return vim.api.nvim_buf_get_lines(0, erow - 1, srow, true)
		else
			return vim.api.nvim_buf_get_lines(0, srow - 1, erow, true)
		end
	end

	-- regular visual mode
	if vim.fn.mode() == "v" then
		if srow < erow or (srow == erow and scol <= ecol) then
			return vim.api.nvim_buf_get_text(0, srow - 1, scol - 1, erow - 1, ecol, {})
		else
			return vim.api.nvim_buf_get_text(0, erow - 1, ecol - 1, srow - 1, scol, {})
		end
	end

	-- visual block mode
	if vim.fn.mode() == "\22" then
		local lines = {}
		if srow > erow then
			srow, erow = erow, srow
		end
		if scol > ecol then
			scol, ecol = ecol, scol
		end
		for i = srow, erow do
			table.insert(
				lines,
				vim.api.nvim_buf_get_text(0, i - 1, math.min(scol - 1, ecol), i - 1, math.max(scol - 1, ecol), {})[1]
			)
		end
		return lines
	end
end

return M
