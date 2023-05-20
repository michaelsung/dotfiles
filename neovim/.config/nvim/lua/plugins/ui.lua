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
}
