-- ~/.config/nvim/lua/core/performance.lua
-- Performance optimizations for Neovim - Aligned with TreeSitter config

-- UNIFIED FILE SIZE THRESHOLDS (aligned across all configs)
local SMALL_FILE_THRESHOLD = 512 * 1024        -- 512KB - full features
local MEDIUM_FILE_THRESHOLD = 5 * 1024 * 1024  -- 5MB - reduce textobjects
local LARGE_FILE_THRESHOLD = 50 * 1024 * 1024  -- 50MB - minimal TreeSitter
local HUGE_FILE_THRESHOLD = 500 * 1024 * 1024  -- 500MB - disable TreeSitter

-- Make thresholds globally available
_G.PERFORMANCE_THRESHOLDS = {
  SMALL = SMALL_FILE_THRESHOLD,
  MEDIUM = MEDIUM_FILE_THRESHOLD,
  LARGE = LARGE_FILE_THRESHOLD,
  HUGE = HUGE_FILE_THRESHOLD,
}

-- Helper function to get file size safely
local function get_file_size(buf)
  local name = vim.api.nvim_buf_get_name(buf or 0)
  if name == "" then return 0 end
  local size = vim.fn.getfsize(name)
  return size > 0 and size or 0
end

-- Determine performance tier for a buffer
local function get_performance_tier(buf)
  local filesize = get_file_size(buf)
  
  if filesize <= SMALL_FILE_THRESHOLD then
    return "SMALL", "Full features enabled"
  elseif filesize <= MEDIUM_FILE_THRESHOLD then
    return "MEDIUM", "Optimized for medium files"
  elseif filesize <= LARGE_FILE_THRESHOLD then
    return "LARGE", "Basic features only"
  else
    return "HUGE", "Maximum performance mode"
  end
end

-- Disable treesitter globally - must be set before plugins are loaded
-- This will be overridden by the TreeSitter plugin configuration
vim.g.loaded_nvim_treesitter = 1
vim.g.do_filetype_lua = 1
vim.g.did_load_filetypes = 1
vim.g.loaded_ts_parsers = 1

-- Ensure vim knows we prefer legacy syntax as fallback
vim.g.syntax_on = 1
vim.g.syntax_lua = 1

-- CRITICAL PERFORMANCE ENHANCEMENTS - Base settings
vim.opt.history = 100
vim.opt.complete:remove('i')
vim.opt.synmaxcol = 200  -- Will be adjusted per file size
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

-- Store original settings for toggle functionality
vim.g.original_settings = {
  number = vim.opt.number:get(),
  relativenumber = vim.opt.relativenumber:get(),
  signcolumn = vim.opt.signcolumn:get(),
  cursorline = vim.opt.cursorline:get(),
  autoindent = vim.opt.autoindent:get(),
  smartindent = vim.opt.smartindent:get(),
  syntax = true,
}

-- TIERED PERFORMANCE MANAGEMENT
local function apply_performance_tier(buf, tier)
  local bufnr = buf or vim.api.nvim_get_current_buf()
  local filesize = get_file_size(bufnr)
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
  
  if tier == "SMALL" then
    -- Small files: full performance, no restrictions
    vim.bo[bufnr].synmaxcol = 0 -- No limit
    vim.o.eventignore = ""
    vim.bo[bufnr].swapfile = true
    vim.bo[bufnr].undofile = true
    vim.bo[bufnr].undolevels = 1000
    
  elseif tier == "MEDIUM" then
    -- Medium files: balanced performance
    vim.bo[bufnr].synmaxcol = 300
    vim.o.eventignore = ""
    vim.bo[bufnr].swapfile = true
    vim.bo[bufnr].undofile = true
    vim.bo[bufnr].undolevels = 500
    vim.notify(string.format("Medium file optimizations applied: %s (%.1fMB)", 
      filename, filesize / 1024 / 1024), vim.log.levels.INFO)
    
  elseif tier == "LARGE" then
    -- Large files: reduced features
    vim.bo[bufnr].synmaxcol = 200
    vim.o.eventignore = "FileType,BufEnter,WinEnter,CmdwinEnter"
    vim.bo[bufnr].swapfile = false
    vim.bo[bufnr].undofile = false
    vim.bo[bufnr].undolevels = 100
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = "no"
    vim.wo.cursorline = false
    vim.wo.spell = false
    vim.wo.list = false
    vim.notify(string.format("Large file optimizations applied: %s (%.1fMB)", 
      filename, filesize / 1024 / 1024), vim.log.levels.WARN)
    
  else -- HUGE
    -- Huge files: maximum performance mode
    vim.bo[bufnr].synmaxcol = 0
    vim.o.eventignore = "all"
    vim.bo[bufnr].swapfile = false
    vim.bo[bufnr].undofile = false
    vim.bo[bufnr].undolevels = -1
    vim.bo[bufnr].lazyredraw = true
    vim.bo[bufnr].bufhidden = "unload"
    vim.bo[bufnr].foldmethod = "manual"
    vim.bo[bufnr].foldenable = false
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = "no"
    vim.wo.cursorline = false
    vim.wo.spell = false
    vim.wo.list = false
    vim.wo.conceallevel = 0
    
    -- Disable syntax highlighting for huge files
    vim.cmd('syntax clear')
    vim.cmd('syntax off')
    vim.cmd('filetype off')
    
    -- Detach LSP clients for huge files
    if vim.lsp then
      local clients = vim.lsp.get_active_clients({ buffer = bufnr })
      for _, client in pairs(clients) do
        vim.lsp.buf_detach_client(bufnr, client.id)
      end
    end
    
    vim.notify(string.format("Maximum performance mode: %s (%.1fMB)", 
      filename, filesize / 1024 / 1024), vim.log.levels.ERROR)
  end
  
  -- Store tier info in buffer variable
  vim.b[bufnr].performance_tier = tier
end
-- Auto-apply performance tiers on buffer read
local performance_group = vim.api.nvim_create_augroup("PerformanceManagement", { clear = true })

vim.api.nvim_create_autocmd({"BufReadPost", "BufNewFile"}, {
  group = performance_group,
  callback = function(ev)
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(ev.buf) then
        local tier, _ = get_performance_tier(ev.buf)
        apply_performance_tier(ev.buf, tier)
      end
    end, 100) -- Increased delay for stability
  end,
  desc = "Auto-apply performance tiers based on file size"
})

-- Cursor line performance - disable in insert mode
vim.api.nvim_create_autocmd({"InsertEnter"}, {
  group = performance_group,
  callback = function() 
    local tier = vim.b.performance_tier or "SMALL"
    if tier == "SMALL" or tier == "MEDIUM" then
      vim.opt.cursorline = false 
    end
  end
})

vim.api.nvim_create_autocmd({"InsertLeave"}, {
  group = performance_group,
  callback = function() 
    local tier = vim.b.performance_tier or "SMALL"
    if tier == "SMALL" or tier == "MEDIUM" then
      vim.opt.cursorline = true 
    end
  end
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

-- Enhanced garbage collection timer with tier awareness
local gc_timer = vim.loop.new_timer()
gc_timer:start(30000, 30000, vim.schedule_wrap(function()
  -- More aggressive GC for large files
  local current_buf = vim.api.nvim_get_current_buf()
  local tier = vim.b[current_buf].performance_tier or "SMALL"
  
  if tier == "LARGE" or tier == "HUGE" then
    collectgarbage("collect")
    collectgarbage("collect") -- Double collection for large files
  else
    collectgarbage("collect")
  end
end))

-- ENHANCED USER COMMANDS
vim.api.nvim_create_user_command("CheckMemory", function()
  _G.check_memory_usage()
end, { desc = "Check current memory usage" })

vim.api.nvim_create_user_command("PerformanceStatus", function()
  local buf = vim.api.nvim_get_current_buf()
  local filesize = get_file_size(buf)
  local tier, description = get_performance_tier(buf)
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
  
  print("=== Performance Status ===")
  print(string.format("File: %s", filename))
  print(string.format("Size: %.2f KB (%.2f MB)", filesize / 1024, filesize / 1024 / 1024))
  print(string.format("Tier: %s - %s", tier, description))
  print(string.format("Thresholds: Small=%.0fKB, Medium=%.0fMB, Large=%.0fMB, Huge=%.0fMB",
    SMALL_FILE_THRESHOLD / 1024,
    MEDIUM_FILE_THRESHOLD / 1024 / 1024,
    LARGE_FILE_THRESHOLD / 1024 / 1024,
    HUGE_FILE_THRESHOLD / 1024 / 1024))
  
  -- Show current buffer settings
  print("\nCurrent Settings:")
  print(string.format("  synmaxcol: %s", vim.bo.synmaxcol))
  print(string.format("  swapfile: %s", vim.bo.swapfile))
  print(string.format("  undofile: %s", vim.bo.undofile))
  print(string.format("  undolevels: %s", vim.bo.undolevels))
end, { desc = "Show detailed performance status" })

vim.api.nvim_create_user_command("OptimizeBuffer", function()
  local buf = vim.api.nvim_get_current_buf()
  local tier, _ = get_performance_tier(buf)
  apply_performance_tier(buf, tier)
  vim.notify("Buffer performance optimized for tier: " .. tier, vim.log.levels.INFO)
end, { desc = "Manually optimize current buffer performance" })

vim.api.nvim_create_user_command("ProfileStart", function()
  vim.cmd('profile start profile.log')
  vim.cmd('profile func *')
  vim.cmd('profile file *')
  vim.notify('Profiling started', vim.log.levels.INFO)
end, { desc = "Start performance profiling" })

vim.api.nvim_create_user_command("ProfileStop", function()
  vim.cmd('profile stop')
  vim.notify('Profiling stopped and saved to profile.log', vim.log.levels.INFO)
end, { desc = "Stop performance profiling" })

vim.api.nvim_create_user_command("MemoryUsage", function()
  local memory = vim.fn.system('ps -o rss= -p ' .. vim.fn.getpid()):gsub("%s+", "")
  local memory_mb = tonumber(memory) / 1024
  vim.notify(string.format('Neovim memory usage: %.2f MB', memory_mb), vim.log.levels.INFO)
end, { desc = "Show detailed memory usage" })

-- Enhanced toggle command with tier awareness
vim.api.nvim_create_user_command("TogglePerformance", function()
  local buf = vim.api.nvim_get_current_buf()
  local current_tier = vim.b[buf].performance_tier or "SMALL"
  
  if vim.b.optimized_for_performance then
    -- Restore to automatic tier-based settings
    local tier, _ = get_performance_tier(buf)
    apply_performance_tier(buf, tier)
    vim.b.optimized_for_performance = false
    vim.notify(string.format('Performance settings restored to %s tier', tier), vim.log.levels.INFO)
  else
    -- Force maximum performance
    apply_performance_tier(buf, "HUGE")
    vim.b.optimized_for_performance = true
    vim.notify('Maximum performance mode enabled', vim.log.levels.INFO)
  end
end, { desc = "Toggle between automatic and maximum performance" })

-- Legacy commands for backward compatibility
vim.api.nvim_create_user_command("MaxPerformance", function()
  local buf = vim.api.nvim_get_current_buf()
  apply_performance_tier(buf, "HUGE")
  vim.notify('Maximum performance mode enabled for current buffer', vim.log.levels.INFO)
end, { desc = "Enable maximum performance mode" })

vim.api.nvim_create_user_command("ViewBinary", function()
  vim.cmd('edit ++bin')
  vim.opt_local.display = "uhex"
  -- Force huge file tier for binary files
  apply_performance_tier(0, "HUGE")
  vim.notify('Binary view mode enabled with maximum performance', vim.log.levels.INFO)
end, { desc = "Enable binary view mode" })

-- Cleanup on buffer leave for large files
vim.api.nvim_create_autocmd("BufWinLeave", {
  group = performance_group,
  callback = function()
    local filesize = get_file_size()
    if filesize > MEDIUM_FILE_THRESHOLD then
      vim.defer_fn(function()
        collectgarbage("collect")
      end, 100)
    end
  end,
  desc = "Cleanup memory when leaving large buffers"
})
