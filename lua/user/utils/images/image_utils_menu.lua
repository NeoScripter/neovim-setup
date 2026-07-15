local M = {}

-- stylua: ignore start
local options = {
	copy = "📥 Import image from downloads",
	resize = "↕️ Resize to specific dimensions",
	convert = "🖼️ Convert to different format",
	variants = "📚 Create responsive variants",
}
-- stylua: ignore end

function M.run()
	local items = {}

	for key, value in pairs(options) do
		table.insert(items, { key = key, value = value })
	end

	vim.ui.select(items, {
		prompt = "Select the method:",
		format_item = function(item)
			return item.value
		end,
	}, function(method)
		if not method then
			echo_error("Process aborted")
			return
		end

		if method.key == "copy" then
			require("user.utils.images.copy_from_downloads_to").run()
		elseif method.key == "convert" then
			require("user.utils.images.image_convert_to").run()
		elseif method.key == "resize" then
			require("user.utils.images.image_resize_to").run()
		elseif method.key == "variants" then
			require("user.utils.images.image_make_variants").run()
		end
	end)
end
return M
