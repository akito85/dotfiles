-- Plugins setup with lazy.nvim
require("lazy").setup({
  -- Disable treesitter completely
  { "nvim-treesitter/nvim-treesitter", enabled = false },
  { "nvim-treesitter/nvim-treesitter-textobjects", enabled = false },
  { "nvim-treesitter/nvim-treesitter-context", enabled = false },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lspconfig = require('lspconfig')
      local servers = { 'pyright', 'ts_ls', 'clangd', 'rust_analyzer', 'gopls' }

      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
          capabilities = require('cmp_nvim_lsp').default_capabilities(),
          flags = { debounce_text_changes = 150 },
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
    end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    }
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      -- "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
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
    end
  },

  -- Telescope (file finder, grep)
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
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
    end
  },

  -- Neo-tree (file explorer)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle reveal<cr>", desc = "Toggle Explorer" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require('neo-tree').setup({
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
          mappings = {
            ["<space>"] = "none",
            -- Add a toggle mapping for <C-h> to toggle between neotree and buffer
            ["<C-h>"] = "toggle_preview", -- Use preview toggle as an example action
          },
        },
        -- event_handlers = {
        --   -- Fix for buffer clearing issue - don't unload current buffer on file_open
        --   {
        --     event = "file_opened",
        --     handler = function(file_path)
        --       -- Don't close the tree when opening a file
        --       -- and don't clear the buffer
        --       require("neo-tree.sources.manager").close_all()
        --       -- Optionally focus the opened file
        --       vim.cmd("e " .. vim.fn.fnameescape(file_path))
        --     end
        --   },
        -- },
        enable_diagnostics = false,
        enable_git_status = false,
        enable_modified_markers = false,
        log_level = "warn",
        log_to_file = false,
        use_popups_for_input = true, -- Avoid floating windows that might use Tree-sitter
      })
    end
  },

  -- Theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
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
    end
  },

  {
      'ggandor/leap.nvim',
      event = "VeryLazy",
      config = function()
          local leap = require('leap')
          leap.add_default_mappings()
          -- Reset 's' for compatibility with vim-surround if needed
          vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap-forward-to)', {})
          vim.keymap.set({'n', 'x', 'o'}, 'S', '<Plug>(leap-backward-to)', {})
      end,
  },
  {
      'ThePrimeagen/harpoon',
      branch = "harpoon2", -- Using the newer version
      dependencies = { "nvim-lua/plenary.nvim" },
      event = "VeryLazy",
      config = function()
          local harpoon = require("harpoon")
          harpoon:setup()

          -- Set keymaps for Harpoon 2
          vim.keymap.set("n", "<leader>m", function() harpoon:list():append() end)
          vim.keymap.set("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

          -- Quick file navigation
          vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
          vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
          vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
          vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
      end,
  },
  {
      'unblevable/quick-scope',
      event = "VeryLazy",
      config = function()
          -- Trigger a highlight in the appropriate direction when pressing these keys
          vim.g.qs_highlight_on_keys = {'f', 'F', 't', 'T'}
      end,
  },

  -- file type plugin
  {
    "nathom/filetype.nvim",
    lazy = false, -- Load during startup
    priority = 1000, -- High priority to load before other plugins
    config = function()
      -- Basic setup with overrides
      require("filetype").setup({
        overrides = {
          extensions = {
            -- Override Lua filetype handling to not use Tree-sitter
            lua = "lua_no_ts", -- Use our custom filetype
          },
          literal = {
            -- Handle specific Lua files if needed
            [".luacheckrc"] = "lua_no_ts",
          },
          complex = {
            -- Handle all Lua files
            [".*%.lua"] = "lua_no_ts",
          },
        },
      })

      -- Create a new filetype handler that doesn't use Tree-sitter
      vim.filetype.add({
        extension = {
          lua = function()
            -- Prevent Tree-sitter based ftplugin from running
            vim.b.did_ftplugin_treesitter_lua = 1

            -- Return a string to set the filetype
            return "lua"
          end
        },
      })

      -- Register autocmds for additional safety
      local ft_group = vim.api.nvim_create_augroup("FiletypeNoTS", { clear = true })

      -- Add autocommand to disable Tree-sitter for Lua files
      vim.api.nvim_create_autocmd({"FileType"}, {
        pattern = "lua",
        callback = function()
          -- Disable Tree-sitter for Lua
          vim.b.did_ftplugin_treesitter_lua = 1
          vim.bo.syntax = "lua" -- Force traditional syntax

          -- Safely try to stop Tree-sitter if it's loaded
          pcall(function() vim.treesitter.stop() end)
        end,
        group = ft_group,
      })
    end
  },

 -- Startup time measurement
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    init = function()
      -- Execute startup time display on VimEnter
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.defer_fn(function()
            display_startup_time()
          end, 100)
        end,
      })
    end
  },

  -- Only include necessary dependencies
  { "nvim-lua/plenary.nvim", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },
}, {
  checker = { enabled = false }, -- Disable update checking
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  install = {
    colorscheme = { "tokyonight-storm" },
  },

})

-- Add early initialization hook to disable Tree-sitter for Lua
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Set critical variables to prevent the Lua Tree-sitter parser
    vim.g.do_filetype_lua = 0  -- Use the old filetype.vim
    vim.g.did_load_filetypes = 1  -- Don't load default filetype.vim

    -- Set buffer variable for any existing Lua buffers
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[bufnr].filetype == "lua" then
        vim.api.nvim_buf_set_var(bufnr, "did_ftplugin_treesitter_lua", 1)
      end
    end
  end,
  once = true,
})
