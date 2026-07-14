local M = {}

-- stylua: ignore start
local options = {
	images = "📥 Print image imports",
	component = "📥 Create a React component",
}
-- stylua: ignore end

function M.run()
	if not vim.tbl_contains({ "javascript", "typescript", "javascriptreact", "typescriptreact" }, vim.bo.filetype) then
		vim.api.nvim_echo({
			{ "\n ✗ This method must be called only in ts, js, jsx or tsx projects", "ErrorMsg" },
		}, false, {})
		return
	end

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
			vim.api.nvim_echo({
				{ "\n ✗ Process aborted", "ErrorMsg" },
			}, false, {})
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
