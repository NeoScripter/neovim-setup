local M = {}

local options = {
	{ key = "copy", value = "📥 Import image from downloads" },
	{ key = "resize", value = "↕️ Resize to specific dimensions" },
	{ key = "convert", value = "🖼️ Convert to different format" },
	{ key = "variants", value = "📚 Create responsive variants" },
}

function M.run()
	vim.ui.select(options, {
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
