return {
    --[[ {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
            vim.keymap.set('n', '<leader>pv', '<Cmd>NvimTreeToggle<CR>', { desc = "NvimTree: Toggle open" })
            require("nvim-tree").setup()
        end,
    }, ]]
    {
        'stevearc/oil.nvim',
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
            vim.keymap.set('n', '<leader>pv', '<C-w>v<Cmd>Oil<CR>', { desc = "Open Oil file explorer" })
            require("oil").setup({
                view_options = {
                    show_hidden = true
                }
            })
        end
    },
    {
        'akinsho/bufferline.nvim',
        version = "*",
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            vim.keymap.set('n', '<leader>l', '<Cmd>BufferLineCycleNext<CR>', { desc = "Bufferline: Cycle next" })
            vim.keymap.set('n', '<leader>h', '<Cmd>BufferLineCyclePrev<CR>', { desc = "Bufferline: Cycle previous" })
            require("bufferline").setup()
        end,
    },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.1',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Telescope: Find files" })
            vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = "Telescope: Git files" })
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Telescope: Live grep" })
            vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Telescope: Buffers" })
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Telescope: Help tags" })
            vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = "Telescope: References" })
            require("telescope").setup()
        end,
    },
}
