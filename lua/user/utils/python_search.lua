local M = {}

function M.search_method()
	if vim.bo.filetype ~= "python" then
		print("Not a Python file")
		return
	end

	vim.ui.input({ prompt = "Describe what you want to do: " }, function(query)
		if not query or query == "" then
			return
		end

		-- Python script - query passed as argument
		local python_code = [[
import sys

query = sys.argv[1].lower()
results = []

# Common types and modules to search
builtins = [dict, list, str, set, tuple, int, float, bytes, bool]
import_modules = []

try:
    import itertools
    import_modules.append(('itertools', itertools))
except: pass

try:
    import collections
    import_modules.append(('collections', collections))
except: pass

try:
    import functools
    import_modules.append(('functools', functools))
except: pass

# Search builtin types
for cls in builtins:
    for attr in dir(cls):
        if attr.startswith('_'):
            continue
        try:
            method = getattr(cls, attr)
            doc = method.__doc__ or ""
            if query in attr.lower() or query in doc.lower():
                results.append(f"{cls.__name__}.{attr}() - {doc.split(chr(10))[0][:80]}")
        except:
            pass

# Search imported modules
for mod_name, mod in import_modules:
    for attr in dir(mod):
        if attr.startswith('_'):
            continue
        try:
            func = getattr(mod, attr)
            doc = func.__doc__ or ""
            if query in attr.lower() or query in doc.lower():
                results.append(f"{mod_name}.{attr}() - {doc.split(chr(10))[0][:80]}")
        except:
            pass

if results:
    print(chr(10).join(results[:20]))
else:
    print("No methods found matching your query")
]]

		-- Pass query as command line argument
		local cmd = string.format("python3 -c %s %s", vim.fn.shellescape(python_code), vim.fn.shellescape(query))
		local output = vim.fn.systemlist(cmd)

		if #output == 0 then
			print("No results found")
			return
		end

        local height = math.floor(vim.o.lines * 0.4)

		vim.cmd(height .. "split")
		local bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_win_set_buf(0, bufnr)

		vim.bo[bufnr].buftype = "nofile"
		vim.bo[bufnr].bufhidden = "wipe"
		vim.bo[bufnr].swapfile = false
		vim.bo[bufnr].filetype = "text"

		local header = { "Search results for: " .. query, string.rep("-", 60), "" }
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, header)
		vim.api.nvim_buf_set_lines(bufnr, #header, -1, false, output)
		vim.bo[bufnr].modifiable = false

		vim.keymap.set("n", "<CR>", function()
			vim.cmd("bwipeout! " .. bufnr)
		end, { buffer = bufnr, silent = true })

		vim.keymap.set("n", "h", function()
			local line = vim.api.nvim_get_current_line()
			local method = line:match("^([%w_]+%.[%w_]+)")
			if method then
				vim.cmd("bwipeout! " .. bufnr)
				local help_cmd = string.format("python3 -c \"help('%s')\"", method)
				local help_output = vim.fn.systemlist(help_cmd)

				vim.cmd(height .. "split")
				local help_bufnr = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_win_set_buf(0, help_bufnr)
				vim.bo[help_bufnr].buftype = "nofile"
				vim.bo[help_bufnr].bufhidden = "wipe"
				vim.api.nvim_buf_set_lines(help_bufnr, 0, -1, false, help_output)
				vim.bo[help_bufnr].modifiable = false

				vim.keymap.set("n", "<CR>", function()
					vim.cmd("bwipeout! " .. help_bufnr)
				end, { buffer = help_bufnr, silent = true })
			end
		end, { buffer = bufnr, silent = true })

		vim.api.nvim_buf_set_name(bufnr, "Python Search: " .. query)
		print("Press <CR> to close, 'h' on a method to see full help")
	end)
end

return M
