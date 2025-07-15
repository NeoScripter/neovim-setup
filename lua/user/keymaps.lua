-- Space is my leader.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Clear search highlighting.
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Close all open buffers.
vim.keymap.set("n", "<leader>Q", ":bufdo bdelete<CR>")

-- Diagnostics.
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [d]iagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [d]iagnostic" })

-- Reselect visual selection after indenting.
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Maintain the cursor position when yanking a visual selection.
-- http://ddrscott.github.io/blog/2016/yank-without-jank/
vim.keymap.set("v", "y", "myy`y")
vim.keymap.set("v", "Y", "myY`y")

-- When text is wrapped, move by terminal rows, not lines, unless a count is provided.
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- Paste replace visual selection without copying it.
vim.keymap.set("v", "p", '"_dP')

-- Reselect pasted text
-- vim.keymap.set('n', 'p', 'p`[v`]')

-- Easy insertion of a trailing ; or , from insert mode.
vim.keymap.set("i", ";;", "<Esc>A;<Esc>")
vim.keymap.set("i", ",,", "<Esc>A,<Esc>")

-- Open the current file in the default program (on Mac this should just be just `open`).
vim.keymap.set("n", "<leader>x", ':!start "" %<cr><cr>')

-- Disable annoying command line thing.
vim.keymap.set("n", "q:", ":q<CR>")

-- Resize with arrows.
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>")
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>")
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>")

-- Insert mode vim.keymap.set
vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, { noremap = true, silent = true })
vim.keymap.set("i", "<C-H>", "<C-w>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-z>", "<Esc>u", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>lv", ":LiveServer<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>lx", ":StopLiveServer<CR>", { noremap = true, silent = true })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })

-- Move selected lines up in visual mode and reindent
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- Join the next line below to the current one without moving the cursor
vim.keymap.set("n", "J", "mzJ`z", { noremap = true, silent = true })

-- Scroll half-page down and center the cursor
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })

-- Scroll half-page up and center the cursor
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })

-- Go to next search result and center it, unfolding folds if needed
vim.keymap.set("n", "n", "nzzzv", { noremap = true, silent = true })

-- Go to previous search result and center it, unfolding folds if needed
vim.keymap.set("n", "N", "Nzzzv", { noremap = true, silent = true })

-- Format around a paragraph and return to original cursor location
vim.keymap.set("n", "=ap", "ma=ap'a", { noremap = true, silent = true })

-- vim.keymap.set({ "n", "v" }, "y", [["+y]], { noremap = true, silent = true })
-- vim.keymap.set("n", "Y", [["+Y]], { noremap = true, silent = true })

-- -- Use system clipboard for paste
-- vim.keymap.set({ "n", "v" }, "p", [["+p]], { noremap = true, silent = true })
-- vim.keymap.set({ "n", "v" }, "P", [["+P]], { noremap = true, silent = true })

-- -- Delete to clipboard
-- vim.keymap.set({ "n", "v" }, "d", [["+d]], { noremap = true, silent = true })
-- vim.keymap.set({ "n", "v" }, "D", [["+D]], { noremap = true, silent = true })
-- vim.keymap.set({ "n", "v" }, "x", [["+x]], { noremap = true, silent = true })

-- -- Delete without copying to register (use black hole register)
-- vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d", { noremap = true, silent = true })

-- Map Ctrl+C in insert mode to Esc (acts like exiting insert mode cleanly)
vim.keymap.set("i", "<C-c>", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("v", "<C-c>", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("s", "<C-c>", "<Esc>", { noremap = true, silent = true })

-- Disable the useless default Q (Ex mode)
vim.keymap.set("n", "Q", "<nop>", { noremap = true, silent = true })

-- Quickfix: go to next entry and center it
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { noremap = true, silent = true })

vim.keymap.set("n", "<C-l>", vim.diagnostic.open_float, { noremap = true, silent = true })

-- Quickfix: go to previous entry and center it
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { noremap = true, silent = true })

-- Location list: go to next entry and center it
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { noremap = true, silent = true })

-- Location list: go to previous entry and center it
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { noremap = true, silent = true })

-- Search and replace the word under cursor throughout file (with live editing)
vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ noremap = true, silent = true }
)

-- vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { noremap = true, silent = true })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
-- vim.keymap.set("i", "<C-e>", function()
-- 	vim.lsp.buf.execute_command({
-- 		command = "_emmet.expandAbbreviation",
-- 		arguments = {
-- 			vim.api.nvim_get_current_line(),
-- 		},
-- 	})
-- end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>+", ":vertical resize +10<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>-", ":vertical resize -10<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>=", "<C-w>=", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>-", vim.cmd.Ex, { noremap = true, silent = true })

-- vim.keymap.set('n', '<leader>tn', function() require('neotest').run.run() end)

-- vim.keymap.set('n', '<leader>tf', function() require('neotest').run.run(vim.fn.expand('%')) end)

vim.keymap.set('t', '<C-k>', '<Up>', { noremap = true, silent = true })
