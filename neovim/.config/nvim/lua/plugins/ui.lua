return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        config = function()
            require("catppuccin").setup()
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
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            require("indent_blankline").setup()
        end
    },
    {
        'akinsho/bufferline.nvim',
        version = "*",
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            vim.keymap.set('n', '<leader>bl', '<Cmd>BufferLineCycleNext<CR>', { desc = "Bufferline: Cycle next" })
            vim.keymap.set('n', '<leader>bh', '<Cmd>BufferLineCyclePrev<CR>', { desc = "Bufferline: Cycle previous" })
            require("bufferline").setup()
        end,
    },
}
