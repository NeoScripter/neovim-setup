vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.wrap = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
-- vim.opt.colorcolumn = "80"

vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch", -- highlight group (can change to Visual, Search, etc.)
            timeout = 200,         -- duration in milliseconds
        })
    end,
})

vim.diagnostic.config({
    virtual_text = true,   -- inline red squiggles
    float = {
        source = "always", -- show source (e.g., eslint)
        max_width = 80,
        wrap = true
    },
    signs = true, -- show signs in gutter
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})
