-- ~/.config/nvim/lua/core/init.lua
-- Loads all core configurations

-- Order matters!
require('core.performance') -- Load performance optimizations first
require('core.options')     -- Then general options
require('core.keymaps')     -- Then keybindings
require('core.autocmds')    -- Finally autocommands

