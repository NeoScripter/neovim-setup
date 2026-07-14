local M = {}

function M.run()
	local file = nil
	local utils = require("user.utils.images.utils")

	require("user.utils.images.copy_from_downloads_to").run(function(path)
		file = path
	end)

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
	end
end

return M
