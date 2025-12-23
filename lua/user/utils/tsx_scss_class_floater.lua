-- ~/.config/nvim/lua/utils/tsx_scss_class_floater.lua
-- Usage: map a key to require("utils.tsx_scss_class_floater").toggle()

local M = {}

-- state for toggle
M._win = nil
M._buf = nil
M._scss_path = nil

local function esc_pat(s)
	return s:gsub("(%W)", "%%%1")
end

-- Get word under cursor including '-' and '_' and digits
local function get_classname_under_cursor()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()

	-- nvim_win_get_cursor returns 0-indexed col, convert to 1-indexed
	col = col + 1

	-- clamp to line length
	if col > #line then
		col = #line
	end
	if col < 1 then
		col = 1
	end

	-- expand left to find start of classname
	local start_i = col
	while start_i > 1 do
		local ch = line:sub(start_i - 1, start_i - 1)
		if ch:match("[%w_%-]") then
			start_i = start_i - 1
		else
			break
		end
	end

	-- expand right to find end of classname
	local end_i = col
	while end_i <= #line do
		local ch = line:sub(end_i, end_i)
		if ch:match("[%w_%-]") then
			end_i = end_i + 1
		else
			break
		end
	end
	end_i = end_i - 1 -- went one past

	if end_i < start_i then
		-- fallback: try vim's expand
		local word = vim.fn.expand("<cword>")
		if word:sub(1, 1) == "." then
			word = word:sub(2)
		end
		return word
	end

	local word = line:sub(start_i, end_i)

	-- strip leading dot if present
	if word:sub(1, 1) == "." then
		word = word:sub(2)
	end

	return word
end

-- Find any .module.scss file in dir (returns path or nil)
local function find_scss_module_in_dir(dir)
	if dir == nil or dir == "" then
		return nil
	end
	local files = vim.fn.globpath(dir, "*.module.scss", false, true)
	if #files > 0 then
		table.sort(files)
		return files[1]
	end
	return nil
end

-- Create empty scss module file at given path if doesn't exist
local function ensure_scss_module_file(path)
	if vim.fn.filereadable(path) == 1 then
		return true
	end
	local dir = vim.fn.fnamemodify(path, ":h")
	vim.fn.mkdir(dir, "p")
	local f = io.open(path, "w")
	if not f then
		return false
	end
	f:write("@use 'core' as u;\n")
	f:close()
	return true
end

-- Search for selector in buffer lines
local function find_selector_range(bufnr, classname)
	-- Match .classname with word boundary (not followed by word char, - or _)
	local patt = "%." .. esc_pat(classname) .. "([^%w_%-])"
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	for i, l in ipairs(lines) do
		-- Also try simpler pattern if first doesn't match
		if
			l:match(patt)
			or l:match("%." .. esc_pat(classname) .. "%s*{")
			or l:match("%." .. esc_pat(classname) .. "$")
		then
			-- Find opening brace
			local start_line = i
			local found_open = false
			for j = i, #lines do
				if lines[j]:find("{", 1, true) then
					start_line = j
					found_open = true
					break
				end
			end

			if not found_open then
				return i, i
			end

			-- Find matching closing brace
			local brace_count = 0
			for k = start_line, #lines do
				local ln = lines[k]
				for ch in ln:gmatch(".") do
					if ch == "{" then
						brace_count = brace_count + 1
					end
					if ch == "}" then
						brace_count = brace_count - 1
					end
				end
				if brace_count == 0 then
					return start_line, k
				end
			end

			return start_line, #lines
		end
	end
	return nil, nil
end

-- Append a selector block for classname at EOF
local function append_selector_and_get_range(bufnr, classname)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local insert_at = #lines

	-- Add empty line before if file is not empty
	local insert_lines = {}
	if #lines > 0 and lines[#lines] ~= "" then
		table.insert(insert_lines, "")
	end

	table.insert(insert_lines, "." .. classname .. " {")
	table.insert(insert_lines, "  ")
	table.insert(insert_lines, "}")

	vim.api.nvim_buf_set_lines(bufnr, insert_at, insert_at, false, insert_lines)

	-- return start and end (1-index)
	local offset = (#lines > 0 and lines[#lines] ~= "") and 1 or 0
	local start_line = insert_at + 1 + offset
	local end_line = start_line + 2
	return start_line, end_line
end

-- Main action to ensure scss module file and selector exist
local function ensure_scss_module_and_selector(classname)
	local curpath = vim.api.nvim_buf_get_name(0)
	if curpath == "" then
		vim.notify("No file path", vim.log.levels.ERROR)
		return nil
	end

	local curdir = vim.fn.fnamemodify(curpath, ":h")
	local scss = find_scss_module_in_dir(curdir)

	-- If not found, call organize_component
	if not scss then
		local ok, mod = pcall(require, "utils.organize_component")
		if ok then
			pcall(mod.run)
			curpath = vim.api.nvim_buf_get_name(0)
			curdir = vim.fn.fnamemodify(curpath, ":h")
			scss = find_scss_module_in_dir(curdir)
		end

		-- If still not found, create scss module
		if not scss then
			local filename = vim.fn.fnamemodify(curpath, ":t")
			local base = filename:gsub("%.%w+$", "")
			scss = curdir .. "/" .. base .. ".module.scss"
			ensure_scss_module_file(scss)
		end
	end

	-- Load or create buffer for scss module file
	local bufnr = vim.fn.bufadd(scss)
	vim.fn.bufload(bufnr)

	-- Set buffer options correctly for editing
	vim.api.nvim_buf_set_option(bufnr, "filetype", "scss")
	vim.api.nvim_buf_set_option(bufnr, "buftype", "") -- normal file buffer
	vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
	vim.api.nvim_buf_set_option(bufnr, "buflisted", true)

	-- Search for selector
	local sline, eline = find_selector_range(bufnr, classname)

	if not sline then
		sline, eline = append_selector_and_get_range(bufnr, classname)
		-- Save the file after adding the selector
		vim.api.nvim_buf_call(bufnr, function()
			vim.cmd("silent! write")
		end)
	end

	return scss, bufnr, sline, eline
end

-- Open floating window with proper sizing and positioning
local function open_floating_for_range(bufnr, start_line, end_line)
	-- Get the content to display
	local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
	local block_lines = #lines

	-- Calculate max line length
	local max_len = 0
	for _, l in ipairs(lines) do
		if #l > max_len then
			max_len = #l
		end
	end

	-- Calculate window size (reasonable defaults)
	local win_w = math.min(math.max(100, max_len + 8), math.floor(vim.o.columns * 0.5))
	local win_h = math.min(math.max(40, block_lines + 4), math.floor(vim.o.lines * 0.4))

	-- Create floating window above cursor
	local opts = {
		relative = "cursor",
		width = win_w,
		height = win_h,
		col = 0,
		row = -1, -- Above cursor
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(bufnr, true, opts)
	M._win = win
	M._buf = bufnr

	-- Set window options
	vim.api.nvim_win_set_option(win, "wrap", false)
	vim.api.nvim_win_set_option(win, "cursorline", true)
	vim.api.nvim_win_set_option(win, "number", true)
	vim.api.nvim_win_set_option(win, "relativenumber", false)

	-- Position cursor at the selector start
	local top_line = math.max(1, start_line - 2)
	vim.api.nvim_win_set_cursor(win, { start_line, 2 })
	vim.fn.winrestview({ topline = top_line })

	-- Map Esc to close in this buffer
	vim.api.nvim_buf_set_keymap(
		bufnr,
		"n",
		"<Esc>",
		"<Cmd>lua require('utils.tsx_scss_class_floater').close_win()<CR>",
		{ nowait = true, noremap = true, silent = true }
	)

	-- Map q to close as well
	vim.api.nvim_buf_set_keymap(
		bufnr,
		"n",
		"q",
		"<Cmd>lua require('utils.tsx_scss_class_floater').close_win()<CR>",
		{ nowait = true, noremap = true, silent = true }
	)

	return win
end

function M.close_win()
	if M._win and vim.api.nvim_win_is_valid(M._win) then
		pcall(vim.api.nvim_win_close, M._win, true)
		M._win = nil
	end
end

-- Main toggle function
function M.toggle()
	-- If floating window is open, close it
	if M._win and vim.api.nvim_win_is_valid(M._win) then
		M.close_win()
		return
	end

	local filetype = vim.bo.filetype
	if not (filetype == "typescriptreact" or filetype == "typescript.tsx" or filetype:match("tsx")) then
		vim.notify("This mapping should be used in a TSX file (current: " .. filetype .. ")", vim.log.levels.ERROR)
		return
	end

	local classname = get_classname_under_cursor()
	if not classname or classname == "" then
		vim.notify("No class name found under cursor", vim.log.levels.ERROR)
		return
	end

	vim.notify("Looking for class: " .. classname, vim.log.levels.INFO)

	-- Ensure scss module file and selector exist
	local scss_path, scss_buf, start_line, end_line = ensure_scss_module_and_selector(classname)

	if not scss_path then
		vim.notify("Error ensuring scss module file and selector", vim.log.levels.ERROR)
		return
	end

	-- Open floating window
	open_floating_for_range(scss_buf, start_line, end_line)
end

return M
