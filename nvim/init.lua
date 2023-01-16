--[[ init.lua ]]

-- LEADER
-- These keybindings need to be defined before the first /
-- is called; otherwise, it will default to "\"
-- vim.g.mapleader = ","
-- vim.g.localleader = "\\"

-- IMPORTS
-- require('vars')      -- Variables
-- require('opts')      -- Options
-- require('keys')      -- Keymaps
-- require('plug')      -- Plugins
--
require("akito.plugins-setup")
require("akito.core.options")
require("akito.core.keymaps")
--require("akito.core.colorscheme")
require("akito.plugins.comment")
require("akito.plugins.nvim-tree")
require("akito.plugins.lualine")
require("akito.plugins.telescope")
require("akito.plugins.nvim-cmp")
require("akito.plugins.lsp.mason")
require("akito.plugins.lsp.lspsaga")
require("akito.plugins.lsp.lspconfig")
require("akito.plugins.lsp.null-ls")
require("akito.plugins.autopairs")
require("akito.plugins.treesitter")
require("akito.plugins.gitsigns")
require("akito.plugins.glance")
