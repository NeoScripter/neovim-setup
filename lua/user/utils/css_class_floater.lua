-- ~/.config/nvim/lua/user/utils/css_class_floater.lua
-- Usage:
--   require("user.utils.css_class_floater").toggle()          -- classname-under-cursor mode
--   require("user.utils.css_class_floater").toggle_element()  -- leader+w: tag-aware mode

local M = {}

M._win = nil
M._buf = nil
M._css_path = nil

local function esc_pat(s)
	return s:gsub("(%W)", "%%%1")
end

local function simple_hash(str)
	local hash = 5381
	for i = 1, #str do
		hash = (hash * 33 + str:byte(i)) % 4294967296
	end
	return string.format("%08x", hash)
end

--------------------------------------------------------------------------
-- Project root + css file discovery
--------------------------------------------------------------------------

local function find_project_root()
	local buf_path = vim.api.nvim_buf_get_name(0)
	local start_dir = buf_path ~= "" and vim.fn.fnamemodify(buf_path, ":h") or vim.fn.getcwd()
	local markers = { ".git", "package.json", "composer.json", ".hg" }
	local found = vim.fs.find(markers, { upward = true, path = start_dir })
	if found and found[1] then
		return vim.fn.fnamemodify(found[1], ":h")
	end
	return vim.fn.getcwd()
end

local function find_css_file(root)
	local direct = vim.fn.globpath(root, "*.css", false, true)
	if #direct > 0 then
		table.sort(direct)
		return direct[1]
	end

	for _, sub in ipairs({ "src", "ui" }) do
		local dir = root .. "/" .. sub
		if vim.fn.isdirectory(dir) == 1 then
			local files = vim.fn.globpath(dir, "**/*.css", false, true)
			if #files > 0 then
				table.sort(files)
				return files[1]
			end
		end
	end

	return nil
end

local function ensure_css_file()
	local root = find_project_root()
	local css = find_css_file(root)
	if not css then
		css = root .. "/styles.css"
		if vim.fn.filereadable(css) == 0 then
			vim.fn.mkdir(vim.fn.fnamemodify(css, ":h"), "p")
			local f = io.open(css, "w")
			if f then
				f:write("")
				f:close()
			end
		end
	end
	return css
end

--------------------------------------------------------------------------
-- Selector search / creation (plain CSS, no module semantics)
--------------------------------------------------------------------------

local function find_selector_range(bufnr, classname)
	local patt = "%." .. esc_pat(classname) .. "([^%w_%-])"
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	for i, l in ipairs(lines) do
		if
			l:match(patt)
			or l:match("%." .. esc_pat(classname) .. "%s*{")
			or l:match("%." .. esc_pat(classname) .. "$")
		then
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

local function append_selector_and_get_range(bufnr, classname)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local insert_at = #lines

	local insert_lines = {}
	if #lines > 0 and lines[#lines] ~= "" then
		table.insert(insert_lines, "")
	end

	table.insert(insert_lines, "." .. classname .. " {")
	table.insert(insert_lines, "  ")
	table.insert(insert_lines, "}")

	vim.api.nvim_buf_set_lines(bufnr, insert_at, insert_at, false, insert_lines)

	local offset = (#lines > 0 and lines[#lines] ~= "") and 1 or 0
	local start_line = insert_at + 1 + offset
	local end_line = start_line + 2
	return start_line, end_line
end

local function ensure_css_selector(classname)
	local css_path = ensure_css_file()
	if not css_path then
		vim.notify("Could not determine or create a CSS file", vim.log.levels.ERROR)
		return nil
	end

	local bufnr = vim.fn.bufadd(css_path)
	vim.fn.bufload(bufnr)
	vim.api.nvim_buf_set_option(bufnr, "filetype", "css")
	vim.api.nvim_buf_set_option(bufnr, "buftype", "")
	vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
	vim.api.nvim_buf_set_option(bufnr, "buflisted", true)

	local sline, eline = find_selector_range(bufnr, classname)
	if not sline then
		sline, eline = append_selector_and_get_range(bufnr, classname)
		vim.api.nvim_buf_call(bufnr, function()
			vim.cmd("silent! write")
		end)
	end

	return css_path, bufnr, sline, eline
end

--------------------------------------------------------------------------
-- Floating window
--------------------------------------------------------------------------

local function open_floating_for_range(bufnr, start_line, end_line)
	local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
	local block_lines = #lines

	local max_len = 0
	for _, l in ipairs(lines) do
		if #l > max_len then
			max_len = #l
		end
	end

	local win_w = math.min(math.max(100, max_len + 8), math.floor(vim.o.columns * 0.5))
	local win_h = math.min(math.max(40, block_lines + 4), math.floor(vim.o.lines * 0.4))

	local opts = {
		relative = "cursor",
		width = win_w,
		height = win_h,
		col = 0,
		row = -1,
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(bufnr, true, opts)
	M._win = win
	M._buf = bufnr

	vim.api.nvim_win_set_option(win, "wrap", false)
	vim.api.nvim_win_set_option(win, "cursorline", true)
	vim.api.nvim_win_set_option(win, "number", true)
	vim.api.nvim_win_set_option(win, "relativenumber", false)

	local top_line = math.max(1, start_line - 2)
	vim.api.nvim_win_set_cursor(win, { start_line, 2 })
	vim.fn.winrestview({ topline = top_line })

	local close_cmd = "<Cmd>lua require('user.utils.css_class_floater').close_win()<CR>"
	-- Esc, q, AND <leader>w all close the floater from inside it.
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", close_cmd, { nowait = true, noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(bufnr, "n", "q", close_cmd, { nowait = true, noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(
		bufnr,
		"n",
		"<leader>w",
		close_cmd,
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

--------------------------------------------------------------------------
-- Mode 1: classname-under-cursor (unchanged UX from original tsx floater)
--------------------------------------------------------------------------

local function get_word_at_pos(str, pos)
	-- pos is 1-indexed into str; returns the [%w_%-] word touching/containing pos
	if pos > #str then
		pos = #str
	end
	if pos < 1 then
		pos = 1
	end

	local start_i = pos
	while start_i > 1 do
		local ch = str:sub(start_i - 1, start_i - 1)
		if ch:match("[%w_%-]") then
			start_i = start_i - 1
		else
			break
		end
	end

	local end_i = pos
	while end_i <= #str do
		local ch = str:sub(end_i, end_i)
		if ch:match("[%w_%-]") then
			end_i = end_i + 1
		else
			break
		end
	end
	end_i = end_i - 1

	if end_i < start_i then
		return nil
	end

	return str:sub(start_i, end_i)
end

local function get_classname_under_cursor()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local word = get_word_at_pos(line, col + 1)
	if not word then
		local w = vim.fn.expand("<cword>")
		if w:sub(1, 1) == "." then
			w = w:sub(2)
		end
		return w
	end
	if word:sub(1, 1) == "." then
		word = word:sub(2)
	end
	return word
end

function M.toggle()
	if M._win and vim.api.nvim_win_is_valid(M._win) then
		M.close_win()
		return
	end

	local classname = get_classname_under_cursor()
	if not classname or classname == "" then
		vim.notify("No class name found under cursor", vim.log.levels.ERROR)
		return
	end

	vim.notify("Looking for class: " .. classname, vim.log.levels.INFO)

	local css_path, bufnr, sline, eline = ensure_css_selector(classname)
	if not css_path then
		return
	end

	open_floating_for_range(bufnr, sline, eline)
end

--------------------------------------------------------------------------
-- Mode 2: leader+w tag-aware mode
--------------------------------------------------------------------------

local function get_buffer_text_and_offset()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local text = table.concat(lines, "\n")
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local offset = 0
	for i = 1, row - 1 do
		offset = offset + #lines[i] + 1
	end
	offset = offset + col + 1
	return text, offset, lines
end

local function offset_to_pos(lines, offset)
	local pos = 0
	for i, line in ipairs(lines) do
		local line_len = #line
		if offset <= pos + line_len then
			return i - 1, offset - pos - 1
		end
		pos = pos + line_len + 1
	end
	return #lines - 1, #lines[#lines]
end

-- Find the <...> tag enclosing `offset` in `text`. Returns start/end byte positions or nil.
local function find_enclosing_tag(text, offset)
	local in_string, string_char = false, nil
	local start_pos = nil
	local i = offset
	while i >= 1 do
		local ch = text:sub(i, i)
		if in_string then
			if ch == string_char then
				in_string = false
			end
		else
			if ch == '"' or ch == "'" then
				in_string = true
				string_char = ch
			elseif ch == ">" then
				return nil
			elseif ch == "<" then
				start_pos = i
				break
			end
		end
		i = i - 1
	end
	if not start_pos then
		return nil
	end

	in_string, string_char = false, nil
	local end_pos = nil
	i = offset
	while i <= #text do
		local ch = text:sub(i, i)
		if in_string then
			if ch == string_char then
				in_string = false
			end
		else
			if ch == '"' or ch == "'" then
				in_string = true
				string_char = ch
			elseif ch == ">" then
				end_pos = i
				break
			elseif ch == "<" then
				return nil
			end
		end
		i = i + 1
	end
	if not end_pos then
		return nil
	end

	return start_pos, end_pos
end

-- Find the class/className attribute's value range *within tag_text* (1-indexed, local coords).
-- Returns value_start_local, value_end_local, value_text or nil.
local function find_attr_value_range(tag_text, attr_name)
	local quote_chars = { '"', "'" }
	for _, qc in ipairs(quote_chars) do
		local patt = attr_name .. "%s*=%s*" .. qc
		local s, e = tag_text:find(patt)
		if s then
			local value_start = e + 1
			local close_pos = tag_text:find(qc, value_start, true)
			if close_pos then
				local value_end = close_pos - 1
				if value_end < value_start then
					return value_start, value_start - 1, ""
				end
				return value_start, value_end, tag_text:sub(value_start, value_end)
			end
		end
	end
	return nil
end

function M.toggle_element()
	if M._win and vim.api.nvim_win_is_valid(M._win) then
		M.close_win()
		return
	end

	local filetype = vim.bo.filetype
	local is_blade = vim.fn.expand("%:t"):match("%.php$") ~= nil
	local is_jsx = filetype == "typescriptreact"
		or filetype == "javascriptreact"
		or filetype:match("tsx")
		or filetype:match("jsx")
	local is_markup = filetype == "html" or filetype == "php" or is_blade or is_jsx

	if not is_markup then
		vim.notify(
			"This mapping should be used in an HTML/JSX/TSX file (current: " .. filetype .. ")",
			vim.log.levels.ERROR
		)
		return
	end

	local attr_name = is_jsx and "className" or "class"

	local text, offset, lines = get_buffer_text_and_offset()
	local start_pos, end_pos = find_enclosing_tag(text, offset)
	if not start_pos then
		vim.notify("Cursor is not inside an element tag", vim.log.levels.ERROR)
		return
	end

	if text:sub(start_pos, start_pos + 1) == "</" then
		vim.notify("Cursor is inside a closing tag; place cursor in the opening tag", vim.log.levels.ERROR)
		return
	end

	if text:sub(start_pos, start_pos + 3) == "<!--" then
		vim.notify("Cursor is inside a comment", vim.log.levels.ERROR)
		return
	end

	local tag_text = text:sub(start_pos, end_pos)
	local value_start_local, value_end_local, value_text = find_attr_value_range(tag_text, attr_name)

	local classname = nil

	if value_start_local then
		-- Absolute buffer offsets for the attribute value
		local value_start_abs = start_pos - 1 + value_start_local
		local value_end_abs = start_pos - 1 + value_end_local

		if value_text ~= "" and offset >= value_start_abs and offset <= value_end_abs + 1 then
			-- Cursor sits inside the existing class value: target the exact token under it.
			local local_pos_in_value = offset - value_start_abs + 1
			classname = get_word_at_pos(value_text, local_pos_in_value)
		end

		-- Cursor is in the tag but not (usefully) inside the value: fall back to the first class.
		if not classname or classname == "" then
			classname = value_text:match("^%s*(%S+)")
		end
	end

	if not classname or classname == "" then
		-- No usable existing class: create a new hashed one and insert the attribute.
		local seed = vim.api.nvim_buf_get_name(0) .. tostring(vim.loop.hrtime()) .. tostring(math.random(1, 1e9))
		classname = "c-" .. simple_hash(seed)

		if value_start_local then
			-- Attribute exists but was empty (e.g. class=""): insert the new name into it.
			local insert_offset = start_pos - 1 + value_start_local
			local row, col = offset_to_pos(lines, insert_offset - 1)
			vim.api.nvim_buf_set_text(0, row, col, row, col, { classname })
		else
			-- No attribute at all: insert a brand-new one just before the tag closes.
			local is_self_closing = tag_text:sub(-2) == "/>"
			local insert_offset = is_self_closing and (end_pos - 1) or end_pos
			local row, col = offset_to_pos(lines, insert_offset)
			local attr_text = " " .. attr_name .. '="' .. classname .. '"'
			vim.api.nvim_buf_set_text(0, row, col, row, col, { attr_text })
		end

		vim.notify("Created new class: " .. classname, vim.log.levels.INFO)
	end

	local css_path, bufnr, sline, eline = ensure_css_selector(classname)
	if not css_path then
		return
	end

	open_floating_for_range(bufnr, sline, eline)
end

return M
