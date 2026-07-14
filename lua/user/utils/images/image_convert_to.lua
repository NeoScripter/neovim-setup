local M = {}

function M.run(cb)
	if cb ~= nil and type(cb) ~= "function" then
		cb = nil
	end
	cb = cb or function() end

	vim.ui.input({
		prompt = "Enter the filename: ",
		default = "",
	}, function(filename)
		if filename == nil then
			vim.api.nvim_echo({
				{ "\n ✗ Process aborted", "ErrorMsg" },
			}, false, {})
			return cb(nil)
		end

		local utils = require("user.utils.images.utils")
		local root = utils.get_project_root()
		local matched_files = vim.fn.globpath(root, "**/*" .. filename .. "*", false, true)

		if next(matched_files) == nil then
			vim.api.nvim_echo({
				{ "\n ✗ Could not find any files with this name", "ErrorMsg" },
			}, false, {})
			return cb(nil)
		end

		vim.ui.select(matched_files, {
			prompt = "Select image to convert:",
			format_item = function(item)
				return item:gsub(root, "")
			end,
		}, function(path)
			if not path then
				vim.api.nvim_echo({
					{ "\n ✗ Process aborted", "ErrorMsg" },
				}, false, {})

				return cb(nil)
			end

			local formats = { "png", "webp", "jpg", "avif" }

			vim.ui.select(formats, {
				prompt = "Select format:",
				format_item = function(item)
					return item
				end,
			}, function(format)
				if not format then
					vim.api.nvim_echo({
						{ "\n ✗ Process aborted", "ErrorMsg" },
					}, false, {})

					return cb(nil)
				end

				local final_path = utils.convert_image_to(format, path)

				cb(final_path)

				vim.api.nvim_echo({
					{ "\n ✓ Converted: " .. path .. " -> " .. final_path },
				}, false, {})
			end)
		end)
	end)
end

return M
