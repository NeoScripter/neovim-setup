local downloads_dir = "/home/ilya/Downloads/"
local M = {}
local function get_project_root()
	return vim.fs.root(
		0,
		{ { ".git", "package.json", "composer.json", "vite.config", "node_modules", "index.html" }, ".git" }
	)
end

function M.run(callback)
	callback = callback or function() end

	local downloads = vim.fn.readdir(downloads_dir)
	local root = get_project_root()
	local assets_dir = vim.fn.globpath(root, "**/assets", false, true, true)

	if next(assets_dir) == nil then
		assets_dir = { root }
	end

	assets_dir = assets_dir[1]

	local image_files = vim.tbl_filter(function(file)
		local ext = file:match("%.([%w]+)$")
		return ext and vim.tbl_contains({ "png", "jpg", "jpeg", "gif", "svg", "webp" }, ext:lower())
	end, downloads)

	vim.ui.select(image_files, {
		prompt = "Select image to move:",
		format_item = function(item)
			return item
		end,
	}, function(choice)

		if not choice then
			return callback(nil)
		end

		vim.ui.input({
			prompt = "Subfolder (optional, relative to " .. assets_dir:gsub(root, "") .. "): ",
			default = "",
		}, function(subfolder)

			if subfolder == nil then
				return callback(nil)
			end

			local dest_dir = assets_dir

			if subfolder ~= "" then
				dest_dir = dest_dir .. "/" .. subfolder
			end

			vim.ui.input({
				prompt = "Enter the new image name (press Enter to keep original): ",
				default = choice:match("(.*)%.[%w]+$"),
			}, function(new_name)

				if new_name == nil then
					return callback(nil)
				end

				local final_name = new_name

				if new_name == "" then
					final_name = choice
				end

				if not final_name:match("%.[%w]+$") then
					local ext = choice:match("%.([%w]+)$")
					if ext then
						final_name = final_name .. "." .. ext
					end
				end

				vim.fn.mkdir(dest_dir, "p")

				local source = downloads_dir .. choice
				local dest = dest_dir .. "/" .. final_name
				vim.fn.delete(dest)

				local result = vim.fn.filecopy(source, dest)

				if result == 1 then
					print("Copied: " .. choice .. " -> " .. dest)
					callback(dest)
				else
					print("Failed to copy file: " .. source .. " -> " .. dest)
					callback(nil)
				end
			end)
		end)
	end)
end

return M
