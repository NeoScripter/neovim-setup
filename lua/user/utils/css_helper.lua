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

local function find_css_file()
	local curpath = vim.api.nvim_buf_get_name(0)

	if curpath == "" then
		return false
	end

	local current_dir = vim.fn.fnamemodify(curpath, ":h")
	local file_ext = vim.fn.fnamemodify(curpath, ":e")

	if file_ext == "css" or file_ext == "scss" then
		vim.api.nvim_input("<C-^>")
		return false
	end

	if current_dir == nil or current_dir == "" then
		vim.notify("Could not find current directory", vim.log.levels.INFO)
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

	return false
end

local function get_classname()
	local line = vim.api.nvim_get_current_line()

	local patterns = {
		[[class%s*=.*css%.([%w%-]+)]],
		[[classname%s*=.*css%.([%w%-]+)]],
		[[className%s*=.*css%.([%w%-]+)]],
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
end

function M.run()
	if find_css_file() == false then
		return nil
	end

	local class = get_classname()
	print(class)

	if class ~= nil and vim.fn.search(class, "nw") > 0 then
		vim.api.nvim_input("/" .. class .. "<CR>")
	end
end

return M
