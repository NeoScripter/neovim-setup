-- File: ~/.config/nvim/lua/user/utils/php-tools.lua
-- Automatically run Rector and Peck on PHP file save

local M = {}

-- Configuration
M.config = {
	debug = false, -- Set to true to enable debug logging
}

-- Cache for tool availability to avoid repeated checks
local cache = {
	rector = {},
	peck = {},
	notified = {},
}

-- Debug logging helper
local function log_debug(msg)
	if M.config.debug then
		vim.notify("[PHP Tools Debug] " .. msg, vim.log.levels.INFO)
	end
end

-- Get project root by looking for composer.json
local function get_project_root(filepath)
	log_debug("Looking for project root starting from: " .. filepath)
	local current_dir = vim.fn.fnamemodify(filepath, ":p:h")

	while current_dir ~= "/" do
		local composer_file = current_dir .. "/composer.json"
		log_debug("Checking: " .. composer_file)
		if vim.fn.filereadable(composer_file) == 1 then
			log_debug("Found project root: " .. current_dir)
			return current_dir
		end
		current_dir = vim.fn.fnamemodify(current_dir, ":h")
	end

	log_debug("No project root found")
	return nil
end

-- Check if vendor binary exists
local function vendor_binary_exists(binary, project_root)
	local vendor_path = project_root .. "/vendor/bin/" .. binary
	log_debug("Checking vendor binary: " .. vendor_path)

	-- Use Neovim's built-in function
	local stat = vim.loop.fs_stat(vendor_path)
	if stat and stat.type == "file" then
		log_debug("Found vendor binary: " .. vendor_path)
		return true
	end

	log_debug("Vendor binary not found: " .. vendor_path)
	return false
end

-- Check if global command exists
local function global_command_exists(cmd)
	log_debug("Checking global command: " .. cmd)
	local result = vim.fn.executable(cmd) == 1
	log_debug("Global command " .. cmd .. " exists: " .. tostring(result))
	return result
end

-- Check if tool is available (with caching)
local function is_tool_available(tool, project_root)
	if not project_root then
		return false
	end

	-- Check cache first
	if cache[tool][project_root] ~= nil then
		log_debug(tool .. " availability (cached): " .. tostring(cache[tool][project_root]))
		return cache[tool][project_root]
	end

	-- Check vendor/bin first (preferred for project-specific installations)
	local available = vendor_binary_exists(tool, project_root) or global_command_exists(tool)

	-- Cache the result
	cache[tool][project_root] = available

	log_debug(tool .. " available: " .. tostring(available))
	return available
end

-- Clear cache for a specific project
function M.clear_cache(project_root)
	if project_root then
		cache.rector[project_root] = nil
		cache.peck[project_root] = nil
		log_debug("Cache cleared for: " .. project_root)
	else
		cache.rector = {}
		cache.peck = {}
		cache.notified = {}
		log_debug("All cache cleared")
	end
end

-- Run a PHP tool asynchronously
local function run_tool(tool, filepath, project_root)
	local cmd

	-- Prefer vendor/bin version
	if vendor_binary_exists(tool, project_root) then
		cmd = project_root .. "/vendor/bin/" .. tool
	else
		cmd = tool
	end

	-- Build command based on tool
	local full_cmd
	if tool == "rector" then
		full_cmd = string.format("cd '%s' && '%s' process '%s' --no-progress-bar", project_root, cmd, filepath)
	elseif tool == "peck" then
		full_cmd = string.format("cd '%s' && '%s' '%s'", project_root, cmd, filepath)
	end

	log_debug("Running command: " .. full_cmd)
	vim.notify(string.format("Running %s...", tool), vim.log.levels.INFO)

	-- Run asynchronously using vim.fn.jobstart
	vim.fn.jobstart(full_cmd, {
		on_stdout = function(_, data, _)
			if data and #data > 0 then
				local output = table.concat(data, "\n"):gsub("^%s*(.-)%s*$", "%1")
				if output ~= "" then
					vim.schedule(function()
						log_debug(string.format("[%s stdout] %s", tool, output))
					end)
				end
			end
		end,
		on_stderr = function(_, data, _)
			if data and #data > 0 then
				local output = table.concat(data, "\n"):gsub("^%s*(.-)%s*$", "%1")
				if output ~= "" then
					vim.schedule(function()
						log_debug(string.format("[%s stderr] %s", tool, output))
					end)
				end
			end
		end,
		on_exit = function(_, exit_code, _)
			vim.schedule(function()
				if exit_code == 0 then
					vim.notify(string.format("%s completed successfully", tool), vim.log.levels.INFO)
					-- Reload the buffer to show changes
					vim.cmd("checktime")
				else
					vim.notify(string.format("%s exited with code %d", tool, exit_code), vim.log.levels.WARN)
				end
			end)
		end,
		stdout_buffered = true,
		stderr_buffered = true,
	})
end

-- Main function to run tools on save
function M.run_on_save()
	log_debug("=== run_on_save triggered ===")

	local filepath = vim.fn.expand("%:p")
	local filetype = vim.bo.filetype

	log_debug("Filepath: " .. filepath)
	log_debug("Filetype: " .. filetype)

	-- Only run for PHP files
	if filetype ~= "php" then
		log_debug("Not a PHP file, skipping")
		return
	end

	local project_root = get_project_root(filepath)

	if not project_root then
		log_debug("No project root found, skipping")
		return
	end

	local rector_available = is_tool_available("rector", project_root)
	local peck_available = is_tool_available("peck", project_root)

	-- Run available tools
	if rector_available then
		log_debug("Running Rector")
		run_tool("rector", filepath, project_root)
	else
		log_debug("Rector not available")
	end

	if peck_available then
		log_debug("Running Peck")
		run_tool("peck", filepath, project_root)
	else
		log_debug("Peck not available")
	end

	-- Notify if neither tool is available
	if not rector_available and not peck_available then
		local cache_key = project_root
		if not cache.notified[cache_key] then
			vim.notify("Neither Rector nor Peck found in project: " .. project_root, vim.log.levels.WARN)
			cache.notified[cache_key] = true
		end
	end
end

-- Callback for BufWritePost
function M._on_buf_write_post()
	log_debug("BufWritePost callback executed")
	M.run_on_save()
end

-- Callback for DirChanged
function M._on_dir_changed()
	log_debug("DirChanged callback executed")
	M.clear_cache()
end

-- Setup autocommand
function M.setup(opts)
	opts = opts or {}
	M.config.debug = opts.debug or false

	log_debug("Setting up PHP Tools autocommands")

	-- Create autocommand group
	local group = vim.api.nvim_create_augroup("PHPToolsAutoRun", { clear = true })

	-- Run on save - use explicit function reference
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		pattern = "*.php",
		callback = M._on_buf_write_post,
		desc = "Run Rector and Peck on PHP file save",
	})

	-- Optional: Clear cache when entering a new project
	vim.api.nvim_create_autocmd("DirChanged", {
		group = group,
		callback = M._on_dir_changed,
		desc = "Clear PHP tools cache on directory change",
	})

	log_debug("Setup complete")
	vim.notify("PHP Tools loaded. Debug mode: " .. tostring(M.config.debug), vim.log.levels.INFO)
end

-- Manual trigger command
function M.run_now()
	log_debug("Manual trigger via run_now()")
	M.run_on_save()
end

return M
