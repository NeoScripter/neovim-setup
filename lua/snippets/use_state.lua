-- File: ~/.config/nvim/lua/snippets/use_state.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- Function to get the variable name from the useState destructuring
local function get_setter_name()
	local line = vim.api.nvim_get_current_line()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	-- Get text before cursor (not including the trigger)
	local before_cursor = line:sub(1, col)
	before_cursor = before_cursor:gsub("se?t?$", "")

	-- Extract the variable name from: const [varName,
	local var_name = before_cursor:match("%[%s*([%w_]+)%s*,%s*$")

	if var_name and var_name ~= "" then
		-- Convert to setter name (camelCase)
		local setter = "set" .. var_name:sub(1, 1):upper() .. var_name:sub(2)

		-- After snippet inserts, clean up the rest of the line
		vim.schedule(function()
			local current_row = vim.api.nvim_win_get_cursor(0)[1]
			local current_line = vim.api.nvim_buf_get_lines(0, current_row - 1, current_row, false)[1]

			-- Remove everything after "] = useState();" if it exists
			local cleaned = current_line:gsub("(.*%] = useState%(%);).*", "%1")
			vim.api.nvim_buf_set_lines(0, current_row - 1, current_row, false, { cleaned })
		end)

		return setter .. "] = useState();"
	end

	return ""
end

-- Create the snippet
local function create_setter_snippet()
	return s({
		trig = "set",
		name = "setValue",
		wordTrig = true,
		priority = 1000,
		dscr = "useState hook",
        docstring = "setValue",
	}, {
		f(get_setter_name, {}),
	})
end

-- Register snippets for all React file types
local filetypes = { "typescriptreact", "javascriptreact", "typescript", "javascript" }

for _, ft in ipairs(filetypes) do
	ls.add_snippets(ft, {
		create_setter_snippet(),
	})
end
