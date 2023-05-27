vim.g.mapleader = " "
vim.keymap.set("n", "<leader>bq", "<Cmd>bp|bd #<CR>", { desc = "Buffer close" })
vim.keymap.set("n", "<leader>ba", "<Cmd>%bd|e#|bd#<CR>", { desc = "Close all buffers except current" })
vim.keymap.set({ "i", "v" }, "<C-c>", "<Esc>",
    { desc = "Remap CTRL+c to Escape to trigger LSP when exiting insert mode" })
