-- ~/.config/nvim/lua/core/options.lua
-- Core Neovim options

-- Store original settings to restore when needed (for large file mode toggle)
vim.g.original_settings = {
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

-- ESSENTIAL CORE SETTINGS
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.hidden = true
vim.opt.updatetime = 200
vim.opt.signcolumn = 'yes'
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.textwidth = 0
vim.opt.wrapmargin = 0

-- Enable syntax and filetype detection
vim.opt.syntax = "on"
vim.cmd('filetype plugin indent on')
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

-- Status line optimized for performance
vim.opt.statusline = [[%f %h%w%m%r%=%y %-14.(%l,%c%V%) %P]]

-- Set clipboard configuration based on OS
if vim.fn.has('mac') == 1 then
  -- On macOS: don't set Wayland clipboard
  -- (uses system clipboard by default)
elseif vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
  -- On Windows: don't set Wayland clipboard
  -- (uses system clipboard by default)
else
  -- On Linux: set up Wayland clipboard
  vim.g.clipboard = {
    name = 'WaylandClipboard',
    copy = {
      ['+'] = 'wl-copy',
      ['*'] = 'wl-copy',
    },
    paste = {
      ['+'] = 'wl-paste',
      ['*'] = 'wl-paste',
    },
    cache_enabled = 1,
  }
end

-- Disable built-in plugins for startup performance
local disabled_built_ins = {
  "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers",
  "gzip", "zip", "zipPlugin", "tar", "tarPlugin",
  "getscript", "getscriptPlugin", "vimball", "vimballPlugin",
  "2html_plugin", "logipat", "rrhelper", "spellfile_plugin",
  "matchit", "matchparen", "tutor", "rplugin", "shada",
  "tohtml", "man", "filetype", "tutor_mode_plugin", "remote_plugins"
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end

-- Disable language providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_python3_provider = 0
