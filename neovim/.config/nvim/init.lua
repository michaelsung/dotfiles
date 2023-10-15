-- load config files in lua/config
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

local lazy = require("lazy")
-- load all plugin files in the lua/plugins folder.
lazy.setup("plugins", {
    defaults = { lazy = false },
})
