local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", opts)
keymap("n", "<leader>fp", function()
    local scan = require("plenary.scandir")
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    local dirs = {}
    local bases = {
        "D:/Herd",
        "D:/javascript",
        "C:/Users/User/AppData/Local",
    }

    for _, base in ipairs(bases) do
        local ok, results = pcall(scan.scan_dir, base, { only_dirs = true, depth = 2 })
        if ok then
            vim.list_extend(dirs, results)
        end
    end

    pickers.new({}, {
        prompt_title = "Select Project",
        finder = finders.new_table({ results = dirs }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                local path = selection[1]
                vim.cmd("cd " .. vim.fn.fnameescape(path)) -- real global cd
                vim.notify("Project root: " .. path)
                require("telescope.builtin").find_files({ cwd = path })
            end)
            return true
        end,
    }):find()
end, opts)
keymap("n", "<leader>fb", ":Telescope buffers<CR>", opts)
keymap("n", "<leader>fh", ":Telescope help_tags<CR>", opts)
keymap("n", "<leader>pv", vim.cmd.Ex, opts)
-- Normal mode LSP keymaps
keymap("n", "gd", vim.lsp.buf.definition, opts)
keymap("n", "K", vim.lsp.buf.hover, opts)
keymap("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
keymap("n", "<leader>vd", vim.diagnostic.open_float, opts)
keymap("n", "[d", vim.diagnostic.goto_next, opts)
keymap("n", "]d", vim.diagnostic.goto_prev, opts)
keymap("n", "<leader>vca", vim.lsp.buf.code_action, opts)
keymap("n", "<leader>vrr", vim.lsp.buf.references, opts)
keymap("n", "<leader>vrn", vim.lsp.buf.rename, opts)
keymap("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)

--[[ 
local terminal_bufnr = nil

keymap("n", "<C-tt>", function()
  local is_valid = terminal_bufnr
    and vim.api.nvim_buf_is_valid(terminal_bufnr)
    and vim.api.nvim_buf_is_loaded(terminal_bufnr)

  if is_valid then
    vim.api.nvim_set_current_buf(terminal_bufnr)
  else
    local cwd = vim.fn.getcwd()

    -- open terminal in a new horizontal split
    vim.cmd("split")
    terminal_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, terminal_bufnr)

    -- force PowerShell to start in the correct directory
    vim.fn.termopen({
      "powershell.exe",
      "-NoExit",
      "-Command",
      "cd '" .. cwd .. "'"
    })

    vim.cmd("startinsert")
  end
end, opts) --]]

-- Insert mode keymap
keymap("i", "<C-h>", vim.lsp.buf.signature_help, opts)
keymap("i", "<C-H>", "<C-w>", opts)
keymap("i", "<C-z>", "<Esc>u", opts)

keymap("n", "<leader>lv", ":LiveServer<CR>", opts)
keymap("n", "<leader>lx", ":StopLiveServer<CR>", opts)


keymap("v", "J", ":m '>+1<CR>gv=gv", opts)

-- Move selected lines up in visual mode and reindent
keymap("v", "K", ":m '<-2<CR>gv=gv", opts)

-- Join the next line below to the current one without moving the cursor
keymap("n", "J", "mzJ`z", opts)

-- Scroll half-page down and center the cursor
keymap("n", "<C-d>", "<C-d>zz", opts)

-- Scroll half-page up and center the cursor
keymap("n", "<C-u>", "<C-u>zz", opts)

-- Go to next search result and center it, unfolding folds if needed
keymap("n", "n", "nzzzv", opts)

-- Go to previous search result and center it, unfolding folds if needed
keymap("n", "N", "Nzzzv", opts)

-- Format around a paragraph and return to original cursor location
keymap("n", "=ap", "ma=ap'a", opts)

keymap({ "n", "v" }, "y", [["+y]], opts)
keymap("n", "Y", [["+Y]], opts)

-- Use system clipboard for paste
keymap({ "n", "v" }, "p", [["+p]], opts)
keymap({ "n", "v" }, "P", [["+P]], opts)

-- Delete to clipboard
keymap({ "n", "v" }, "d", [["+d]], opts)
keymap({ "n", "v" }, "D", [["+D]], opts)
keymap({ "n", "v" }, "x", [["+x]], opts)

-- Delete without copying to register (use black hole register)
keymap({ "n", "v" }, "<leader>d", "\"_d", opts)

-- Map Ctrl+C in insert mode to Esc (acts like exiting insert mode cleanly)
keymap("i", "<C-c>", "<Esc>", opts)
keymap("v", "<C-c>", "<Esc>", opts)
keymap("s", "<C-c>", "<Esc>", opts)

-- Disable the useless default Q (Ex mode)
keymap("n", "Q", "<nop>", opts)

-- Open a new tmux window with a project switcher (if using tmux-sessionizer)
keymap("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", opts)


-- Quickfix: go to next entry and center it
keymap("n", "<C-k>", "<cmd>cnext<CR>zz", opts)

keymap("n", "<C-l>", vim.diagnostic.open_float, opts)

-- Quickfix: go to previous entry and center it
keymap("n", "<C-j>", "<cmd>cprev<CR>zz", opts)

-- Location list: go to next entry and center it
keymap("n", "<leader>k", "<cmd>lnext<CR>zz", opts)

-- Location list: go to previous entry and center it
keymap("n", "<leader>j", "<cmd>lprev<CR>zz", opts)

-- Search and replace the word under cursor throughout file (with live editing)
keymap("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], opts)

keymap("n", "<leader>tt", "<cmd>ToggleTerm<CR>", opts)
keymap("t", "<Esc>", [[<C-\><C-n>]], opts)
keymap("i", "<C-e>", function()
    vim.lsp.buf.execute_command({
        command = "_emmet.expandAbbreviation",
        arguments = {
            vim.api.nvim_get_current_line(),
        },
    })
end, opts)

keymap("n", "<leader>+", ":vertical resize +10<CR>", opts)
keymap("n", "<leader>-", ":vertical resize -10<CR>", opts)
keymap("n", "<leader>=", "<C-w>=", opts)
