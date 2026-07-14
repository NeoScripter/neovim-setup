local M = {}

function M.run()
	vim.ui.input({
		prompt = "Enter the filename: ",
		default = "",
	}, function(filename)
		if filename == nil then
			return nil
		end

		local utils = require("user.utils.images.utils")
		local root = utils.get_project_root()
		local matched_files = vim.fn.globpath(root, "**/*" .. filename .. "*", false, true)

		if next(matched_files) == nil then
			vim.api.nvim_echo({
				{ "\n ✗ Could not find any files with this name", "ErrorMsg" },
			}, false, {})
			return nil
		end

		vim.ui.select(matched_files, {
			prompt = "Select image to convert:",
			format_item = function(item)
				return item:gsub(root, "")
			end,
		}, function(path)
			if not path then
				vim.api.nvim_echo({
					{ "\n ✗ Process aborted" },
				}, false, {})

				return nil
			end

			print(path)
		end)
	end)
end

return M

--[[
    Stages:
    1) copy image from downloads to the specified directory
    2) convert to a desired format
    3) optimize the image
    4) process each image separately


    Utils:
    1) Move image from downloads
    2) Convert image to a specified format
    3) Optimize the image
    4) Resize the image
--]]
