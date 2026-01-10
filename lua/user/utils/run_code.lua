local M = {}

function M.run()
	local ft = vim.bo.filetype
	local filename = vim.fn.expand("%:p")
	vim.cmd("w")

	local runners = {
		python = "python3",
		javascript = "node",
		php = "php",
		bash = "bash",
		sh = "bash",
	}

	if ft == "lua" then
		vim.cmd("luafile " .. vim.fn.fnameescape(filename))
	elseif runners[ft] then
		local height = math.floor(vim.o.lines * 0.25)
		vim.cmd(height .. "split | terminal " .. runners[ft] .. " " .. vim.fn.shellescape(filename))

		local bufnr = vim.api.nvim_get_current_buf()

		-- Close terminal with Enter after process exits
		vim.api.nvim_create_autocmd("TermClose", {
			buffer = bufnr,
			callback = function()
				vim.keymap.set("n", "<CR>", function()
					vim.cmd("bwipeout! " .. bufnr)
				end, { buffer = bufnr, silent = true })
			end,
			once = true,
		})
	else
		print("No runner configured for " .. ft)
	end
end

return M
