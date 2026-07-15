local M = {}

function M.run()
	local file = nil
	local utils = require("user.utils.images.utils")

	require("user.utils.images.copy_from_downloads_to").run(function(path)
		file = path

		if file == nil then
			echo_error("Error tranferring the file from the downloads folder")
			return
		end

		local suffixes = vim.fn.input("Enter image suffixes: ")
		if suffixes == "" then
			echo_error("No suffixes provided")
			return
		end

		local list_suffixes = utils.split(suffixes, " ")

		local sizes = vim.fn.input("Enter image sizes: ")

		if sizes == "" then
			echo_error("No sizes provided")
			return
		end

		local list_sizes = utils.split(sizes, " ")

		if #list_sizes ~= #list_suffixes then
			echo_error("Different number of sizes and suffixes")
			return
		end

		local avif = utils.convert_image_to("avif", file)
		local webp = utils.convert_image_to("webp", file)

		for idx, suffix in ipairs(list_suffixes) do
			local variants = { "", "2x", "3x" }
			for multiple, def in ipairs(variants) do
				local size = list_sizes[idx] * multiple
				local final_suffix = "-" .. suffix .. def
				utils.resize_image_to(size, webp, webp:gsub(".webp", final_suffix .. ".webp"))
				utils.resize_image_to(size, avif, avif:gsub(".avif", final_suffix .. ".avif"))
			end
			utils.resize_image_to(30, webp, webp:gsub(".webp", "-" .. suffix .. "-tiny.webp"))
		end

		echo_success("Image variants are successfully created")
	end)
end

return M
