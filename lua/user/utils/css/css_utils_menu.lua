local M = {}

-- stylua: ignore start
local options = {
    { key = "scope", value = "📥 Convert current class into scope" },
}
--
-- stylua: ignore end

function M.run()
	-- if not vim.tbl_contains({ "css", "scss" }, vim.bo.filetype) then
	-- 	echo_error("This method must be called only in css or scss projects")
	-- 	return
	-- end

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

		if method.key == "scope" then
			require("user.utils.css.css_convert_to_scope").run()
		end
	end)
end

return M
