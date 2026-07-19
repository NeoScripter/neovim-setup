vim.api.nvim_create_user_command(
	"NumCalculatePercentage",
	require("user.utils.number.get_percentage").run,
	{ desc = "Get the percentage of one number relative to the other" }
)

vim.api.nvim_create_user_command(
	"NumToRem",
	require("user.utils.number.convert_to_rem").run,
	{ desc = "Convert a number to rem" }
)

vim.api.nvim_create_user_command(
	"NumToTailwind",
	require("user.utils.number.convert_to_tailwind").run,
	{ desc = "Convert a number to a tailwind class" }
)

vim.api.nvim_create_user_command(
	"CssUtils",
	require("user.utils.css.css_utils_menu").run,
	{ desc = "Open CSS utility menu" }
)
vim.api.nvim_create_user_command(
	"ReactUtils",
	require("user.utils.react.react_utils_menu").run,
	{ desc = "Open React utility menu" }
)

vim.api.nvim_create_user_command(
	"ImageUtils",
	require("user.utils.images.image_utils_menu").run,
	{ desc = "Open image utility menu" }
)
vim.api.nvim_create_user_command("OrganizeComponent", require("user.utils.organize_component").run, {})

-- Create a custom command to edit Downloads directory with Oil
vim.api.nvim_create_user_command("EditDownloads", require("user.utils.edit-downloads").run, {
	desc = "Edit downloads directory",
})

vim.api.nvim_create_user_command("Undotree", function(opts)
	local args = opts.fargs
	local cmd = args[1]

	local cb = require("undotree")[cmd]

	if cmd == "setup" or cb == nil then
		vim.notify("Invalid subcommand: " .. (cmd or ""), vim.log.levels.ERROR)
	else
		cb()
	end
end, {
	nargs = 1,
	complete = function(arg_lead)
		return vim.tbl_filter(function(cmd)
			return vim.startswith(cmd, arg_lead)
		end, { "toggle", "open", "close" })
	end,
	desc = "Undotree command with subcommands: toggle, open, close",
})

local group_id = nil

local function toggle_update_assets_autocmd()
	if group_id ~= nil then
		vim.api.nvim_del_augroup_by_id(group_id)
		group_id = nil
		print("Auto build: disabled")
		return
	end

	group_id = vim.api.nvim_create_augroup("hot-module-refresh", { clear = true })

	local cb = function()
		local command = "pnpm run build > /dev/null 2>&1; ~/.config/i3/ws9_f5.sh;"
		vim.fn.jobstart(command, {
			stdout_buffered = true,
			on_stderr = function(_, data)
				if data then
					print(table.concat(data, "\n"))
				end
			end,
		})
	end

	cb()

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group_id,
		pattern = { "*.php", "*.html", "*.scss", "*.css", "*.ts", "*.js", "*.jsx", "*.tsx" },
		callback = cb,
	})

	print("Auto build: enabled")
end

vim.api.nvim_create_user_command("ToggleAutoBuild", toggle_update_assets_autocmd, {
	desc = "Toggle Auto Build and Update Frontend Assets When Any File Changes",
})

local search_term = "style"

vim.keymap.set("n", "<leader>w", function()
	require("user.utils.css.css_helper").run(search_term)
end, { desc = "Open css file" })

vim.api.nvim_create_user_command("ChangeCSSFileSearchTerm", function()
	local input = vim.fn.input("Enter CSS file name: ")

	if input == nil then
		echo_error("No search term supplied")
		return
	end

	search_term = input
end, {})

vim.api.nvim_create_user_command("Test", function()
	local files = vim.fn.split(vim.fn.system([[fd -t f -i -e scss -e css -E node_modules -E dist -E build]]), "\n")

	for _, value in pairs(files) do
		print(value)
	end
end, {})
