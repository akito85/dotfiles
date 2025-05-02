local large_file = require('utils.large_file')

-- Create an autocommand group for our syntax fixes
local syntax_fix_group = vim.api.nvim_create_augroup("SyntaxFix", { clear = true })

-- Force syntax on after VimEnter to ensure it's not disabled by any plugin
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Enable syntax globally
    vim.cmd("syntax on")
    
    -- Set syntax settings that might help with edge cases
    vim.opt.synmaxcol = 3000  -- Avoid syntax timeout on long lines
    
    -- Force syntax reload for all existing buffers
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(bufnr) then
        local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
        if ft and ft ~= "" then
          -- Reset syntax for this buffer
          vim.api.nvim_buf_call(bufnr, function()
            vim.cmd("syntax clear")
            vim.cmd("syntax enable")
            vim.cmd("doautocmd Syntax " .. ft)
          end)
        end
      end
    end
  end,
  group = syntax_fix_group,
  desc = "Ensure syntax highlighting is enabled globally",
})

-- Ensure syntax is enabled for each buffer when filetype is set
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
    
    -- Skip empty filetypes
    if not ft or ft == "" then
      return
    end
    
    -- Ensure syntax for this filetype
    vim.api.nvim_buf_call(bufnr, function()
      -- Force native syntax highlighting
      vim.cmd("syntax enable")
      
      -- Handle special case for Lua
      if ft == "lua" then
        -- Additional settings specific to Lua
        vim.b[bufnr].current_syntax = "lua"
        vim.cmd("runtime! syntax/lua.vim")
      end
      
      -- Reload syntax for this filetype
      vim.cmd("doautocmd Syntax " .. ft)
    end)
  end,
  group = syntax_fix_group,
  desc = "Ensure syntax highlighting when filetype is set",
})

-- Add a safety check for any buffer that seems to be missing syntax
vim.api.nvim_create_autocmd({"BufWinEnter", "BufEnter"}, {
  pattern = "*",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
    
    -- Skip empty filetypes or special buffers
    if not ft or ft == "" or ft:match("^%s*$") then
      return
    end
    
    -- Check if syntax appears to be missing (no current_syntax set)
    if not vim.b[bufnr].current_syntax then
      vim.api.nvim_buf_call(bufnr, function()
        -- Force native syntax highlighting
        vim.cmd("syntax enable")
        vim.cmd("runtime! syntax/" .. ft .. ".vim")
        vim.cmd("doautocmd Syntax " .. ft)
      end)
    end
  end,
  group = syntax_fix_group,
  desc = "Safety check for missing syntax highlighting",
})

-- Add specific handler for Lua files
vim.api.nvim_create_autocmd({"BufReadPre", "BufNewFile", "BufEnter"}, {
  pattern = "*.lua",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    
    -- Force Lua syntax
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd("syntax enable")
      vim.cmd("runtime! syntax/lua.vim")
      
      -- Ensure standard Lua filetype settings
      vim.bo.syntax = "lua"
      vim.b.current_syntax = "lua"
    end)
  end,
  group = syntax_fix_group,
  desc = "Special handling for Lua files",
})

-- Display startup time
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
  desc = "Display startup time",
})

-- Manage cursor line in insert mode
vim.api.nvim_create_autocmd({"InsertEnter"}, {
  callback = function() vim.opt.cursorline = false end,
  desc = "Hide cursor line in insert mode",
})

vim.api.nvim_create_autocmd({"InsertLeave"}, {
  callback = function() vim.opt.cursorline = true end,
  desc = "Show cursor line outside insert mode",
})

-- For all buffers, set default filetype if empty
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*",
  callback = function()
    if vim.bo.filetype == '' then
      vim.bo.filetype = 'text'
    end
  end,
  desc = "Set default filetype for empty buffers",
})

-- Performance autocmds
local performance_group = vim.api.nvim_create_augroup("PerformanceAutocmds", { clear = true })

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = performance_group,
  pattern = "*",
  callback = function()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, cursor_pos)
  end,
  desc = "Remove trailing whitespace",
})

-- Auto save session
vim.api.nvim_create_autocmd("BufWritePost", {
  group = performance_group,
  pattern = "*",
  callback = function()
    if vim.g.auto_session_enabled then
      vim.cmd("silent! mksession! " .. vim.fn.stdpath("data") .. "/sessions/autosave.vim")
    end
  end,
  desc = "Auto save session",
})

-- Notify on large file mode
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    vim.defer_fn(function()
      if vim.b.large_file then
        vim.notify('Large file mode active - some features disabled', vim.log.levels.INFO)
      end
    end, 100)
  end,
  desc = "Large file notification",
})
