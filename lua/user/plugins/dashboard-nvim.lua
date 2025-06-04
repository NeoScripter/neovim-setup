return {
    enabled = true,
    'glepnir/dashboard-nvim',
    opts = {
        theme = 'doom',
        config = {
            header = {
                '',
                '',
                '',
                '      ⢸⣦⡈⠻⣿⣿⣿⣶⣄      ',
                '      ⢸⣿⣿⣦⡈⠻⣿⣿⣿⣷⣄    ',
                '⣀⣀⣀⣀⣀⣀⣼⣿⣿⣿⣿ ⠈⠻⣿⣿⣿⣷⣄  ',
                '⠈⠻⣿⣿⣿⣿⣿⡿⠿⠛⠁   ⠈⠻⢿⣿⣿⣷⣄',
                '',
                '',
            },
            center = {
                {
                    icon = '  ',
                    desc = 'New file',
                    action = function() vim.cmd('enew') end
                },
                {
                    icon = '  ',
                    desc = 'Find file               ',
                    key = 'Space + f',
                    action = function()
                        require('telescope.builtin').find_files()
                    end,
                },
                {
                    icon = '  ',
                    desc = 'Recent files            ',
                    key = 'Space + h',
                    action = function()
                        require('telescope.builtin').oldfiles()
                    end,
                },
                {
                    icon = '  ',
                    desc = 'Find word               ',
                    key = 'Space + g',
                    action = function()
                        require('telescope.builtin').live_grep()
                    end,
                },            },
                footer = { '' }
            },
            hide = {
                statusline = false,
                tabline = false,
                winbar = false,
            }
        },
        init = function()
            vim.api.nvim_set_hl(0, 'DashboardHeader', { fg = '#6272a4' })
            vim.api.nvim_set_hl(0, 'DashboardDesc', { fg = '#f8f8f2' })
            vim.api.nvim_set_hl(0, 'DashboardIcon', { fg = '#bd93f9' })
            vim.api.nvim_set_hl(0, 'DashboardKey', { fg = '#6272a4' })
            vim.api.nvim_set_hl(0, 'DashboardFooter', { fg = '#6272a4' })
        end,
    }
