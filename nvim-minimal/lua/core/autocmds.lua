local large_file = require('utils.large_file')

-- Handle file size optimizations
vim.api.nvim_create_autocmd({"BufReadPre"}, {
  pattern = "*",
  callback = function(ev)
    large_file.optimize_for_file_size(ev.file)
  end,
})

-- Add multiple layers of protection against Tree-sitter Lua parser errors
vim.api.nvim_create_autocmd({"BufReadPre", "BufNewFile"}, {
  pattern = "*.lua",
  callback = function()
    -- Set these variables before any ftplugin runs
    vim.b.did_ftplugin_treesitter_lua = 1
    
    -- Disable treesitter for Lua files in Neovim 0.11
    if vim.treesitter and vim.treesitter.stop then
      pcall(function() vim.treesitter.stop("lua") end)
    end
    
    -- Alternative approach for Neovim 0.11
    if vim.treesitter and vim.treesitter.highlighter then
      pcall(function()
        local highlighter = vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()]
        if highlighter then
          highlighter:destroy()
        end
      end)
    end
    
    -- Set syntax highlighting explicitly
    vim.cmd("syntax enable")
    vim.cmd("set syntax=lua")
  end,
  group = ts_fix_group,
  desc = "Disable treesitter for Lua files",
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
      
      -- Disable treesitter for this buffer in Neovim 0.11
      if vim.treesitter and vim.treesitter.stop then
        pcall(function() vim.treesitter.stop("lua", args.buf) end)
      end
      
      -- Alternative approach for Neovim 0.11
      if vim.treesitter and vim.treesitter.highlighter then
        pcall(function()
          local highlighter = vim.treesitter.highlighter.active[args.buf]
          if highlighter then
            highlighter:destroy()
          end
        end)
      end
    end
  end,
  group = ts_fix_group,
  desc = "Handle Lua files in Neo-tree",
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
    -- Don't use vim.treesitter.stop() as it doesn't exist
    -- Instead, make sure treesitter is not used
    if vim.bo.filetype == '' then
      vim.bo.filetype = 'text'
    end
  end,
  desc = "Set default filetype for empty buffers",
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

      -- Disable treesitter for this buffer properly
      if vim.treesitter and vim.treesitter.language then
        pcall(function() vim.treesitter.language.require_language("lua", nil) end)
      end
    end
  end,
  group = ts_fix_group,
  desc = "Handle Lua files in Neo-tree",
})

-- Performance autocmds
local autocmd_group = vim.api.nvim_create_augroup("PerformanceAutocmds", { clear = true })

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = autocmd_group,
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
  group = autocmd_group,
  pattern = "*",
  callback = function()
    if vim.fn.exists("g:auto_session_enabled") == 1 and vim.g.auto_session_enabled then
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
