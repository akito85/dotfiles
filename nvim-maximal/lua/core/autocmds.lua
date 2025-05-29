-- Create an autocommand group for our syntax fixes
local syntax_fix_group = vim.api.nvim_create_augroup("SyntaxFix", { clear = true })

-- Languages we want to ensure have syntax highlighting
local target_languages = {
  lua = { extensions = { "lua" } },
  javascript = { extensions = { "js", "jsx", "mjs", "cjs" } },
  typescript = { extensions = { "ts", "tsx" } },
  rust = { extensions = { "rs" } },
  go = { extensions = { "go" } },
  python = { extensions = { "py", "pyw" } },
  julia = { extensions = { "jl" } },
  sql = { extensions = {"sql"} },
}

-- Function to safely check if treesitter is available for a filetype
local function has_treesitter_parser(lang)
  local ok, parsers = pcall(require, 'nvim-treesitter.parsers')
  if not ok then
    return false
  end
  return parsers.has_parser(lang)
end

-- Function to force syntax highlighting for a specific filetype
local function force_syntax(bufnr, filetype)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  -- Skip if treesitter is handling this filetype
  if has_treesitter_parser(filetype) then
    return
  end

  local success, err = pcall(function()
    vim.api.nvim_buf_call(bufnr, function()
      -- Clear any existing syntax to avoid conflicts
      vim.cmd("syntax clear")

      -- Enable syntax globally
      vim.cmd("syntax enable")

      -- Set buffer-specific syntax
      vim.bo.syntax = filetype

      -- Ensure the syntax file is loaded
      vim.cmd("runtime! syntax/" .. filetype .. ".vim")

      -- Set current_syntax to prevent reloading
      vim.b.current_syntax = filetype

      -- Force syntax events
      vim.cmd("doautocmd Syntax " .. filetype)
    end)
  end)

  if not success then
    vim.notify("Failed to force syntax for " .. filetype .. ": " .. (err or "unknown error"), vim.log.levels.WARN)
  end
end

-- Force syntax on after VimEnter to ensure it's not disabled by any plugin
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Enable syntax globally
    vim.cmd("syntax on")

    -- Set syntax settings that might help with edge cases
    vim.opt.synmaxcol = 3000  -- Avoid syntax timeout on long lines

    -- Force syntax reload for all existing buffers (with delay to let treesitter load)
    vim.defer_fn(function()
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) then
          local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
          if ft and ft ~= "" then
            force_syntax(bufnr, ft)
          end
        end
      end
    end, 200) -- Delay to let treesitter initialize
  end,
  group = syntax_fix_group,
  desc = "Ensure syntax highlighting is enabled globally",
})

-- Create pattern matching for our target language extensions
local file_patterns = {}
for lang, info in pairs(target_languages) do
  for _, ext in ipairs(info.extensions) do
    table.insert(file_patterns, "*." .. ext)
  end
end

-- Special handling for target language files (less aggressive approach)
vim.api.nvim_create_autocmd({"BufReadPost"}, {  -- Changed from BufReadPre to BufReadPost
  pattern = file_patterns,
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local ext = vim.fn.fnamemodify(filename, ":e"):lower()

    -- Find the matching language for this extension
    for lang, info in pairs(target_languages) do
      for _, lang_ext in ipairs(info.extensions) do
        if ext == lang_ext then
          -- Only set filetype if it's not already set correctly
          if vim.bo.filetype ~= lang then
            vim.bo.filetype = lang
          end

          -- Defer syntax forcing to avoid conflicts
          vim.defer_fn(function()
            force_syntax(bufnr, lang)
          end, 50)
          break
        end
      end
    end
  end,
  group = syntax_fix_group,
  desc = "Special handling for target language files",
})

-- Ensure syntax is enabled for each buffer when filetype is set (with safeguards)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")

    -- Skip empty filetypes
    if not ft or ft == "" then
      return
    end

    -- Skip if this buffer is being handled by treesitter
    if has_treesitter_parser(ft) then
      return
    end

    -- Check if this is one of our target languages
    for lang, _ in pairs(target_languages) do
      if ft == lang then
        -- Defer to avoid conflicts with other FileType autocmds
        vim.defer_fn(function()
          force_syntax(bufnr, ft)
        end, 10)
        return
      end
    end

    -- For other filetypes, still ensure basic syntax (safely)
    pcall(function()
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("syntax enable")
        vim.cmd("doautocmd Syntax " .. ft)
      end)
    end)
  end,
  group = syntax_fix_group,
  desc = "Ensure syntax highlighting when filetype is set",
})

-- Add a safety check for any buffer that seems to be missing syntax (less aggressive)
vim.api.nvim_create_autocmd({"BufWinEnter"}, {  -- Removed BufEnter to reduce conflicts
  pattern = "*",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")

    -- Skip empty filetypes or special buffers
    if not ft or ft == "" or ft:match("^%s*$") then
      return
    end

    -- Skip if treesitter is handling this
    if has_treesitter_parser(ft) then
      return
    end

    -- Check if syntax appears to be missing (no current_syntax set)
    if not vim.b[bufnr].current_syntax then
      vim.defer_fn(function()
        force_syntax(bufnr, ft)
      end, 100)
    end
  end,
  group = syntax_fix_group,
  desc = "Safety check for missing syntax highlighting",
})

-- Add specific commands for manually triggering syntax highlighting
vim.api.nvim_create_user_command("ForceSyntax", function(opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = opts.args ~= "" and opts.args or vim.bo.filetype
  if ft and ft ~= "" then
    force_syntax(bufnr, ft)
    print("Syntax highlighting forced for " .. ft)
  else
    print("No filetype specified")
  end
end, {
  nargs = "?",
  desc = "Force syntax highlighting for current buffer or specified filetype",
  complete = function(_, _, _)
    local completions = {}
    for lang, _ in pairs(target_languages) do
      table.insert(completions, lang)
    end
    return completions
  end,
})

-- Ensure runtime files for target languages are sourced
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    -- Reload syntax files after colorscheme changes to ensure they take effect
    vim.defer_fn(function()
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) then
          local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
          if ft and ft ~= "" and target_languages[ft] then
            force_syntax(bufnr, ft)
          end
        end
      end
    end, 50)
  end,
  group = syntax_fix_group,
  desc = "Ensure syntax highlighting after colorscheme changes",
})

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
