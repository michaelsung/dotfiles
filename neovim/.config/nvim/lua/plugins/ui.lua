return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        config = function()
            require("catppuccin").setup({
                show_end_of_buffer = true,
                integrations = {
                    gitsigns = true,
                    leap = true,
                    markdown = true,
                    mason = true,
                    mini = true,
                    nvimtree = true,
                    telescope = true,
                    treesitter = true,
                    which_key = true,
                },
                highlight_overrides = {
                    all = function(colors)
                        return {
                            LineNr = { fg = colors.lavender }, -- replace "some_color" with the color you want from the palette
                            CursorLineNr = { fg = colors.blue }
                        }
                    end,
                }
            })
            vim.cmd.colorscheme "catppuccin"
        end,
    },
    {
        'echasnovski/mini.statusline',
        config = function()
            require('mini.statusline').setup()
        end
    },
    {
        'petertriho/nvim-scrollbar',
        dependencies = { "lewis6991/gitsigns.nvim" },
        config = function()
            require('scrollbar').setup()
            require("scrollbar.handlers.gitsigns").setup()
        end
    },
    {
        'echasnovski/mini.indentscope',
        version = '*',
        config = function()
            local MiniIndentscope = require("mini.indentscope")
            MiniIndentscope.setup({
                options = {
                    try_as_border = true,
                },
                draw = {
                    animation = MiniIndentscope.gen_animation.quadratic({
                        easing = 'out',
                        duration = 80,
                        unit = 'total'
                    })
                },
                symbol = '│'
            })
        end
    },
    {
        'echasnovski/mini.starter',
        version = '*',
        config = function()
            require("mini.starter").setup()
        end
    },
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            vim.keymap.set('n', '<leader>pt', '<Cmd>NvimTreeToggle<CR>', { desc = "Open Nvim Tree" })
            require("nvim-tree").setup()
        end,
    },
}
