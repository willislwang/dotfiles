return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      explorer = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      picker = {
        enabled = true,
        sources = {
          explorer = {
            git_status = true,
            watch = true,
          },
        },
      },
    },
    keys = {
      { "<leader>e", function() Snacks.explorer() end, desc = "File explorer" },
      { "<C-n>", function() Snacks.explorer() end, desc = "File explorer (legacy)" },
      { "<leader>f", function() Snacks.picker.files() end, desc = "Find files" },
      { "<leader>s", function() Snacks.picker.grep() end, desc = "Search text" },
      { "<leader>b", function() Snacks.picker.buffers() end, desc = "Find buffers" },
      { "<C-Space>", function() Snacks.picker.files() end, desc = "Find files (legacy)" },
      { "<C-g>", function() Snacks.picker.grep() end, desc = "Search text (legacy)" },
    },
  },
}
