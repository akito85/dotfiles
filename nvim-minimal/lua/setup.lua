-- Enhanced Neovim Configuration
-- Focus: Maximum speed for large files (1GB+)

-- Leader key (must be set before keybindings)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- PERFORMANCE CRITICAL SETTINGS FOR LARGE FILES
--------------------------------------------------------------------------------
-- Set aggressive large file thresholds
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
  
  if file_size < 0 then return end
  
  vim.b.large_file = false  -- Reset per buffer
  
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

-- Set up autocmd to detect file size on read
vim.api.nvim_create_autocmd({"BufReadPre"}, {
  pattern = "*",
  callback = function(ev)
    optimize_for_file_size(ev.file)
  end,
})

-- ESSENTIAL CORE SETTINGS
--------------------------------------------------------------------------------
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

-- CRITICAL PERFORMANCE ENHANCEMENTS
--------------------------------------------------------------------------------
vim.opt.history = 100
vim.opt.complete:remove('i')
vim.opt.synmaxcol = 200
vim.opt.lazyredraw = true
vim.opt.redrawtime = 1500
vim.opt.wrapscan = false
vim.opt.maxmempattern = 1000
vim.opt.regexpengine = 1
vim.opt.fsync = false
vim.opt.ruler = false
vim.opt.sidescrolloff = 0
vim.opt.scrolljump = 5
vim.opt.ttyfast = true
vim.opt.ttimeoutlen = 10
vim.opt.timeoutlen = 500
vim.opt.startofline = true
vim.opt.display = "lastline"
vim.opt.shortmess:append("c")
vim.opt.cmdheight = 1
vim.opt.laststatus = 2
vim.opt.showcmd = false

-- PLUGIN MANAGEMENT OPTIMIZATIONS
--------------------------------------------------------------------------------
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

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_python3_provider = 0

vim.opt.syntax = "on"
vim.cmd('filetype plugin indent on')
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

-- ESSENTIAL KEYBINDINGS
--------------------------------------------------------------------------------
local function setup_essential_keybindings()
  vim.keymap.set('i', 'jk', '<ESC>', { noremap = true, silent = true })
  vim.keymap.set('i', 'kj', '<ESC>', { noremap = true, silent = true })
  vim.keymap.set('n', 'H', '^', { noremap = true })
  vim.keymap.set('n', 'L', '$', { noremap = true })
  vim.keymap.set('n', '<leader>h', '<C-w>h', { noremap = true })
  vim.keymap.set('n', '<leader>j', '<C-w>j', { noremap = true })
  vim.keymap.set('n', '<leader>k', '<C-w>k', { noremap = true })
  vim.keymap.set('n', '<leader>l', '<C-w>l', { noremap = true })
  vim.keymap.set('n', '<leader>n', ':bn<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>p', ':bp<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>d', ':bd<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>w', ':w<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>q', ':q<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>Q', ':qa!<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>/', ':nohlsearch<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>v', ':vsplit<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>t', ':terminal<CR>', { noremap = true, silent = true })
  vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })
end

-- HELPFUL COMMANDS FOR LARGE FILES
--------------------------------------------------------------------------------
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

vim.api.nvim_create_user_command("MemoryUsage", function()
  local memory = vim.fn.system('ps -o rss= -p ' .. vim.fn.getpid()):gsub("%s+", "")
  local memory_mb = tonumber(memory) / 1024
  vim.notify(string.format('Neovim memory usage: %.2f MB', memory_mb), vim.log.levels.INFO)
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

-- Define setup_plugins before startup
local function setup_plugins()
  -- Theme setup
  local ok, tokyonight = pcall(require, 'tokyonight')
  if ok then
    tokyonight.setup({
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
  else
    vim.notify('Failed to load tokyonight', vim.log.levels.WARN)
  end

  -- Fast completion setup
  local cmp_ok, cmp = pcall(require, 'cmp')
  local luasnip_ok, luasnip = pcall(require, 'luasnip')
  if cmp_ok and luasnip_ok then
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
  else
    vim.notify('Failed to load cmp or luasnip', vim.log.levels.WARN)
  end

  -- Telescope setup
  local telescope_ok, telescope = pcall(require, 'telescope.builtin')
  if telescope_ok then
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
          horizontal = { preview_width = 0.5 },
        },
        preview = {
          timeout = 200,
          filesize_limit = 1,
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

  -- Neo-tree setup
  local neotree_ok, neotree = pcall(require, 'neo-tree')
  if neotree_ok then
    neotree.setup({
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true },
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
        mappings = { ["<space>"] = "none" },
      },
      event_handlers = {
        {
          event = "file_opened",
          handler = function()
            vim.cmd("Neotree close")
          end
        },
      },
      enable_diagnostics = false,
      enable_git_status = false,
      enable_modified_markers = false,
      log_level = "warn",
      log_to_file = false,
    })
    vim.keymap.set('n', '<C-h>', ':Neotree focus<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<C-l>', ':wincmd p<CR>', { noremap = true, silent = true })
  else
    vim.notify('Neo-tree not loaded - run :PackerSync', vim.log.levels.WARN)
  end

  -- LSP setup
  local lspconfig_ok, lspconfig = pcall(require, 'lspconfig')
  if lspconfig_ok then
    local servers = { 'pyright', 'ts_ls', 'clangd', 'rust_analyzer', 'gopls' }
    for _, lsp in ipairs(servers) do
      lspconfig[lsp].setup {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        flags = { debounce_text_changes = 300 },
        handlers = {
          ["textDocument/publishDiagnostics"] = vim.lsp.with(
            vim.lsp.diagnostic.on_publish_diagnostics, {
              update_in_insert = false,
              virtual_text = { spacing = 4, prefix = '●' },
              severity_sort = true,
              underline = false,
            }
          ),
        },
      }
    end
    vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>gh', vim.lsp.buf.hover, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { noremap = true, silent = true })
  else
    vim.notify('LSPConfig not loaded - run :PackerSync', vim.log.levels.WARN)
  end
end

-- Plugin setup with Packer
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
  use 'folke/tokyonight.nvim'
  use {
    'dstein64/vim-startuptime',
    cmd = 'StartupTime',
  }
  
  if packer_bootstrap then
    require('packer').sync(function()
      vim.g.packer_synced = true
      setup_plugins()
    end)
  else
    setup_plugins()
  end
end)

-- Initialize essential keybindings
setup_essential_keybindings()

-- Additional performance optimizations for startup
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    vim.defer_fn(function()
      if vim.b.large_file then
        vim.notify('Large file mode active - some features disabled', vim.log.levels.INFO)
      else
        if vim.fn.exists(':Neotree') == 2 then
          vim.keymap.set('n', '<leader>e', ':Neotree reveal<CR>', { noremap = true, silent = true })
        end
      end
    end, 100)
  end,
})

-- Status line optimized for performance
vim.opt.statusline = [[%f %h%w%m%r%=%y %-14.(%l,%c%V%) %P]]

-- Profiling commands
vim.api.nvim_create_user_command("ProfileStart", function()
  vim.cmd('profile start profile.log')
  vim.cmd('profile func *')
  vim.cmd('profile file *')
  vim.notify('Profiling started', vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command("ProfileStop", function()
  vim.cmd('profile stop')
  vim.notify('Profiling stopped and saved to profile.log', vim.log.levels.INFO)
end, {})

-- Additional performance optimizations
vim.opt.updatetime = 300

vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy,
    ['*'] = require('vim.ui.clipboard.osc52').copy,
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste,
    ['*'] = require('vim.ui.clipboard.osc52').paste,
  },
}

local disabled_built_ins = {
  "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers",
  "gzip", "zip", "zipPlugin", "tar", "tarPlugin",
  "getscript", "getscriptPlugin",
  "vimball", "vimballPlugin",
  "2html_plugin", "logipat", "rrhelper",
  "spellfile_plugin", "matchit"
}
for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end

vim.opt.synmaxcol = 200
vim.g.syntax_on = true

vim.opt.cursorline = true
vim.api.nvim_create_autocmd({"InsertEnter"}, {
  callback = function() vim.opt.cursorline = false end
})
vim.api.nvim_create_autocmd({"InsertLeave"}, {
  callback = function() vim.opt.cursorline = true end
})

vim.opt.ttyfast = true
vim.opt.lazyredraw = true

vim.opt.timeout = true
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 10

vim.opt.hidden = true
vim.opt.history = 100
vim.opt.undolevels = 1000

vim.cmd([[
  augroup FastFT
    autocmd!
    autocmd BufRead,BufNewFile * if &filetype == '' | setlocal filetype=text | endif
  augroup END
]])

vim.cmd('filetype plugin indent on')
vim.g.did_load_filetypes = 1

function _G.check_memory_usage()
  local stats = vim.loop.resident_set_memory()
  local memory_mb = math.floor(stats / 1024 / 1024 * 100) / 100
  vim.notify(string.format("Neovim memory usage: %.2f MB", memory_mb), vim.log.levels.INFO)
  return memory_mb
end

vim.api.nvim_create_user_command("CheckMemory", function()
  _G.check_memory_usage()
end, {})

local autocmd_group = vim.api.nvim_create_augroup("PerformanceAutocmds", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = autocmd_group,
  pattern = "*",
  callback = function()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, cursor_pos)
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = autocmd_group,
  pattern = "*",
  callback = function()
    if vim.fn.exists("g:auto_session_enabled") == 1 and vim.g.auto_session_enabled then
      vim.cmd("silent! mksession! " .. vim.fn.stdpath("data") .. "/sessions/autosave.vim")
    end
  end,
})

local gc_timer = vim.loop.new_timer()
gc_timer:start(30000, 30000, vim.schedule_wrap(function()
  collectgarbage("collect")
end))

vim.api.nvim_create_autocmd("BufReadPost", {
  group = autocmd_group,
  callback = function()
    local ft = vim.bo.filetype
    if ft == "lua" or ft == "python" or ft == "javascript" or ft == "typescript" then
      vim.notify("LSP loaded for " .. ft, vim.log.levels.INFO)
    end
  end,
})