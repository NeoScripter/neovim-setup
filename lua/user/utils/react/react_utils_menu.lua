local M = {}

local options = {
	{ key = "images", value = "📥 Print image imports" },
	{ key = "component", value = "📥 Create a React component" },
}

function M.run()
	if not vim.tbl_contains({ "javascript", "typescript", "javascriptreact", "typescriptreact" }, vim.bo.filetype) then
		echo_error("This method must be called only in ts, js, jsx or tsx projects")
		return
	end

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

		if method.key == "images" then
			require("user.utils.react.react_print_image_variants").run()
		elseif method.key == "component" then
			print("hello")
		end
	end)
end

return M
