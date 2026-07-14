local M = {}

function M.run()
	local file = nil
	local utils = require("user.utils.images.utils")

	require("user.utils.images.copy_from_downloads_to").run(function(path)
		file = path

		if file == nil then
			vim.api.nvim_echo({
				{ "\n ✗ Error tranferring the file from the downloads folder", "ErrorMsg" },
			}, false, {})

			return
		end

		local suffixes = vim.fn.input("Enter image suffixes: ")
		if suffixes == "" then
			vim.api.nvim_echo({
				{ "\n ✗ No suffixes provided", "ErrorMsg" },
			}, false, {})
			return
		end

		local list_suffixes = utils.split(suffixes, " ")

		local sizes = vim.fn.input("Enter image sizes: ")

		if sizes == "" then
			vim.api.nvim_echo({
				{ "\n ✗ No sizes provided", "ErrorMsg" },
			}, false, {})
			return
		end

		local list_sizes = utils.split(sizes, " ")

		if #list_sizes ~= #list_suffixes then
			vim.api.nvim_echo({
				{ "\n ✗ Different number of sizes and suffixes", "ErrorMsg" },
			}, false, {})
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

		vim.api.nvim_echo({
			{ "\n ✓ Image variants are successfully created" },
		}, false, {})
	end)
end

return M
