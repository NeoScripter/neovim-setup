local M = {}

local excluded_dirs = {
	"node_modules",
	".git",
	"vendor",
	"dist",
	"build",
	".next",
}

function M.run()
	vim.ui.input({
		prompt = "Enter the filename: ",
		default = "",
	}, function(filename)
		if filename == nil then
			echo_error("Process aborted")
			return
		end

		local utils = require("user.utils.images.utils")
		local str = require("user.utils.str.utils")
		local root = utils.get_project_root()

		local matched_files = vim.fn.globpath(root, "**/*" .. filename .. "*", false, true)

		matched_files = vim.tbl_filter(function(file)
			if vim.fn.isdirectory(file) == 1 then
				return false
			end

			for _, excluded in ipairs(excluded_dirs) do
				local escaped = vim.pesc(excluded)
				if file:match("[/\\]" .. escaped .. "[/\\]") or file:match("^" .. escaped .. "[/\\]") then
					return false
				end
			end

			return true
		end, matched_files)

		if next(matched_files) == nil then
			echo_error("Could not find any files with this name")
			return
		end

		vim.ui.select(matched_files, {
			prompt = "Select image to import:",
			format_item = function(item)
				item = item:gsub(root, "")
				item = item:gsub("/resources/js", "")
				item = item:gsub("/public", "")

				return item
			end,
		}, function(choice)
			if not choice then
				echo_error("Process aborted")
				return
			end

			local parent_dir = vim.fn.fnamemodify(choice, ":h")
			local variant_names = vim.fn.readdir(parent_dir)

			local variants = vim.tbl_map(function(name)
				return parent_dir .. "/" .. name
			end, variant_names)

			variants = vim.tbl_filter(function(file)
				if vim.fn.isdirectory(file) == 1 then
					return false
				end
				local base = vim.fn.fnamemodify(file, ":t")
				return base:find(filename, 1, true) ~= nil
			end, variants)

			if next(variants) == nil then
				echo_error("Could not find any files with this name")
				return
			end

			local new_lines = {}

			for _, path in ipairs(variants) do
				path = path:gsub(root, "")
				path = path:gsub("/resources/js", "")
				path = "@" .. path:gsub("/public", "")
				local file_slug = path:match("([%w-]+%.%w+)$")
				if file_slug ~= nil then
					file_slug = file_slug:gsub("%.", "-")
				end
				file_slug = str.kebab_to_pascal(file_slug)
				local import = "import " .. file_slug .. " from '" .. path .. "'"
				table.insert(new_lines, import)
			end

			local start_row = vim.api.nvim_win_get_cursor(0)[1]

			vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), start_row - 1, start_row - 1, false, new_lines)
		end)
	end)
end

return M
