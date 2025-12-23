local M = {}

-- Utility: trim
local function trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Detect nearest function name above a given line index
local function find_function_name(lines, start_idx)
	for i = start_idx - 1, 1, -1 do
		local l = trim(lines[i])

		-- function foo(...)
		local name = l:match("^function%s+([%w_$]+)%s*%(")
		if name then
			return name
		end

		-- var|let|const foo = <anything>
		name = l:match("^var%s+([%w_$]+)%s*=")
		if name then
			return name
		end

		-- foo: function(...) or foo = function(...)
		name = l:match("^([%w_$]+)%s*[:=]%s*function%s*%(")
		if name then
			return name
		end
	end

	return nil
end -- Extract ordered input values

local function extract_values(input_line)
	local values = {}
	local text = input_line

	-- We will scan left-to-right using a pattern list
	local patterns = {
		"%b[]", -- arrays
		'"[^"]*"', -- double-quoted strings
		"'[^']*'", -- single-quoted strings
		"true",
		"false", -- booleans
		"%d+", -- numbers
	}

	local i = 1
	while i <= #text do
		local found, j, token = nil, nil, nil

		for _, pat in ipairs(patterns) do
			local s, e = text:find(pat, i)
			if s and (not found or s < found) then
				found, j = s, e
				token = text:sub(s, e)
			end
		end

		if not found then
			break
		end

		table.insert(values, token)
		i = j + 1
	end

	return values
end

function M.generate_test()
	local api = vim.api
	local lines = api.nvim_buf_get_lines(0, 0, -1, false)

	-- EXTENSION: check topmost line for 'test' and add import if missing
	if not lines[1]:match("test") then
		api.nvim_buf_set_lines(0, 0, 0, false, { "import test from './test.js';" })
	end

	local cur_line = api.nvim_win_get_cursor(0)[1]
	lines = api.nvim_buf_get_lines(0, 0, -1, false)

	-- 1. Find Input:
	local input_idx
	for i = cur_line, #lines do
		if lines[i]:match("^%s*Input:%s*") then
			input_idx = i
			break
		end
	end
	if not input_idx then
		return print("No Input: found")
	end

	-- 2. Find Output:
	local output_idx
	for i = input_idx + 1, #lines do
		if lines[i]:match("^%s*Output:%s*") then
			output_idx = i
			break
		end
	end
	if not output_idx then
		return print("No Output: found")
	end

	local input_line = lines[input_idx]
	local output_line = lines[output_idx]

	-- Extract values
	local values = extract_values(input_line)

	-- Extract output value
	local output_val = output_line:match("Output:%s*(.+)")
	if not output_val then
		return print("Cannot parse Output value")
	end
	output_val = trim(output_val)

	-- Detect function name above Input:
	local fn_name = find_function_name(lines, input_idx)
	if not fn_name then
		return print("Cannot detect function name")
	end

	-- Find previous case number
	local case_num = 1
	for i = input_idx - 1, 1, -1 do
		local n = lines[i]:match("test%('case%s*(%d+)'")
		if n then
			case_num = tonumber(n) + 1
			break
		end
	end

	-- Delete Input/Output
	api.nvim_buf_set_lines(0, input_idx - 1, output_idx, false, {})

	-- Final line
	local args = table.concat(values, ", ")
	local final = string.format("test('case %d', %s(%s), %s);", case_num, fn_name, args, output_val)

	-- Insert
	api.nvim_buf_set_lines(0, input_idx - 1, input_idx - 1, false, { final })
end

return M
