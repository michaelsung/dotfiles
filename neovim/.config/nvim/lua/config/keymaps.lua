vim.g.mapleader = " "
vim.keymap.set("n", "<leader>bq", "<Cmd>bp|bd #<CR>", { desc = "Buffer close" })
vim.keymap.set("n", "<leader>ba", "<Cmd>%bd|e#|bd#<CR>", { desc = "Close all buffers except current" })
