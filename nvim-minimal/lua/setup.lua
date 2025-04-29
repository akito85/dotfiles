-- Enhanced Neovim Configuration
-- Focus: Maximum speed for large files (1GB+)

-- Leader key (must be set before keybindings)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Essential keybindings that work everywhere, even with large files
vim.keymap.set('i', 'jk', '<ESC>', { noremap = true, silent = true }) -- Escape insert mode with 'jk'

-- PERFORMANCE CRITICAL SETTINGS FOR LARGE FILES
--------------------------------------------------------------------------------
-- Set aggressive large file threshold
local medium_file_threshold = 50 * 1024 * 1024  -- 50MB
local large_file_threshold = 500 * 1024 * 1024  -- 500MB
local huge_file_threshold = 1 * 1024 * 1024 * 1024  -- 1GB

-- Track original settings to restore when needed
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

-- Enhanced large file detection and optimization
local function optimize_for_file_size(file_path)
  local file_size = vim.fn.getfsize(file_path)
  
  -- Skip if file doesn't exist or we can't determine size
  if file_size < 0 then return end
  
  -- Medium files (50MB+) - apply minor optimizations
  if file_size > medium_file_threshold then
    vim.opt_local.swapfile = false
    vim.opt_local.undofile = false
    vim.opt_local.backupcopy = "yes"
    vim.opt_local.list = false
    vim.opt_local.foldmethod = "manual"
    
    -- Disable LSP for this buffer if available
    if vim.lsp and vim.lsp.buf_is_attached then
      local clients = vim.lsp.get_active_clients({buffer = 0})
      for _, client in pairs(clients) do
        vim.lsp.buf_detach_client(0, client.id)
      end
    end
    
    vim.notify('Medium file detected (50MB+), applying basic optimizations', vim.log.levels.INFO)
  end
  
  -- Large files (500MB+) - apply stronger optimizations
  if file_size > large_file_threshold then
    -- Apply all medium file optimizations plus these:
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
    
    -- Disable plugins for this buffer
    vim.b.large_file = true
    
    vim.notify('Large file detected (500MB+), applying stronger optimizations', vim.log.levels.INFO)
  end
  
  -- Huge files (1GB+) - maximum optimization
  if file_size > huge_file_threshold then
    -- Apply all previous optimizations plus these:
    vim.opt_local.eventupdatealt = 10000
    vim.opt_local.bufhidden = 'unload'
    vim.opt_local.undolevels = -1
    vim.opt_local.scrollback = 1
    vim.opt_local.scrolljump = 5
    vim.opt_local.redrawtime = 10000
    vim.opt_local.regexpengine = 1
    vim.opt_local.maxmempattern = 2000
    
    -- Completely disable syntax features
    vim.cmd('filetype off')
    
    -- Set read mode
    vim.opt_local.modifiable = false
    vim.opt_local.readonly = true
    
    -- Use binary mode for truly massive files
    if file_size > huge_file_threshold * 10 then  -- 10GB+
      vim.cmd('edit ++bin')
    end
    
    vim.notify('Huge file detected (1GB+), maximum optimizations applied', vim.log.levels.WARN)
  end
end

-- Set up autocmd to detect file size on read
vim.api.nvim_create_autocmd({"BufReadPre"}, {
  pattern = "*",
  callback = function(ev)
    optimize_for_file_size(ev.file)
  end,
})

-- ESSENTIAL CORE SETTINGS
--------------------------------------------------------------------------------
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
vim.opt.updatetime = 200         -- Even faster updates
vim.opt.signcolumn = 'yes'       -- Always show sign column
vim.opt.wrap = false             -- No line wrapping
vim.opt.cursorline = true        -- Highlight current line
vim.opt.autoindent = true        -- Auto indent
vim.opt.smartindent = true       -- Smart indent
vim.opt.expandtab = true         -- Use spaces instead of tabs
vim.opt.tabstop = 2              -- Tab width
vim.opt.shiftwidth = 2           -- Indent width
vim.opt.softtabstop = 2          -- Tab key width
vim.opt.textwidth = 0            -- Disable text wrapping
vim.opt.wrapmargin = 0           -- Disable auto wrapping

-- CRITICAL PERFORMANCE ENHANCEMENTS
--------------------------------------------------------------------------------
-- Memory optimizations
vim.opt.history = 100            -- Limit command history
vim.opt.complete:remove('i')     -- Don't scan included files for completion
vim.opt.synmaxcol = 200          -- Only highlight first 200 columns
vim.opt.lazyredraw = true        -- Don't redraw during macros
vim.opt.redrawtime = 1500        -- Timeout for screen redraw
vim.opt.wrapscan = false         -- Don't wrap searches
vim.opt.maxmempattern = 1000     -- Limit memory used for pattern matching
vim.opt.regexpengine = 1         -- Use old regex engine (faster)
vim.opt.fsync = false            -- Let OS handle file syncing
vim.opt.ruler = false            -- Disable cursor position display
vim.opt.sidescrolloff = 0        -- Disable side scrolling context
vim.opt.scrolljump = 5           -- Scroll multiple lines at once
vim.opt.ttyfast = true           -- Faster terminal connection
vim.opt.ttimeoutlen = 10         -- Faster key sequence completion
vim.opt.timeoutlen = 500         -- Faster key sequence timeout
vim.opt.startofline = true       -- Jump to first non-blank character
vim.opt.display = "lastline"     -- Show as much as possible of last line
vim.opt.shortmess:append("c")    -- Don't show completion messages

-- Set a shorter updatetime - careful, too low can cause flickering
vim.opt.updatetime = 250

-- Faster UI updates
vim.opt.cmdheight = 1            -- Command line height
vim.opt.laststatus = 2           -- Always show status line
vim.opt.showcmd = false          -- Don't show command in last line

-- PLUGIN MANAGEMENT OPTIMIZATIONS
--------------------------------------------------------------------------------
-- Disable runtime plugins
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

-- Disable all language providers unless needed
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_python3_provider = 0

-- Native syntax highlighting with performance limits
vim.opt.syntax = "on"
vim.cmd('filetype plugin indent on')

-- Native Completion Settings with performance optimized
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

-- ESSENTIAL KEYBINDINGS
--------------------------------------------------------------------------------
-- Essential keybindings that always work, regardless of file size
local function setup_essential_keybindings()
  -- Mode escaping
  vim.keymap.set('i', 'jk', '<ESC>', { noremap = true, silent = true })  -- Escape insert mode with 'jk'
  vim.keymap.set('i', 'kj', '<ESC>', { noremap = true, silent = true })  -- Alternative escape
  
  -- Basic navigation
  vim.keymap.set('n', 'H', '^', { noremap = true })  -- Jump to start of line
  vim.keymap.set('n', 'L', '
-- Create commands for manually enabling optimizations
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

-- Create command for chunk-based file reading
vim.api.nvim_create_user_command("ReadChunk", function(opts)
  local args = opts.args
  local start_line, end_line = string.match(args, "(%d+)%s+(%d+)")
  
  if not start_line or not end_line then
    print("Usage: ReadChunk <start_line> <end_line>")
    return
  end
  
  start_line = tonumber(start_line)
  end_line = tonumber(end_line)
  
  -- Create a new buffer
  vim.cmd("enew")
  
  -- Read the specified chunk of lines
  vim.cmd(string.format("read !sed -n '%d,%dp' #", start_line, end_line))
  
  -- Remove the empty first line
  vim.cmd("1delete")
  
  print(string.format("Loaded lines %d to %d", start_line, end_line))
end, {nargs = "+"})

-- Command to toggle performance settings for current buffer
vim.api.nvim_create_user_command("TogglePerformance", function()
  if vim.b.optimized_for_performance then
    -- Restore regular settings
    vim.opt_local.number = original_settings.number
    vim.opt_local.relativenumber = original_settings.relativenumber
    vim.opt_local.signcolumn = original_settings.signcolumn
    vim.opt_local.cursorline = original_settings.cursorline
    vim.opt_local.autoindent = original_settings.autoindent
    vim.opt_local.smartindent = original_settings.smartindent
    if original_settings.syntax then
      vim.cmd('syntax on')
    end
    vim.b.optimized_for_performance = false
    vim.notify('Regular performance settings restored', vim.log.levels.INFO)
  else
    -- Enable high performance mode
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

-- Binary file viewing command
vim.api.nvim_create_user_command("ViewBinary", function()
  vim.cmd('edit ++bin')
  vim.opt_local.display = "uhex"
  vim.notify('Binary view mode enabled', vim.log.levels.INFO)
end, {})

-- Memory usage command
vim.api.nvim_create_user_command("MemoryUsage", function()
  local memory = vim.fn.system('ps -o rss= -p ' .. vim.fn.getpid()):gsub("%s+", "")
  local memory_mb = tonumber(memory) / 1024
  vim.notify(string.format('Neovim memory usage: %.2f MB', memory_mb), vim.log.levels.INFO)
end, {})

-- Function to optimize current buffer maximally
vim.api.nvim_create_user_command("MaxPerformance", function()
  -- Unload all plugins and clear all syntax
  vim.cmd('syntax clear')
  vim.cmd('syntax off')
  vim.cmd('filetype off')
  
  -- Maximum optimization settings
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
  
  -- Disable LSP for this buffer
  if vim.lsp and vim.lsp.buf_is_attached then
    local clients = vim.lsp.get_active_clients({buffer = 0})
    for _, client in pairs(clients) do
      vim.lsp.buf_detach_client(0, client.id)
    end
  end
  
  vim.notify('Maximum performance mode enabled for current buffer', vim.log.levels.INFO)
end, {})

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

-- Modified plugin setup with conditionals for large files
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  
  -- Only load plugins when not in large file mode
  use {
    'hrsh7th/nvim-cmp',
    disable = function() return vim.b.large_file end,
    requires = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    }
  }
  
  use {
    'neovim/nvim-lspconfig',
    disable = function() return vim.b.large_file end
  }
  
  use {
    'nvim-telescope/telescope.nvim',
    disable = function() return vim.b.large_file end,
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  
  use {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    disable = function() return vim.b.large_file end,
    requires = { 
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    }
  }
  
  use {
    'folke/tokyonight.nvim',
    disable = function() return vim.b.large_file end
  }

  -- Performance monitoring plugin (optional but useful)
  use {
    'dstein64/vim-startuptime',
    cmd = 'StartupTime',
    disable = function() return vim.b.large_file end
  }

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Plugin-dependent keybindings and setup
local function setup_keybindings()
  if vim.b.large_file then
    vim.notify('Plugin keybindings and theme disabled for large file', vim.log.levels.INFO)
    return
  end

  -- Theme setup
  require('tokyonight').setup({
    style = 'storm',
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
      { name = 'nvim_lsp', max_item_count = 10 },
      { name = 'luasnip', max_item_count = 5 },
      { name = 'buffer', max_item_count = 8, keyword_length = 3 },
      { name = 'path', max_item_count = 5 },
    }),
    performance = {
      max_view_entries = 8,
      debounce = 100,
      throttle = 50,
      fetching_timeout = 80,
    },
  })

  -- Telescope setup with performance optimizations
  local status, telescope = pcall(require, 'telescope.builtin')
  if status then
    -- Configure telescope for better performance
    require('telescope').setup {
      defaults = {
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden',
        },
        initial_mode = 'insert',
        selection_strategy = 'reset',
        sorting_strategy = 'ascending',
        layout_strategy = 'horizontal',
        file_ignore_patterns = {
          "%.git/",
          "node_modules/",
          "%.cache/",
        },
        generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
        path_display = { "truncate" },
        file_previewer = require('telescope.previewers').vim_buffer_cat.new,
        grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
        qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
        layout_config = {
          horizontal = {
            preview_width = 0.5,
          },
        },
        preview = {
          timeout = 200,
          filesize_limit = 1,  -- MB
        },
      }
    }
    
    vim.keymap.set('n', '<leader>ff', telescope.find_files, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>fg', telescope.live_grep, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>fb', telescope.buffers, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>fh', telescope.help_tags, { noremap = true, silent = true })
  else
    vim.notify('Telescope not loaded - run :PackerSync', vim.log.levels.WARN)
  end

  -- Neo-tree setup with performance optimizations
  local neotree = require('neo-tree')
  neotree.setup({
    close_if_last_window = true,
    filesystem = {
      follow_current_file = {
        enabled = true,
      },
      use_libuv_file_watcher = true,
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = true,
      },
      scan_mode = "deep",
      bind_to_cwd = false,
      cwd_target = {
        sidebar = "tab",
        current = "window",
      },
    },
    window = {
      position = 'left',
      width = 30,
      mappings = {
        ["<space>"] = "none",
      },
    },
    event_handlers = {
      {
        event = "file_opened",
        handler = function()
          -- Auto close after opening a file
          vim.cmd("Neotree close")
        end
      },
    },
    
    -- Performance-related settings
    enable_diagnostics = false,
    enable_git_status = false,
    enable_modified_markers = false,
    log_level = "warn",
    log_to_file = false,
  })

  vim.keymap.set('n', '<C-h>', ':Neotree focus<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<C-l>', ':wincmd p<CR>', { noremap = true, silent = true })

  -- LSP setup with performance optimizations
  local lspconfig = require('lspconfig')
  local servers = {
    'pyright',
    'tsserver',
    'clangd',
    'rust_analyzer',
    'gopls',
  }

  for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      flags = {
        debounce_text_changes = 300,
      },
      -- Limit diagnostics for better performance
      handlers = {
        ["textDocument/publishDiagnostics"] = vim.lsp.with(
          vim.lsp.diagnostic.on_publish_diagnostics, {
            update_in_insert = false,
            virtual_text = {
              spacing = 4,
              prefix = '●',
            },
            severity_sort = true,
            underline = false,
          }
        ),
      },
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

-- Performance-focused key bindings for large files
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    if vim.b.large_file then
      -- Add specific keybindings for large files
      vim.keymap.set('n', '<leader>mp', ':MaxPerformance<CR>', { buffer = true, noremap = true, silent = true })
      vim.keymap.set('n', '<leader>mu', ':MemoryUsage<CR>', { buffer = true, noremap = true, silent = true })
      vim.keymap.set('n', '<leader>rc', ':ReadChunk ', { buffer = true, noremap = true })
      vim.keymap.set('n', '<leader>tp', ':TogglePerformance<CR>', { buffer = true, noremap = true, silent = true })
      vim.keymap.set('n', '<leader>vb', ':ViewBinary<CR>', { buffer = true, noremap = true, silent = true })
      
      -- Fast movement keys
      vim.keymap.set('n', '<C-j>', '10j', { buffer = true, noremap = true, silent = true })
      vim.keymap.set('n', '<C-k>', '10k', { buffer = true, noremap = true, silent = true })
      vim.keymap.set('n', '<C-d>', '30j', { buffer = true, noremap = true, silent = true })
      vim.keymap.set('n', '<C-u>', '30k', { buffer = true, noremap = true, silent = true })
    end
  end
})

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

-- CREATE A MINIMAL INIT.LUA FILE
local init_file = [[
-- init.lua - Minimal file that loads the optimized setup
require("setup")
]]

-- Write this to init.lua
local file = io.open("init.lua", "w")
if file then
    file:write(init_file)
    file:close()
end
, { noremap = true })  -- Jump to end of line
  
  -- Window navigation
  vim.keymap.set('n', '<leader>h', '<C-w>h', { noremap = true })  -- Move to left window
  vim.keymap.set('n', '<leader>j', '<C-w>j', { noremap = true })  -- Move to lower window
  vim.keymap.set('n', '<leader>k', '<C-w>k', { noremap = true })  -- Move to upper window
  vim.keymap.set('n', '<leader>l', '<C-w>l', { noremap = true })  -- Move to right window
  
  -- Buffer navigation
  vim.keymap.set('n', '<leader>n', ':bn<CR>', { noremap = true, silent = true })  -- Next buffer
  vim.keymap.set('n', '<leader>p', ':bp<CR>', { noremap = true, silent = true })  -- Previous buffer
  vim.keymap.set('n', '<leader>d', ':bd<CR>', { noremap = true, silent = true })  -- Delete buffer
  
  -- Fast save and quit
  vim.keymap.set('n', '<leader>w', ':w<CR>', { noremap = true, silent = true })  -- Save
  vim.keymap.set('n', '<leader>q', ':q<CR>', { noremap = true, silent = true })  -- Quit
  vim.keymap.set('n', '<leader>Q', ':qa!<CR>', { noremap = true, silent = true }) -- Force quit all
  
  -- Clear search highlighting
  vim.keymap.set('n', '<leader>/', ':nohlsearch<CR>', { noremap = true, silent = true })
  
  -- Fast vertical split
  vim.keymap.set('n', '<leader>v', ':vsplit<CR>', { noremap = true, silent = true })
  
  -- Fast terminal access
  vim.keymap.set('n', '<leader>t', ':terminal<CR>', { noremap = true, silent = true })
  vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })  -- Exit terminal mode
end

-- Setup essential keybindings immediately
setup_essential_keybindings()

-- HELPFUL COMMANDS FOR LARGE FILES
--------------------------------------------------------------------------------
-- Create commands for manually enabling optimizations
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

-- Create command for chunk-based file reading
vim.api.nvim_create_user_command("ReadChunk", function(opts)
  local args = opts.args
  local start_line, end_line = string.match(args, "(%d+)%s+(%d+)")
  
  if not start_line or not end_line then
    print("Usage: ReadChunk <start_line> <end_line>")
    return
  end
  
  start_line = tonumber(start_line)
  end_line = tonumber(end_line)
  
  -- Create a new buffer
  vim.cmd("enew")
  
  -- Read the specified chunk of lines
  vim.cmd(string.format("read !sed -n '%d,%dp' #", start_line, end_line))
  
  -- Remove the empty first line
  vim.cmd("1delete")
  
  print(string.format("Loaded lines %d to %d", start_line, end_line))
end, {nargs = "+"})

-- Command to toggle performance settings for current buffer
vim.api.nvim_create_user_command("TogglePerformance", function()
  if vim.b.optimized_for_performance then
    -- Restore regular settings
    vim.opt_local.number = original_settings.number
    vim.opt_local.relativenumber = original_settings.relativenumber
    vim.opt_local.signcolumn = original_settings.signcolumn
    vim.opt_local.cursorline = original_settings.cursorline
    vim.opt_local.autoindent = original_settings.autoindent
    vim.opt_local.smartindent = original_settings.smartindent
    if original_settings.syntax then
      vim.cmd('syntax on')
    end
    vim.b.optimized_for_performance = false
    vim.notify('Regular performance settings restored', vim.log.levels.INFO)
  else
    -- Enable high performance mode
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

-- Binary file viewing command
vim.api.nvim_create_user_command("ViewBinary", function()
  vim.cmd('edit ++bin')
  vim.opt_local.display = "uhex"
  vim.notify('Binary view mode enabled', vim.log.levels.INFO)
end, {})

-- Memory usage command
vim.api.nvim_create_user_command("MemoryUsage", function()
  local memory = vim.fn.system('ps -o rss= -p ' .. vim.fn.getpid()):gsub("%s+", "")
  local memory_mb = tonumber(memory) / 1024
  vim.notify(string.format('Neovim memory usage: %.2f MB', memory_mb), vim.log.levels.INFO)
end, {})

-- Function to optimize current buffer maximally
vim.api.nvim_create_user_command("MaxPerformance", function()
  -- Unload all plugins and clear all syntax
  vim.cmd('syntax clear')
  vim.cmd('syntax off')
  vim.cmd('filetype off')
  
  -- Maximum optimization settings
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
  
  -- Disable LSP for this buffer
  if vim.lsp and vim.lsp.buf_is_attached then
    local clients = vim.lsp.get_active_clients({buffer = 0})
    for _, client in pairs(clients) do
      vim.lsp.buf_detach_client(0, client.id)
    end
  end
  
  vim.notify('Maximum performance mode enabled for current buffer', vim.log.levels.INFO)
end, {})

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

-- Modified plugin setup with conditionals for large files
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  
  -- Only load plugins when not in large file mode
  use {
    'hrsh7th/nvim-cmp',
    disable = function() return vim.b.large_file end,
    requires = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    }
  }
  
  use {
    'neovim/nvim-lspconfig',
    disable = function() return vim.b.large_file end
  }
  
  use {
    'nvim-telescope/telescope.nvim',
    disable = function() return vim.b.large_file end,
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  
  use {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    disable = function() return vim.b.large_file end,
    requires = { 
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    }
  }
  
  use {
    'folke/tokyonight.nvim',
    disable = function() return vim.b.large_file end
  }

  -- Performance monitoring plugin (optional but useful)
  use {
    'dstein64/vim-startuptime',
    cmd = 'StartupTime',
    disable = function() return vim.b.large_file end
  }

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Plugin-dependent keybindings and setup
local function setup_keybindings()
  if vim.b.large_file then
    vim.notify('Plugin keybindings and theme disabled for large file', vim.log.levels.INFO)
    return
  end

  -- Theme setup
  require('tokyonight').setup({
    style = 'storm',
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
      { name = 'nvim_lsp', max_item_count = 10 },
      { name = 'luasnip', max_item_count = 5 },
      { name = 'buffer', max_item_count = 8, keyword_length = 3 },
      { name = 'path', max_item_count = 5 },
    }),
    performance = {
      max_view_entries = 8,
      debounce = 100,
      throttle = 50,
      fetching_timeout = 80,
    },
  })

  -- Telescope setup with performance optimizations
  local status, telescope = pcall(require, 'telescope.builtin')
  if status then
    -- Configure telescope for better performance
    require('telescope').setup {
      defaults = {
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden',
        },
        initial_mode = 'insert',
        selection_strategy = 'reset',
        sorting_strategy = 'ascending',
        layout_strategy = 'horizontal',
        file_ignore_patterns = {
          "%.git/",
          "node_modules/",
          "%.cache/",
        },
        generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
        path_display = { "truncate" },
        file_previewer = require('telescope.previewers').vim_buffer_cat.new,
        grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
        qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
        layout_config = {
          horizontal = {
            preview_width = 0.5,
          },
        },
        preview = {
          timeout = 200,
          filesize_limit = 1,  -- MB
        },
      }
    }
    
    vim.keymap.set('n', '<leader>ff', telescope.find_files, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>fg', telescope.live_grep, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>fb', telescope.buffers, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>fh', telescope.help_tags, { noremap = true, silent = true })
  else
    vim.notify('Telescope not loaded - run :PackerSync', vim.log.levels.WARN)
  end

  -- Neo-tree setup with performance optimizations
  local neotree = require('neo-tree')
  neotree.setup({
    close_if_last_window = true,
    filesystem = {
      follow_current_file = {
        enabled = true,
      },
      use_libuv_file_watcher = true,
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = true,
      },
      scan_mode = "deep",
      bind_to_cwd = false,
      cwd_target = {
        sidebar = "tab",
        current = "window",
      },
    },
    window = {
      position = 'left',
      width = 30,
      mappings = {
        ["<space>"] = "none",
      },
    },
    event_handlers = {
      {
        event = "file_opened",
        handler = function()
          -- Auto close after opening a file
          vim.cmd("Neotree close")
        end
      },
    },
    
    -- Performance-related settings
    enable_diagnostics = false,
    enable_git_status = false,
    enable_modified_markers = false,
    log_level = "warn",
    log_to_file = false,
  })

  vim.keymap.set('n', '<C-h>', ':Neotree focus<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<C-l>', ':wincmd p<CR>', { noremap = true, silent = true })

  -- LSP setup with performance optimizations
  local lspconfig = require('lspconfig')
  local servers = {
    'pyright',
    'tsserver',
    'clangd',
    'rust_analyzer',
    'gopls',
  }

  for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      flags = {
        debounce_text_changes = 300,
      },
      -- Limit diagnostics for better performance
      handlers = {
        ["textDocument/publishDiagnostics"] = vim.lsp.with(
          vim.lsp.diagnostic.on_publish_diagnostics, {
            update_in_insert = false,
            virtual_text = {
              spacing = 4,
              prefix = '●',
            },
            severity_sort = true,
            underline = false,
          }
        ),
      },
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

-- Performance-focused key bindings for large files
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    if vim.b.large_file then
      -- Add specific keybindings for large files
      vim.keymap.set('n', '<leader>mp', ':MaxPerformance<CR>', { buffer = true, noremap = true, silent = true })
      vim.keymap.set('n', '<leader>mu', ':MemoryUsage<CR>', { buffer = true, noremap = true, silent = true })
      vim.keymap.set('n', '<leader>rc', ':ReadChunk ', { buffer = true, noremap = true })
      vim.keymap.set('n', '<leader>tp', ':TogglePerformance<CR>', { buffer = true, noremap = true, silent = true })
      vim.keymap.set('n', '<leader>vb', ':ViewBinary<CR>', { buffer = true, noremap = true, silent = true })
      
      -- Fast movement keys
      vim.keymap.set('n', '<C-j>', '10j', { buffer = true, noremap = true, silent = true })
      vim.keymap.set('n', '<C-k>', '10k', { buffer = true, noremap = true, silent = true })
      vim.keymap.set('n', '<C-d>', '30j', { buffer = true, noremap = true, silent = true })
      vim.keymap.set('n', '<C-u>', '30k', { buffer = true, noremap = true, silent = true })
    end
  end
})

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

-- CREATE A MINIMAL INIT.LUA FILE
local init_file = [[
-- init.lua - Minimal file that loads the optimized setup
require("setup")
]]

-- Write this to init.lua
local file = io.open("init.lua", "w")
if file then
    file:write(init_file)
    file:close()
endlocal function optimize_for_large_file()
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
