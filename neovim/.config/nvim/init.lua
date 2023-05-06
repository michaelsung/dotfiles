vim.g.mapleader=" "
vim.keymap.set("n", "<leader>a", function() print "hi" end, { desc = "test leader bind" })

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.scrolloff = 12

vim.opt.syntax = 'on'
vim.opt.termguicolors = true

-- setting correct colour appearance in tmux - https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
-- You might have to force true color when using regular vim inside tmux as the
-- colorscheme can appear to be grayscale with "termguicolors" option enabled.
vim.api.nvim_exec([[
if !has('gui_running') && &term =~ '^\%(screen\|tmux\)'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
]], false)

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

require("lazy").setup({
    { "catppuccin/nvim", name = "catppuccin" },
    { "folke/which-key.nvim",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup()
    end,
    },
})

vim.cmd.colorscheme "catppuccin"
