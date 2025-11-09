-- Cmp

vim.opt.completeopt = { "menuone", "noselect", "noinsert" }
vim.opt.shortmess = vim.opt.shortmess + { c = true }

_G.ctrl_y_action = function()
  local ok, info = pcall(vim.fn.complete_info)
  if not ok or not info or info.mode == "" then
    -- No active completion menu (e.g. Telescope prompt)
    return vim.api.nvim_replace_termcodes("<C-y>", true, false, true)
  end

  local feedkeys = vim.api.nvim_feedkeys
  local termcodes = vim.api.nvim_replace_termcodes

  if info.selected == -1 then
    -- Select first item if none selected
    feedkeys(termcodes("<C-n>", true, false, true), "n", true)
  end

  -- Confirm selection
  feedkeys(termcodes("<C-y>", true, false, true), "n", true)
  return ""
end

vim.keymap.set("i", "<C-y>", "v:lua.ctrl_y_action()", { expr = true, noremap = true })

return {
	"echasnovski/mini.nvim",
	version = false, -- always use latest
	config = function()
		require("mini.completion").setup({
			lsp_completion = {
				source_func = "omnifunc", -- use built-in omnifunc
				auto_setup = true,
			},
			auto_completion = {
				enabled = true, -- still show popup
				auto_select = true, -- do NOT insert automatically
			},
		})
	end,
}
