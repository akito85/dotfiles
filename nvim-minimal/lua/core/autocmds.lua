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

-- Create a dedicated group for Tree-sitter fixes
local ts_fix_group = vim.api.nvim_create_augroup("TreesitterFixes", { clear = true })

-- Add multiple layers of protection against Tree-sitter Lua parser errors
vim.api.nvim_create_autocmd({"BufReadPre", "BufNewFile"}, {
  pattern = "*.lua",
  callback = function()
    -- Set these variables before any ftplugin runs
    vim.b.did_ftplugin_treesitter_lua = 1
  end,
  group = ts_fix_group,
})

-- Add additional fix for Neo-tree buffer handling
vim.api.nvim_create_autocmd("BufAdd", {
  pattern = "*",
  callback = function(args)
    -- Check if the buffer is a Lua file
    if vim.fn.fnamemodify(vim.api.nvim_buf_get_name(args.buf), ":e") == "lua" then
      -- Apply fix to the new buffer
      vim.b.did_ftplugin_treesitter_lua = 1
      
      -- Force vim's traditional syntax highlighting 
      vim.api.nvim_buf_set_option(args.buf, "syntax", "lua")
    end
  end,
  group = ts_fix_group,
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
