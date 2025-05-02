-- ~/.config/nvim/lua/core/performance.lua
-- Performance optimizations for Neovim


-- Disable treesitter globally - must be set before plugins are loaded
vim.g.loaded_nvim_treesitter = 1
vim.g.do_filetype_lua = 1
vim.g.did_load_filetypes = 1
vim.g.loaded_ts_parsers = 1

-- Ensure vim knows we prefer legacy syntax
vim.g.syntax_on = 1
vim.g.syntax_lua = 1

-- CRITICAL PERFORMANCE ENHANCEMENTS
vim.opt.history = 100
vim.opt.complete:remove('i')
vim.opt.synmaxcol = 200
vim.opt.lazyredraw = true
vim.opt.redrawtime = 1500
vim.opt.wrapscan = false
vim.opt.maxmempattern = 1000
vim.opt.regexpengine = 1
vim.opt.fsync = false
vim.opt.ruler = false
vim.opt.sidescrolloff = 0
vim.opt.scrolljump = 5
vim.opt.ttyfast = true
vim.opt.ttimeoutlen = 10
vim.opt.timeoutlen = 500
vim.opt.startofline = true
vim.opt.display = "lastline"
vim.opt.shortmess:append("c")
vim.opt.cmdheight = 1
vim.opt.laststatus = 2
vim.opt.showcmd = false
vim.opt.timeout = true

-- Cursor line performance - disable in insert mode
vim.api.nvim_create_autocmd({"InsertEnter"}, {
  callback = function() vim.opt.cursorline = false end
})
vim.api.nvim_create_autocmd({"InsertLeave"}, {
  callback = function() vim.opt.cursorline = true end
})

-- HELPFUL COMMANDS FOR PERFORMANCE AND PROFILING
-- Display memory usage
function _G.check_memory_usage()
  local stats = vim.loop.resident_set_memory()
  local memory_mb = math.floor(stats / 1024 / 1024 * 100) / 100
  vim.notify(string.format("Neovim memory usage: %.2f MB", memory_mb), vim.log.levels.INFO)
  return memory_mb
end

-- Display startup time
function _G.display_startup_time()
  local startuptime = vim.fn.system("nvim --headless --noplugin --startuptime /tmp/nvim_startuptime -c 'quit' && tail -n 1 /tmp/nvim_startuptime | cut -d ' ' -f1"):gsub("%s+", "")
  vim.notify(string.format("Neovim startup time: %s ms", startuptime), vim.log.levels.INFO)
end

-- Garbage collection timer for better memory management
local gc_timer = vim.loop.new_timer()
gc_timer:start(30000, 30000, vim.schedule_wrap(function()
  collectgarbage("collect")
end))

-- Helpful performance user commands
vim.api.nvim_create_user_command("CheckMemory", function()
  _G.check_memory_usage()
end, {})

vim.api.nvim_create_user_command("ProfileStart", function()
  vim.cmd('profile start profile.log')
  vim.cmd('profile func *')
  vim.cmd('profile file *')
  vim.notify('Profiling started', vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command("ProfileStop", function()
  vim.cmd('profile stop')
  vim.notify('Profiling stopped and saved to profile.log', vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command("MemoryUsage", function()
  local memory = vim.fn.system('ps -o rss= -p ' .. vim.fn.getpid()):gsub("%s+", "")
  local memory_mb = tonumber(memory) / 1024
  vim.notify(string.format('Neovim memory usage: %.2f MB', memory_mb), vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command("TogglePerformance", function()
  if vim.b.optimized_for_performance then
    vim.opt_local.number = vim.g.original_settings.number
    vim.opt_local.relativenumber = vim.g.original_settings.relativenumber
    vim.opt_local.signcolumn = vim.g.original_settings.signcolumn
    vim.opt_local.cursorline = vim.g.original_settings.cursorline
    vim.opt_local.autoindent = vim.g.original_settings.autoindent
    vim.opt_local.smartindent = vim.g.original_settings.smartindent
    if vim.g.original_settings.syntax then
      vim.cmd('syntax on')
    end
    vim.b.optimized_for_performance = false
    vim.notify('Regular performance settings restored', vim.log.levels.INFO)
  else
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
    vim.opt_local.cursorline = false
    vim.opt_local.autoindent = false
    vim.opt_local.smartindent = false
    vim.opt_local.syntax = 'off'
    vim.cmd('syntax clear')
    vim.cmd('syntax off')
    vim.b.optimized_for_performance = true
    vim.notify('High performance mode enabled', vim.log.levels.INFO)
  end
end, {})

vim.api.nvim_create_user_command("MaxPerformance", function()
  vim.cmd('syntax clear')
  vim.cmd('syntax off')
  vim.cmd('filetype off')
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.signcolumn = 'no'
  vim.opt_local.cursorline = false
  vim.opt_local.spell = false
  vim.opt_local.list = false
  vim.opt_local.conceallevel = 0
  vim.opt_local.swapfile = false
  vim.opt_local.undofile = false
  vim.opt_local.undolevels = -1
  vim.opt_local.eventignore = 'all'
  vim.opt_local.lazyredraw = true
  vim.opt_local.bufhidden = 'unload'
  vim.opt_local.synmaxcol = 0
  vim.opt_local.foldmethod = 'manual'
  vim.opt_local.foldenable = false
  vim.opt_local.modifiable = true
  vim.opt_local.readonly = false
  if vim.lsp then
    local clients = vim.lsp.get_active_clients({ buffer = 0 })
    for _, client in pairs(clients) do
      vim.lsp.buf_detach_client(0, client.id)
    end
  end
  vim.notify('Maximum performance mode enabled for current buffer', vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command("ViewBinary", function()
  vim.cmd('edit ++bin')
  vim.opt_local.display = "uhex"
  vim.notify('Binary view mode enabled', vim.log.levels.INFO)
end, {})
