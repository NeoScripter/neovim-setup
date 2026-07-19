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
			echo_error("Process aborted")
			return cb(nil)
		end

		local utils = require("user.utils.images.utils")
		local root = utils.get_project_root()
		local cmd = string.format([[fd '%s' -t f -i -E node_modules -E dist -E build]], filename)
		local matched_files = vim.fn.split(vim.fn.system(cmd), "\n")

		if next(matched_files) == nil then
			echo_error("Could not find any files with this name")
			return cb(nil)
		end

		vim.ui.select(matched_files, {
			prompt = "Select image to convert:",
			format_item = function(item)
				return item:gsub(root, "")
			end,
		}, function(path)
			if not path then
				echo_error("Process aborted")
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
					echo_error("Process aborted")
					return cb(nil)
				end

				local final_path = utils.convert_image_to(format, path)

				cb(final_path)

				echo_success("Converted: " .. path .. " -> " .. final_path)
			end)
		end)
	end)
end

return M
