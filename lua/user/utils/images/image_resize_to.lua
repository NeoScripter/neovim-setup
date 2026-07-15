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
			echo_error()
			return cb(nil)
		end

		local utils = require("user.utils.images.utils")
		local root = utils.get_project_root()
		local matched_files = vim.fn.globpath(root, "**/*" .. filename .. "*", false, true)

		if next(matched_files) == nil then
			echo_error("Could not find any files with this name")
			return cb(nil)
		end

		vim.ui.select(matched_files, {
			prompt = "Select image to resize:",
			format_item = function(item)
				return item:gsub(root, "")
			end,
		}, function(path)
			if not path then
				echo_error()
				return cb(nil)
			end

			vim.ui.input({
				prompt = "Enter the size: ",
				default = "",
			}, function(size)
				if size == nil then
					echo_error()
					return cb(nil)
				end

				local final_path = utils.resize_image_to(size, path, path)

				cb(final_path)

				echo_success("resized: " .. final_path .. " -> " .. size)
			end)
		end)
	end)
end

return M
