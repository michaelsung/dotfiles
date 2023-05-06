-- stock vim key bindings
vim.g.mapleader = " "
-- vim.keymap.set("n", "<leader>a", function() print "hi" end, { desc = "test leader bind" })
-- vim.keymap.set("n", "<leader>pv", "<Cmd>Vex<CR>", { desc = "NetRW (Vertical split)" })

-- vim settings - editor
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.scrolloff = 12

-- vim settings - appearance
vim.opt.syntax = "on"
vim.opt.termguicolors = true

-- setting correct colour appearance in tmux - https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
-- You might have to force true color when using regular vim inside tmux as the colorscheme can appear to be grayscale with "termguicolors" option enabled.
vim.api.nvim_exec([[
if !has('gui_running') && &term =~ '^\%(screen\|tmux\)'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
]], false)

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
    { "catppuccin/nvim", name = "catppuccin",
    config = function()
        vim.cmd.colorscheme "catppuccin"
        require("catppuccin").setup()
    end,
    },
    { "folke/which-key.nvim",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup()
    end,
    },
    { "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
    },
    {
    'nvim-telescope/telescope.nvim', tag = '0.1.1', 
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
    'akinsho/bufferline.nvim', version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
        vim.keymap.set('n', '<leader>l', '<Cmd>BufferLineCycleNext<CR>', { desc = "Bufferline: Cycle next" })
        vim.keymap.set('n', '<leader>h', '<Cmd>BufferLineCyclePrev<CR>', { desc = "Bufferline: Cycle previous" })
        require("bufferline").setup()
    end,
    },
    {
    "nvim-tree/nvim-tree.lua", version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
       vim.keymap.set('n', '<leader>pv', '<Cmd>NvimTreeToggle<CR>', { desc = "NvimTree: Toggle open" })
       require("nvim-tree").setup()
    end,
    }
})
