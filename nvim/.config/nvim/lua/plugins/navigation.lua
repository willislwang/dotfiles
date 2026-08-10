return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      skip_confirm_for_simple_edits = true,
      view_options = { show_hidden = true },
    },
    keys = {
      { "<leader>e", "<cmd>Oil<cr>", desc = "File explorer" },
      { "<C-n>", "<cmd>Oil<cr>", desc = "File explorer (legacy)" },
    },
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      input = { enabled = true },
      notifier = { enabled = true },
      picker = { enabled = true },
    },
    keys = {
      { "<leader>f", function() Snacks.picker.files() end, desc = "Find files" },
      { "<leader>s", function() Snacks.picker.grep() end, desc = "Search text" },
      { "<leader>b", function() Snacks.picker.buffers() end, desc = "Find buffers" },
      { "<C-Space>", function() Snacks.picker.files() end, desc = "Find files (legacy)" },
      { "<C-g>", function() Snacks.picker.grep() end, desc = "Search text (legacy)" },
    },
  },
}
