vim.g.mapleader = " "
vim.keymap.set("n", "<leader>bq", "<Cmd>bp|bd #<CR>", { desc = "Buffer close" })
vim.keymap.set("n", "<leader>ba", "<Cmd>%bd|e#|bd#<CR>", { desc = "Close all buffers except current" })
vim.keymap.set({ "i", "v" }, "<C-c>", "<Esc>",
    { desc = "Remap CTRL+c to Escape to trigger LSP when exiting insert mode" })
vim.keymap.set("n", "<C-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("n", "<C-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("i", "<C-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down in insert mode" })
vim.keymap.set("i", "<C-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up in insert mode" })
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })
