-- React Context Boilerplate Generator for Neovim
-- Place this in ~/.config/nvim/lua/react-context.lua
-- Then require it in your init.lua: require('react-context')

local M = {}

-- Extract context name from filename
-- e.g., "AuthContext.tsx" -> "Auth"
local function get_context_name_from_filename(filename)
	-- Remove path and get just the filename
	local basename = vim.fn.fnamemodify(filename, ":t")

	-- Remove extension (.tsx or .ts)
	local name_without_ext = basename:match("(.+)%.[^.]+$") or basename

	-- Remove 'Context' suffix if present
	local context_name = name_without_ext:gsub("Context$", "")

	return context_name
end

-- Generate the React Context boilerplate
local function generate_context_boilerplate(context_name)
	local template = string.format(
		[[import { createContext, useContext, useState, ReactNode } from 'react';

type %sContextType = {
    value: boolean;
    setValue: (v: boolean) => void;
};

const %sContext = createContext<%sContextType | undefined>(undefined);

export function %sProvider({ children }: { children: ReactNode }) {
    const [value, setValue] = useState(false);
    
    return (
        <%sContext.Provider value={{ value, setValue }}>
            {children}
        </%sContext.Provider>
    );
}

export function use%s() {
    const ctx = useContext(%sContext);
    if (!ctx) throw new Error('use%s must be used within %sProvider');
    return ctx;
}]],
		context_name,
		context_name,
		context_name,
		context_name,
		context_name,
		context_name,
		context_name,
		context_name,
		context_name,
		context_name
	)

	return template
end

-- Insert the boilerplate into the current buffer
function M.create_react_context()
	local filename = vim.fn.expand("%:t")

	-- Check if file is a .tsx or .ts file
	if not filename:match("%.tsx?$") then
		vim.notify("ReactContext: File must be a .tsx or .ts file", vim.log.levels.WARN)
		return
	end

	-- Check if buffer is empty
	local line_count = vim.api.nvim_buf_line_count(0)
	local is_empty = line_count == 1 and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == ""

	if not is_empty then
		vim.notify("ReactContext: Buffer is not empty. Use in empty files only.", vim.log.levels.WARN)
		return
	end

	local context_name = get_context_name_from_filename(filename)
	local boilerplate = generate_context_boilerplate(context_name)

	-- Split boilerplate into lines
	local lines = {}
	for line in boilerplate:gmatch("[^\n]+") do
		table.insert(lines, line)
	end

	-- Insert lines into buffer
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

	-- Move cursor to the first line
	vim.api.nvim_win_set_cursor(0, { 1, 0 })

	vim.notify(string.format("Created %sContext boilerplate", context_name), vim.log.levels.INFO)
end

-- Setup autocommand
function M.setup(opts)
	opts = opts or {}

	-- Create autocommand group
	local group = vim.api.nvim_create_augroup("ReactContext", { clear = true })

	-- Create autocommand that triggers on BufNewFile for *Context.tsx files
	vim.api.nvim_create_autocmd("BufNewFile", {
		group = group,
		pattern = "*Context.tsx",
		callback = function()
			M.create_react_context()
		end,
		desc = "Generate React Context boilerplate for new Context files",
	})

	-- Create user command for manual invocation
	vim.api.nvim_create_user_command("ReactContext", function()
		M.create_react_context()
	end, {
		desc = "Generate React Context boilerplate",
	})
end

return M
