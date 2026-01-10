local M = {}

function M.show_help()
	if vim.bo.filetype ~= "python" then
		print("Not a Python file")
		return
	end

	local line = vim.api.nvim_get_current_line()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	col = col + 1

	-- Find the method name (after the dot)
	local start_pos = col
	while start_pos > 1 and line:sub(start_pos - 1, start_pos - 1):match("[%w_.]") do
		start_pos = start_pos - 1
	end

	local end_pos = col
	while end_pos <= #line and line:sub(end_pos, end_pos):match("[%w_]") do
		end_pos = end_pos + 1
	end

	local full_name = line:sub(start_pos, end_pos - 1)

	-- Extract just the method name (after last dot)
	local method_name = full_name:match("%.([%w_]+)$") or full_name

	if method_name == "" then
		print("No method found")
		return
	end

	-- Use Python to find which builtin type has this method
	local python_code = string.format(
		[[
import sys
method_name = '%s'
builtins = [dict, list, str, set, tuple, int, float, bytes]

for cls in builtins:
    if hasattr(cls, method_name):
        help(getattr(cls, method_name))
        sys.exit(0)

# If not found in builtins, try the method name directly
print(f"Method '{method_name}' not found in common builtins")
]],
		method_name
	)

	local cmd = string.format("python3 -c %s", vim.fn.shellescape(python_code))
	local output = vim.fn.systemlist(cmd)

	local height = math.floor(vim.o.lines * 0.25)

	vim.cmd(height .. "split")
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(0, bufnr)

	vim.bo[bufnr].buftype = "nofile"
	vim.bo[bufnr].bufhidden = "wipe"
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].filetype = "text"

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
	vim.bo[bufnr].modifiable = false

	vim.keymap.set("n", "<CR>", function()
		vim.cmd("bwipeout! " .. bufnr)
	end, { buffer = bufnr, silent = true })

	vim.api.nvim_buf_set_name(bufnr, "Python Help: " .. method_name)
end

return M
