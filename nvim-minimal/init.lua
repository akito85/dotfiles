-- ~/.config/nvim/init.lua
-- Main entry point for Neovim configuration

-- Set leader key (must be set before plugins and keymaps)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Load core modules
require('core')

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require('plugins')

-- Display startup performance metrics
vim.defer_fn(function()
  if _G.check_memory_usage then _G.check_memory_usage() end
end, 500)

