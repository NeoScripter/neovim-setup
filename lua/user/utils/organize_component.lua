-- ~/.config/nvim/lua/utils/organize_component.lua
local M = {}

local uv = vim.loop
local api = vim.api
local fn = vim.fn

local function path_join(...)
	local parts = { ... }
	return table.concat(parts, "/")
end

local function exists(path)
	local stat = uv.fs_stat(path)
	return stat ~= nil
end

local function is_dir(path)
	local stat = uv.fs_stat(path)
	return stat and stat.type == "directory"
end

local function create_scss_module_with_template(path)
	local f = io.open(path, "w")
	if not f then
		return false
	end
	f:write("@use 'core' as u;\n")
	f:close()
	return true
end

local function list_dir(path)
	local ok, res = pcall(fn.readdir, path)
	if ok and res then
		return res
	end
	-- fallback using luv
	local t = {}
	local req = uv.fs_scandir(path)
	if not req then
		return t
	end
	while true do
		local name, typ = uv.fs_scandir_next(req)
		if not name then
			break
		end
		table.insert(t, name)
	end
	return t
end

local function create_index_file(dir, comp_name)
	local index_path = path_join(dir, "index.ts")
	if exists(index_path) then
		return true -- Already exists
	end

	local f = io.open(index_path, "w")
	if not f then
		return false
	end

	local content = string.format("export * from './%s';\nexport { default } from './%s';\n", comp_name, comp_name)

	f:write(content)
	f:close()
	return true
end

-- find scss module files in a directory; prefer name match if provided
local function find_scss_module_in_dir(dir, pref_name)
	if not is_dir(dir) then
		return nil
	end
	local names = list_dir(dir)
	local first = nil
	for _, n in ipairs(names) do
		if n:match("%.module%.scss$") then
			if not first then
				first = n
			end
			if pref_name and n == (pref_name .. ".module.scss") then
				return n
			end
		end
	end
	return first
end

local function read_lines(path)
	if not exists(path) then
		return {}
	end
	return fn.readfile(path)
end

local function write_lines(path, lines)
	return fn.writefile(lines, path)
end

-- Check if import already exists in TSX file
local function import_exists_in_tsx(lines, import_path)
	local basename = fn.fnamemodify(import_path, ":t")

	for _, l in ipairs(lines) do
		-- Check for: import css from './Button.module.scss'
		if l:match("import%s+css%s+from") and l:match(basename:gsub("%.", "%%.")) then
			return true
		end
	end
	return false
end

-- Insert import at the top of the TSX file (after other imports)
local function insert_import_in_tsx(tsx_path, scss_module_path)
	local lines = read_lines(tsx_path)
	if #lines == 0 then
		return false
	end

	-- Get relative path from tsx to scss module
	local tsx_dir = fn.fnamemodify(tsx_path, ":h")
	local scss_basename = fn.fnamemodify(scss_module_path, ":t")
	local relative_import = "./" .. scss_basename

	-- Check if import already exists
	if import_exists_in_tsx(lines, relative_import) then
		return true -- Already exists, success
	end

	local import_line = "import css from '" .. relative_import .. "';"

	-- Find the position to insert (after last import statement)
	local insert_pos = 1
	local found_import = false

	for i, l in ipairs(lines) do
		if l:match("^import%s") or l:match("^%s*import%s") then
			insert_pos = i + 1
			found_import = true
		elseif found_import and not l:match("^%s*$") then
			-- Found first non-empty line after imports
			break
		end
	end

	-- If no imports found, insert at the beginning
	if not found_import then
		insert_pos = 1
	end

	table.insert(lines, insert_pos, import_line)

	local ok = write_lines(tsx_path, lines)
	return ok ~= 0
end

local function notify(msg, level)
	level = level or vim.log.levels.INFO
	vim.notify(msg, level)
end

function M.run()
	local buf = api.nvim_get_current_buf()
	local filepath = api.nvim_buf_get_name(buf)
	if filepath == "" then
		notify("No file in buffer", vim.log.levels.ERROR)
		return
	end

	if not filepath:match("%.tsx$") then
		notify("This command works only inside a .tsx file", vim.log.levels.ERROR)
		return
	end

	-- component name
	local filename = fn.fnamemodify(filepath, ":t")
	local comp_name = filename:gsub("%.tsx$", "")

	local file_dir = fn.fnamemodify(filepath, ":h") -- directory containing the tsx file

	-- 1) Check for any scss module file in the same directory (prefer component-named file)
	local scss_module_name = find_scss_module_in_dir(file_dir, comp_name)
	local scss_module_path

	if scss_module_name then
		-- use existing scss module in same dir
		scss_module_path = path_join(file_dir, scss_module_name)
		-- do NOT create folder or move file
	else
		-- 2) no scss module in same dir -> create folder (if not exists), move tsx into it, create scss module file
		local component_dir = path_join(file_dir, comp_name)
		if not is_dir(component_dir) then
			local ok = fn.mkdir(component_dir, "p")
			if ok == 0 then
				notify("Failed to create component dir: " .. component_dir, vim.log.levels.ERROR)
				return
			end
		end

		local new_tsx = path_join(component_dir, filename)
		-- if file not already inside that dir, move it
		if fn.fnamemodify(filepath, ":p") ~= fn.fnamemodify(new_tsx, ":p") then
			local ok, err = pcall(fn.rename, filepath, new_tsx)
			if not ok then
				notify("Failed to move TSX: " .. tostring(err), vim.log.levels.ERROR)
				return
			end
			-- open moved file
			vim.cmd("edit " .. fn.fnameescape(new_tsx))
			filepath = new_tsx
			file_dir = component_dir
			-- Update buffer reference after edit
			buf = api.nvim_get_current_buf()
		else
			-- already in place
			file_dir = component_dir
		end

		scss_module_path = path_join(file_dir, comp_name .. ".module.scss")
		if not exists(scss_module_path) then
			if not create_scss_module_with_template(scss_module_path) then
				notify("Failed to create scss module: " .. scss_module_path, vim.log.levels.ERROR)
				return
			end
		end

		-- Create index.ts file
		if not create_index_file(file_dir, comp_name) then
			notify("Failed to create index.ts file", vim.log.levels.WARN)
		end
	end

	-- now we have scss_module_path. normalize to absolute
	scss_module_path = fn.fnamemodify(scss_module_path, ":p")

	-- Get the current tsx file path (should be up to date now)
	local current_tsx = api.nvim_buf_get_name(buf)

	-- Insert import into TSX file immediately
	local scss_basename = fn.fnamemodify(scss_module_path, ":t")
	local relative_import = "./" .. scss_basename

	-- Read current buffer content
	local lines = api.nvim_buf_get_lines(buf, 0, -1, false)

	-- Check if import already exists
	local import_exists = false
	for _, l in ipairs(lines) do
		if l:match("import%s+css%s+from") and l:match(scss_basename:gsub("%.", "%%.")) then
			import_exists = true
			break
		end
	end

	if not import_exists then
		local import_line = "import css from '" .. relative_import .. "';"

		-- Find position after last import
		local insert_pos = 0
		local found_import = false

		for i, l in ipairs(lines) do
			if l:match("^import%s") or l:match("^%s*import%s") then
				insert_pos = i
				found_import = true
			elseif found_import and not l:match("^%s*$") then
				break
			end
		end

		-- Insert the import line
		api.nvim_buf_set_lines(buf, insert_pos, insert_pos, false, { import_line })

		-- Save the buffer
		vim.cmd("silent! write")
	end

	notify("Created SCSS module and added import: " .. fn.fnamemodify(scss_module_path, ":t"), vim.log.levels.INFO)
end

return M
