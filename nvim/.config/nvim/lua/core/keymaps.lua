local map = vim.keymap.set

map("n", "<leader>n", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>p", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>d", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "<C-a>", "ggVG", { desc = "Select all" })
map("x", "p", '"_dP', { desc = "Paste without replacing clipboard" })
