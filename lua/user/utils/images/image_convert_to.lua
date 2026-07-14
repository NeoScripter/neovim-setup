local M = {}

function M.run()
	local handler = require("user.utils.images.copy_from_downloads_to")

	handler.run(function(result)
		print(result)
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
