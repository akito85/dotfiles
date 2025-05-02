local M = {}

local medium_file_threshold = 50 * 1024 * 1024  -- 50MB
local large_file_threshold = 500 * 1024 * 1024  -- 500MB
local huge_file_threshold = 1 * 1024 * 1024 * 1024  -- 1GB

M.original_settings = {
  number = vim.opt.number:get(),
  relativenumber = vim.opt.relativenumber:get(),
  signcolumn = vim.opt.signcolumn:get(),
  cursorline = vim.opt.cursorline:get(),
  autoindent = vim.opt.autoindent:get(),
  smartindent = vim.opt.smartindent:get(),
  syntax = vim.opt.syntax:get(),
  swapfile = vim.opt.swapfile:get(),
  undofile = vim.opt.undofile:get(),
  foldenable = vim.opt.foldenable:get(),
}

function M.optimize_for_file_size(file_path)
  local file_size = vim.fn.getfsize(file_path)
  if file_size < 0 then return end

  vim.b.large_file = false

  if file_size > medium_file_threshold then
    vim.opt_local.swapfile = false
    vim.opt_local.undofile = false
    vim.opt_local.backupcopy = "yes"
    vim.opt_local.list = false
    vim.opt_local.foldmethod = "manual"
    if vim.lsp then
      local clients = vim.lsp.get_active_clients({ buffer = 0 })
      for _, client in pairs(clients) do
        vim.lsp.buf_detach_client(0, client.id)
      end
    end
    vim.notify('Medium file detected (50MB+), applying basic optimizations', vim.log.levels.INFO)
  end

  if file_size > large_file_threshold then
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
    vim.opt_local.cursorline = false
    vim.opt_local.spell = false
    vim.opt_local.autoindent = false
    vim.opt_local.smartindent = false
    vim.opt_local.synmaxcol = 128
    vim.opt_local.lazyredraw = true
    vim.cmd('syntax clear')
    vim.cmd('syntax off')
    vim.b.large_file = true
    vim.notify('Large file detected (500MB+), applying stronger optimizations', vim.log.levels.INFO)
  end

  if file_size > huge_file_threshold then
    vim.opt_local.updatetime = 10000
    vim.opt_local.bufhidden = 'unload'
    vim.opt_local.undolevels = -1
    vim.opt_local.scrollback = 1
    vim.opt_local.scrolljump = 5
    vim.opt_local.redrawtime = 10000
    vim.opt_local.regexpengine = 1
    vim.opt_local.maxmempattern = 2000
    vim.cmd('filetype off')
    vim.opt_local.modifiable = false
    vim.opt_local.readonly = true
    if file_size > huge_file_threshold * 10 then
      vim.cmd('edit ++bin')
    end
    vim.notify('Huge file detected (1GB+), maximum optimizations applied', vim.log.levels.WARN)
  end
end

vim.api.nvim_create_user_command("LargeFileMode", function()
  vim.opt_local.swapfile = false
  vim.opt_local.undofile = false
  vim.opt_local.undolevels = -1
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.signcolumn = 'no'
  vim.opt_local.cursorline = false
  vim.opt_local.autoindent = false
  vim.opt_local.smartindent = false
  vim.opt_local.foldmethod = "manual"
  vim.opt_local.foldenable = false
  vim.opt_local.syntax = 'off'
  vim.cmd('syntax clear')
  vim.cmd('syntax off')
  vim.opt_local.synmaxcol = 128
  vim.opt_local.lazyredraw = true
  vim.cmd('redraw')
  vim.notify('Large file mode manually enabled', vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command("ReadChunk", function(opts)
  local args = opts.args
  local start_line, end_line = string.match(args, "(%d+)%s+(%d+)")
  if not start_line or not end_line then
    print("Usage: ReadChunk <start_line> <end_line>")
    return
  end
  start_line = tonumber(start_line)
  end_line = tonumber(end_line)
  local current_file = vim.fn.expand('%')
  if current_file == '' then
    print("No file is currently open")
    return
  end
  vim.cmd("enew")
  vim.cmd(string.format("read !sed -n '%d,%dp' %s", start_line, end_line, vim.fn.shellescape(current_file)))
  vim.cmd("1delete")
  print(string.format("Loaded lines %d to %d from %s", start_line, end_line, current_file))
end, {nargs = "+"})

vim.api.nvim_create_user_command("TogglePerformance", function()
  if vim.b.optimized_for_performance then
    vim.opt_local.number = M.original_settings.number
    vim.opt_local.relativenumber = M.original_settings.relativenumber
    vim.opt_local.signcolumn = M.original_settings.signcolumn
    vim.opt_local.cursorline = M.original_settings.cursorline
    vim.opt_local.autoindent = M.original_settings.autoindent
    vim.opt_local.smartindent = M.original_settings.smartindent
    if M.original_settings.syntax then
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

vim.api.nvim_create_user_command("ViewBinary", function()
  vim.cmd('edit ++bin')
  vim.opt_local.display = "uhex"
  vim.notify('Binary view mode enabled', vim.log.levels.INFO)
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

return M
