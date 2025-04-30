-- Place this at the very top of your init.lua

-- Immediately disable Tree-sitter for Lua
vim.g.loaded_lua_treesitter = 1  -- Custom variable to signal our override

-- Create a minimal ftplugin replacement for Lua
local lua_ftplugin_path = vim.fn.stdpath("config") .. "/ftplugin/lua.lua"
local lua_ftplugin_dir = vim.fn.stdpath("config") .. "/ftplugin"

-- Create directory if it doesn't exist
if vim.fn.isdirectory(lua_ftplugin_dir) == 0 then
  vim.fn.mkdir(lua_ftplugin_dir, "p")
end

-- Write our own minimal ftplugin for Lua that doesn't use Tree-sitter
local minimal_ftplugin = [[
-- Minimal Lua ftplugin without Tree-sitter
vim.b.did_ftplugin_treesitter_lua = 1
vim.bo.syntax = "lua"
vim.bo.commentstring = "-- %s"
vim.bo.smartindent = true
]]

-- Write the file if it doesn't exist
if vim.fn.filereadable(lua_ftplugin_path) == 0 then
  local file = io.open(lua_ftplugin_path, "w")
  if file then
    file:write(minimal_ftplugin)
    file:close()
  end
end

-- Block the built-in ftplugin with a high priority autocmd
local ftplugin_block_group = vim.api.nvim_create_augroup("BlockBuiltinLuaFtplugin", { clear = true })

-- Block the built-in ftplugin from loading
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    -- Set variables to prevent built-in ftplugin from using Tree-sitter
    vim.b.did_ftplugin = 1  -- Mark ftplugin as already loaded
    vim.b.did_ftplugin_treesitter_lua = 1  -- Specific to Lua Tree-sitter
    
    -- Force traditional syntax
    vim.bo.syntax = "lua"
    
    -- Explicitly disable Tree-sitter for this buffer
    pcall(function() vim.treesitter.stop() end)
  end,
  once = false,  -- Apply to every Lua file
  desc = "Block built-in Lua ftplugin that uses Tree-sitter",
  group = ftplugin_block_group,
})

-- Override the runtime path to prefer our custom ftplugin
vim.opt.runtimepath:prepend(vim.fn.stdpath("config"))

-- Also handle buffer creation events
vim.api.nvim_create_autocmd({"BufNew", "BufAdd"}, {
  pattern = "*.lua",
  callback = function()
    vim.b.did_ftplugin_treesitter_lua = 1
  end,
  group = ftplugin_block_group,
})