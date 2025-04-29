-- Fast Minimal Neovim Configuration
-- Focus: Speed and essential functionality, optimized for large files (20GB+)

-- Leader key (must be set before keybindings)
vim.g.mapleader = ' '

-- Basic Settings
vim.opt.number = true            -- Show line numbers
vim.opt.relativenumber = true    -- Relative line numbers
vim.opt.ignorecase = true        -- Case insensitive search
vim.opt.smartcase = true         -- Unless uppercase is used
vim.opt.hlsearch = true          -- Highlight search results
vim.opt.incsearch = true         -- Show search matches as you type
vim.opt.mouse = 'a'              -- Enable mouse support
vim.opt.clipboard = 'unnamedplus' -- Use system clipboard
vim.opt.backup = false           -- No backup files
vim.opt.writebackup = false      -- No backup files during write
vim.opt.swapfile = false         -- No swap files
vim.opt.hidden = true            -- Allow switching buffers without saving
vim.opt.updatetime = 300         -- Faster updates
vim.opt.signcolumn = 'yes'       -- Always show sign column
vim.opt.wrap = false             -- No line wrapping
vim.opt.cursorline = true        -- Highlight current line
vim.opt.autoindent = true        -- Auto indent
vim.opt.smartindent = true       -- Smart indent
vim.opt.expandtab = true         -- Use spaces instead of tabs
vim.opt.tabstop = 2              -- Tab width
vim.opt.shiftwidth = 2           -- Indent width
vim.opt.softtabstop = 2          -- Tab key width

-- Native syntax highlighting
vim.opt.syntax = 'on'            -- Enable syntax highlighting
vim.cmd('filetype plugin indent on')

-- Native Completion Settings
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

-- Large file optimizations
local large_file_threshold = 20 * 1024 * 1024 * 1024 -- 20GB in bytes
local is_large_file = false
local original_settings = {
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

local function optimize_for_large_file()
  is_large_file = true
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.signcolumn = 'no'
  vim.opt_local.cursorline = false
  vim.opt_local.autoindent = false
  vim.opt_local.smartindent = false
  vim.opt_local.syntax = 'off'
  vim.opt_local.swapfile = false
  vim.opt_local.undofile = false
  vim.opt_local.foldenable = false
  vim.opt_local.bufhidden = 'unload'
  vim.cmd('filetype off')
  vim.notify('Large file detected (>1GB), optimizations applied', vim.log.levels.INFO)
end

-- Wayland clipboard support
vim.opt.clipboard = 'unnamedplus' -- Ensures Wayland compatibility

-- Package manager setup (Packer)
local ensure_packer = function()
  local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Plugin setup
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    }
  }
  use 'neovim/nvim-lspconfig'
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    requires = { 
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    }
  }
  use 'folke/tokyonight.nvim' -- Fast theme plugin

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Plugin-dependent keybindings and setup
local function setup_keybindings()
  if is_large_file then
    vim.notify('Plugin keybindings and theme disabled for large file', vim.log.levels.INFO)
    return
  end

  -- Theme setup
  require('tokyonight').setup({
    style = 'storm', -- Use storm variant
    transparent = false,
    terminal_colors = true,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      functions = {},
      variables = {},
      sidebars = 'dark',
      floats = 'dark',
    },
  })
  vim.cmd('colorscheme tokyonight-storm')

  -- Fast completion setup
  local cmp = require('cmp')
  local luasnip = require('luasnip')

  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'buffer' },
      { name = 'path' },
    }),
    performance = {
      max_view_entries = 15,
      debounce = 60,
      throttle = 30,
    },
  })

  -- Telescope setup and keybindings
  local status, telescope = pcall(require, 'telescope.builtin')
  if status then
    vim.keymap.set('n', '<leader>ff', telescope.find_files, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>fg', telescope.live_grep, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>fb', telescope.buffers, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>fh', telescope.help_tags, { noremap = true, silent = true })
  else
    vim.notify('Telescope not loaded - run :PackerSync', vim.log.levels.WARN)
  end

  -- Neo-tree setup
  local neotree = require('neo-tree')
  neotree.setup({
    close_if_last_window = true,
    filesystem = {
      follow_current_file = {
        enabled = true,
      },
      use_libuv_file_watcher = true,
    },
    window = {
      position = 'left',
      width = 30,
    },
  })

  -- Neo-tree focus keybinding based on position
  vim.keymap.set('n', '<C-h>', ':Neotree focus<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<C-l>', ':wincmd p<CR>', { noremap = true, silent = true })

  -- LSP setup
  local lspconfig = require('lspconfig')
  local servers = {
    'pyright',
    'ts_ls',
    'clangd',
    'rust_analyzer',
    'gopls',
  }

  for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      flags = {
        debounce_text_changes = 150,
      }
    }
  end

  -- LSP keybindings with <leader>g prefix
  vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>gh', vim.lsp.buf.hover, { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { noremap = true, silent = true })
end

-- Trigger keybindings after Packer completes
vim.api.nvim_create_autocmd('User', {
  pattern = 'PackerComplete',
  callback = function()
    setup_keybindings()
  end,
})

-- Run keybindings setup immediately if Packer is already installed
if not packer_bootstrap then
  setup_keybindings()
end

-- Performance optimizations
vim.g.loaded_perl_provider = 0    -- Disable Perl provider
vim.g.loaded_ruby_provider = 0    -- Disable Ruby provider
vim.g.loaded_node_provider = 0    -- Disable Node provider
vim.g.loaded_python_provider = 0  -- Disable Python 2 provider
vim.g.loaded_python3_provider = 0 -- Only enable if you need Python integration

-- Faster UI updates
vim.opt.lazyredraw = true

-- Disable unused built-in plugins
local disabled_built_ins = {
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
  "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end
