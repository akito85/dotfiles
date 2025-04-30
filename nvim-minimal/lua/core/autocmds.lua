local large_file = require('utils.large_file')

vim.api.nvim_create_autocmd({"BufReadPre"}, {
  pattern = "*",
  callback = function(ev)
    large_file.optimize_for_file_size(ev.file)
  end,
})

local startup_time_displayed = false
local function display_startup_time()
  if not startup_time_displayed then
    local startuptime = vim.fn.system("nvim --headless --noplugin --startuptime /tmp/nvim_startuptime -c 'quit' && tail -n 1 /tmp/nvim_startuptime | cut -d ' ' -f1"):gsub("%s+", "")
    vim.notify(string.format("Neovim startup time: %s ms", startuptime), vim.log.levels.INFO)
    startup_time_displayed = true
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      display_startup_time()
    end, 100)
  end,
})

vim.api.nvim_create_autocmd({"InsertEnter"}, {
  callback = function() vim.opt.cursorline = false end
})
vim.api.nvim_create_autocmd({"InsertLeave"}, {
  callback = function() vim.opt.cursorline = true end
})

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*",
  callback = function()
    vim.treesitter.stop() -- Stop Tree-sitter for the current buffer
    if vim.bo.filetype == '' then
      vim.bo.filetype = 'text'
    end
  end,
})

-- Create augroups with clear=true to ensure our commands take precedence
local disable_lua_ts_group = vim.api.nvim_create_augroup("DisableLuaTreesitter", { clear = true })

-- Disable the built-in Lua ftplugin that tries to use Tree-sitter
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    -- Disable Tree-sitter for Lua specifically
    vim.treesitter.stop()
    
    -- Set a buffer variable to prevent Tree-sitter loading
    vim.b.ts_highlight = 0
    
    -- Force traditional syntax highlighting for Lua
    vim.bo.syntax = "lua"
    
    -- This prevents the built-in lua.lua ftplugin from running its Tree-sitter code
    vim.b.did_ftplugin_treesitter_lua = 1
  end,
  group = disable_lua_ts_group,
  desc = "Disable Tree-sitter for Lua files"
})

-- Preemptively set buffer variables before ftplugin runs
vim.api.nvim_create_autocmd({"BufReadPre", "BufNewFile"}, {
  pattern = "*.lua",
  callback = function()
    -- This prevents the built-in lua.lua ftplugin from running its Tree-sitter code
    vim.b.did_ftplugin_treesitter_lua = 1
  end,
  group = disable_lua_ts_group,
  desc = "Prevent Tree-sitter errors in Lua files"
})

-- In Neovim 0.11, you can also use the new filetype control features
vim.filetype.add({
  extension = {
    lua = function()
      vim.b.did_ftplugin_treesitter_lua = 1
      return "lua"
    end,
  },
})

local autocmd_group = vim.api.nvim_create_augroup("PerformanceAutocmds", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = autocmd_group,
  pattern = "*",
  callback = function()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, cursor_pos)
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = autocmd_group,
  pattern = "*",
  callback = function()
    if vim.fn.exists("g:auto_session_enabled") == 1 and vim.g.auto_session_enabled then
      vim.cmd("silent! mksession! " .. vim.fn.stdpath("data") .. "/sessions/autosave.vim")
    end
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    vim.defer_fn(function()
      if vim.b.large_file then
        vim.notify('Large file mode active - some features disabled', vim.log.levels.INFO)
      end
    end, 100)
  end,
})

function _G.check_memory_usage()
  local stats = vim.loop.resident_set_memory()
  local memory_mb = math.floor(stats / 1024 / 1024 * 100) / 100
  vim.notify(string.format("Neovim memory usage: %.2f MB", memory_mb), vim.log.levels.INFO)
  return memory_mb
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      _G.check_memory_usage()
    end, 500)
  end,
})

local gc_timer = vim.loop.new_timer()
gc_timer:start(30000, 30000, vim.schedule_wrap(function()
  collectgarbage("collect")
end))
