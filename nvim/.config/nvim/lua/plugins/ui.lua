return {
  {
    "tinted-theming/tinted-vim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("base16-tomorrow-night")
      vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
    end,
  },
  {
    "folke/which-key.nvim",
    lazy = false,
    opts = {},
  },
}
