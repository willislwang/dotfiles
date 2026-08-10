local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = " "

opt.clipboard = "unnamedplus"
opt.completeopt = { "menu", "menuone", "noselect" }
opt.conceallevel = 2
opt.expandtab = true
opt.foldlevel = 99
opt.foldmethod = "indent"
opt.ignorecase = true
opt.list = true
opt.listchars = { tab = "| ", trail = ".", extends = ">", precedes = "<", nbsp = "+" }
opt.mouse = "a"
opt.number = true
opt.relativenumber = true
opt.scrolloff = 8
opt.shiftwidth = 2
opt.signcolumn = "yes"
opt.smartcase = true
opt.softtabstop = 2
opt.splitbelow = true
opt.splitright = true
opt.tabstop = 2
opt.termguicolors = true
opt.undofile = true
opt.updatetime = 250
opt.wrap = false
