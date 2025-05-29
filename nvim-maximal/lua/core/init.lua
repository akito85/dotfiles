-- ~/.config/nvim/lua/core/init.lua
-- Loads all core configurations

-- Order matters!
-- Load performance optimizations first

require('core.perf')

-- Optional: Set global variables for TreeSitter thresholds (if you want to customize them)
-- These should match the thresholds in your TreeSitter configuration
vim.g.LargeFile = 50  -- 50MB threshold for TreeSitter disable (50 * 1024 * 1024 bytes)

-- You can also create a simple status line function to show performance tier
local function get_performance_indicator()
  if vim.b.performance_tier then
    local indicators = {
      small = "",
      medium = "⚡",
      large = "🔥",
      huge = "💀",
      massive = "🚫"
    }
    return indicators[vim.b.performance_tier] or ""
  end
  return ""
end

-- vim.o.statusline = vim.o.statusline .. "%{v:lua.get_performance_indicator()}"

-- Optional: Global function to access performance indicator
_G.get_performance_indicator = get_performance_indicator

-- Quick performance check command for debugging
vim.api.nvim_create_user_command("PerfDebug", function()
  local buf = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(buf)
  local file_size = vim.fn.getfsize(file_path)

  print("=== Performance Debug Info ===")
  print("File:", vim.fn.fnamemodify(file_path, ":t"))
  print("Size:", file_size, "bytes")
  print("Tier:", vim.b.performance_tier or "unknown")
  print("Large file:", vim.b.large_file and "yes" or "no")
  print("TS highlight:", vim.b.ts_highlight and "enabled" or "disabled")

  -- Check TreeSitter status
  local ts_status = {}
  if pcall(require, "nvim-treesitter.configs") then
    local ts = require("nvim-treesitter.configs")
    print("TreeSitter loaded: yes")
  else
    print("TreeSitter loaded: no")
  end

  -- Memory usage
  local memory = vim.loop.resident_set_memory()
  print("Memory:", math.floor(memory / 1024 / 1024), "MB")
end, { desc = "Debug performance configuration" })


require('core.options')     -- Then general options
require('core.keymaps')     -- Then keybindings
require('core.autocmds')    -- Finally autocommands

