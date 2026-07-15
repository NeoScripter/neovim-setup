local M = {}

local function open_css_file(file)
	vim.cmd("e " .. file)
end

local function normalize_filename(name)
	name = vim.fn.fnamemodify(name, ":t")
	name = string.gsub(name, "%w%..+", "")
	name = string.gsub(name, "[_%-.,]", "")
	name = string.lower(name)

	return name
end

local function filenames_match(s1, s2)
	s1, s2 = normalize_filename(s1), normalize_filename(s2)
	if string.len(s1) < string.len(s2) then
		s1, s2 = s2, s1
	end

	return string.find(normalize_filename(s1), normalize_filename(s2), 1, true) == 1
end

local function insert_class_block(bufnr, insert_at, classname)
	local insert_lines = {}
	local prev_line = ""
	if insert_at > 0 then
		prev_line = vim.api.nvim_buf_get_lines(bufnr, insert_at - 1, insert_at, false)[1] or ""
	end
	if prev_line ~= "" then
		table.insert(insert_lines, "")
	end
	table.insert(insert_lines, "." .. classname .. " {")
	table.insert(insert_lines, "  ")
	table.insert(insert_lines, "}")
	vim.api.nvim_buf_set_lines(bufnr, insert_at, insert_at, false, insert_lines)
end

local function find_css_file()
	local curpath = vim.api.nvim_buf_get_name(0)

	if curpath == "" then
		echo_error("Path to the current file not found")
		return false
	end

	local current_dir = vim.fn.fnamemodify(curpath, ":h")
	local file_ext = vim.fn.fnamemodify(curpath, ":e")

	if file_ext == "css" or file_ext == "scss" then
		vim.api.nvim_input("<C-^>")
		return false
	end

	if current_dir == nil or current_dir == "" then
		echo_error("Could not find current directory")
		return false
	end

	local files = vim.fn.globpath(current_dir, "**/*.{,s}css", true, true)
	local current_file = vim.fn.fnamemodify(curpath, ":t")

	for _, file in ipairs(files) do
		if vim.fn.filereadable(file) == 1 and filenames_match(file, current_file) then
			open_css_file(file)
			return true
		end
	end

	local root = vim.fs.root(0, { { ".git", "package.json", "composer.json", "vite.config", "node_modules" }, ".git" })
	files = vim.fn.globpath(root, "**/*.{,s}css", true, true)

	table.sort(files, function(a, b)
		return string.len(a) < string.len(b)
	end)

	if next(files) == nil then
		echo_error("No CSS or SCSS files were found in the project")
		return false
	end

	for _, file in ipairs(files) do
		local filename = vim.fn.fnamemodify(file, ":t")

		if (filename:match("style") or filename:match("app")) and vim.fn.filereadable(file) == 1 then
			open_css_file(file)
			return true
		end
	end

	for _, file in ipairs(files) do
		if vim.fn.filereadable(file) == 1 then
			open_css_file(file)
			return true
		end
	end

	echo_error("Could not read any of the CSS or SCSS files")
	return false
end

local function get_class_under_cursor()
	local _, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()

	col = col + 1

	local best = nil

	for _, quote in ipairs({ '"', "'" }) do
		local pattern = quote .. "([^" .. quote .. "]*)" .. quote
		local search_start = 1
		while true do
			local s, e, capture = line:find(pattern, search_start)
			if not s then
				break
			end

			if col >= s and col <= e then
				best = capture
				break
			end
			search_start = s + 1
		end
		if best then
			break
		end
	end

	return best
end

local function append_class(classname)
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	insert_class_block(bufnr, #lines, classname)
end

local function get_classname()
	local class = get_class_under_cursor()

	if class ~= nil then
		return class
	end

	local line = vim.api.nvim_get_current_line()

	local patterns = {
		[[css%.([%w%-]+)]],
		[[class%s*=%s*"([^"]+)"]],
		[[class%s*=%s*'([^']+)']],
		[[className%s*=%s*"([^"]+)"]],
		[[className%s*=%s*'([^']+)']],
		[[classname%s*=%s*"([^"]+)"]],
		[[classname%s*=%s*'([^']+)']],
	}

	for _, p in ipairs(patterns) do
		local m = line:match(p)
		if m then
			return m
		end
	end

	return nil
end

local function find_class_parent()
	vim.cmd("normal! ^")
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	while row > 1 do
		vim.api.nvim_win_set_cursor(0, { row - 1, col })
		vim.cmd("normal! ^")
		local new_row, new_col = unpack(vim.api.nvim_win_get_cursor(0))
		row = new_row
		local line = vim.api.nvim_get_current_line()
		if line:match("^%s*$") then
			goto continue
		end
		if new_col > col then
			return nil
		elseif new_col < col then
			local class = get_classname()
			if class ~= nil then
				return class
			end
		end
		::continue::
	end
	return nil
end

function M.run()
	local class = get_classname()

	if class == nil then
		echo_error("No CSS class found")
		return
	end

	local parent = find_class_parent()

	if find_css_file() == false then
		return nil
	end

	if class == nil then
		return nil
	end

	if vim.fn.search(class, "nwc") <= 0 then
		if parent ~= nil then
			local row = vim.fn.search("@scope (\\." .. parent .. ")", "wc")
			if row == 0 then
				append_class(class)
			else
				local bufnr = vim.api.nvim_get_current_buf()
				local scope_end = vim.fn.search("}", "n")

				if scope_end == 0 then
					scope_end = row
				end
				insert_class_block(bufnr, scope_end, class)
			end
		else
			append_class(class)
		end
		vim.cmd("silent! write")
	end

	local found = vim.fn.search("\\." .. class, "w")
	if found <= 0 then
		return nil
	end
end

return M
