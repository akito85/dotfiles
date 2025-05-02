local large_file = require('utils.large_file')

-- Display loading time in ms
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
