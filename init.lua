vim.g.mapleader = " "
vim.g.maplocalleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local shada_path = vim.fn.stdpath("data") .. "/shada"
for _, file in ipairs(vim.fn.glob(shada_path .. "/main.shada.tmp.*", true, true)) do
    vim.fn.delete(file)
end

vim.defer_fn(function()
    vim.cmd('redraw!')
end, 100)


require("lazy").setup("plugins")
require("settings")
require("lsp")
require("autocomplete")
require("keymaps")
require("nvim-autopairs").setup()
require("live-server")
require("nulls")
require("harpoon-config")
require("toggleterm").setup()
require("telescope").setup({
    defaults = {
        file_ignore_patterns = {
            "node_modules",
            ".git/",
            "dist/",
            "build/",
        },
    },
})
