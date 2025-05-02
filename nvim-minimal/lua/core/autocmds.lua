local large_file = require('utils.large_file')

-- Create a dedicated autocommand group for TreeSitter fixes
local ts_fix_group = vim.api.nvim_create_augroup("TsLuaFix", { clear = true })

-- Function to ensure native syntax highlighting is properly enabled
local function ensure_native_syntax(bufnr)
  -- Make sure syntax is enabled globally
  vim.cmd("syntax enable")

  -- Set buffer-specific syntax
  vim.api.nvim_buf_set_option(bufnr, "syntax", "lua")

  -- Force re-detection of syntax
  vim.cmd("doautocmd Syntax lua")

  -- Ensure FileType hooks run properly
  vim.cmd("doautocmd FileType lua")
end

-- Modern approach to disable TreeSitter for Lua files in Neovim 0.11
vim.api.nvim_create_autocmd({"BufReadPre", "BufNewFile"}, {
  pattern = "*.lua",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()

    -- Set these variables before any ftplugin runs
    vim.b.did_ftplugin_treesitter_lua = 1

    -- Disable TreeSitter for this buffer (Neovim 0.11 method)
    if vim.treesitter then
      pcall(function()
        -- Remove the TreeSitter parser from this buffer
        if vim.treesitter.get_parser and vim.treesitter.get_parser(bufnr) then
          vim.treesitter.get_parser(bufnr):destroy()
        end

        -- Prevent TreeSitter from re-attaching
        vim.b.no_treesitter = true

        -- Ensure native syntax highlighting is enabled
        ensure_native_syntax(bufnr)
      end)
    end
  end,
  group = ts_fix_group,
  desc = "Disable TreeSitter for Lua files",
})

-- Handle new buffers for Lua files
vim.api.nvim_create_autocmd("BufAdd", {
  pattern = "*",
  callback = function(args)
    -- Check if the buffer is a Lua file
    if vim.fn.fnamemodify(vim.api.nvim_buf_get_name(args.buf), ":e") == "lua" then
      -- Apply fix to the new buffer
      vim.b[args.buf].did_ftplugin_treesitter_lua = 1
      vim.b[args.buf].no_treesitter = true

      -- Disable TreeSitter for this buffer if it exists
      pcall(function()
        if vim.treesitter.get_parser and vim.treesitter.get_parser(args.buf) then
          vim.treesitter.get_parser(args.buf):destroy()
        end
      end)
    end
  end,
  group = ts_fix_group,
  desc = "Handle Lua files in buffers",
})

-- Ensure native syntax highlighting is applied after TreeSitter is disabled
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()

    -- If we've marked this buffer to avoid TreeSitter
    if vim.b.no_treesitter then
      -- Small delay to ensure this happens after any treesitter setup
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          ensure_native_syntax(bufnr)
        end
      end, 10)
    end
  end,
  group = ts_fix_group,
  desc = "Ensure native syntax highlighting for Lua",
})

-- Add a fallback for any case where syntax might be disabled
vim.api.nvim_create_autocmd("Syntax", {
  pattern = "lua",
  callback = function()
    -- If highlighting seems missing
    if vim.b.no_treesitter and not vim.b.current_syntax then
      ensure_native_syntax(vim.api.nvim_get_current_buf())
    end
  end,
  group = ts_fix_group,
  desc = "Fallback syntax restoration",
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
