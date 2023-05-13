-- stock vim key bindings
vim.g.mapleader = " "
-- vim.keymap.set("n", "<leader>a", function() print "hi" end, { desc = "test leader bind" })
-- vim.keymap.set("n", "<leader>pv", "<Cmd>Vex<CR>", { desc = "NetRW (Vertical split)" })
vim.keymap.set("n", "<leader>pq", "<Cmd>bp|bd #<CR>", { desc = "Buffer close" })
