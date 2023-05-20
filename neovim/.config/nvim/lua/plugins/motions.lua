return {
    {
        "folke/which-key.nvim",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            require("which-key").setup()

            -- Register keymap group names
            local wk = require("which-key")
            wk.register({ ["<leader>"] = { b = { name = " Buffers" } } })
            wk.register({ ["<leader>"] = { p = { name = " Project management" } } })
        end,
    },
    {
        "ggandor/leap.nvim",
        dependencies = { "tpope/vim-repeat" },
        config = function()
            require("leap").add_default_mappings(true)
        end
    },
    {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }
}
