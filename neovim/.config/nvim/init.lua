-- vim settings
require "config.keymaps"
require "config.editor"
require "config.appearance"
require "config.files"

-- plugin manager setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- plugins
require("lazy").setup({
    {
        "catppuccin/nvim",
        name = "catppuccin",
        config = function()
            require("catppuccin").setup()
            vim.cmd.colorscheme "catppuccin"
        end,
    },
    {
        "folke/which-key.nvim",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            require("which-key").setup()
        end,
    },
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup()
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
            require("telescope").setup()
        end,
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
        "nvim-tree/nvim-tree.lua",
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
            vim.keymap.set('n', '<leader>pv', '<Cmd>NvimTreeToggle<CR>', { desc = "NvimTree: Toggle open" })
            require("nvim-tree").setup()
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "javascript", "typescript", "lua", "vim", "vimdoc" },
                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,
                -- Automatically install missing parsers when entering buffer
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
            })
        end,
    },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' }, -- Required
            {
                'williamboman/mason.nvim',
                build = ":MasonUpdate"
            },
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional
            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },                  -- Required
            { 'hrsh7th/cmp-nvim-lsp' },              -- Required
            { 'L3MON4D3/LuaSnip' },                  -- Required
        },
        config = function()
            local lsp = require('lsp-zero').preset({})
            lsp.on_attach(function(_, bufnr)
                lsp.default_keymaps({ buffer = bufnr })
                lsp.buffer_autoformat()
            end)
            lsp.ensure_installed({
                'lua_ls',
                'yamlls',
                'tsserver',
                'eslint',
                'gopls',
            })
            -- (Optional) Configure lua language server for neovim
            require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
            lsp.setup()
            local cmp = require('cmp')
            cmp.setup({
                mapping = {
                    ['<CR>'] = cmp.mapping.confirm({ select = false }),
                },
                preselect = 'item',
                completion = {
                    completeopt = 'menu,menuone,noinsert'
                },
            })
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
})
