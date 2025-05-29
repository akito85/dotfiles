-- Plugins setup with lazy.nvim
require("lazy").setup({
  -- centered column mode or zen
  {"shortcuts/no-neck-pain.nvim", version = "*"},

  -- Mason for LSP installation
  { "williamboman/mason.nvim", config = function() require("mason").setup() end },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup {
        ensure_installed = { "pyright", "ts_ls", "clangd", "rust_analyzer", "gopls", "julials", "cssls", "jsonls", "yamlls" },
      }
    end,
  },

  -- nvim tmux navigation
  {
    'numToStr/Navigator.nvim',
    config = function()
      require('Navigator').setup()

      -- Setup keymaps
      vim.keymap.set({'n', 't'}, '<C-h>', '<CMD>NavigatorLeft<CR>')
      vim.keymap.set({'n', 't'}, '<C-l>', '<CMD>NavigatorRight<CR>')
      vim.keymap.set({'n', 't'}, '<C-k>', '<CMD>NavigatorUp<CR>')
      vim.keymap.set({'n', 't'}, '<C-j>', '<CMD>NavigatorDown<CR>')
    end
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lspconfig = require('lspconfig')
      local servers = { 'pyright', 'ts_ls', 'clangd', 'rust_analyzer', 'gopls', 'julials', 'cssls', 'jsonls', 'yamlls' }

      -- Disable diagnostics for large files
      local function disable_diagnostics_for_large_files()
        local max_filesize = 10 * 1024 * 1024 -- 10MB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
        if ok and stats and stats.size > max_filesize then
          vim.diagnostic.disable(0)
        end
      end

      vim.api.nvim_create_autocmd("BufReadPost", {
        callback = disable_diagnostics_for_large_files,
      })

      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
          capabilities = require('cmp_nvim_lsp').default_capabilities(),
          flags = { debounce_text_changes = 150 },
          handlers = {
            ["textDocument/publishDiagnostics"] = vim.lsp.with(
              vim.lsp.diagnostic.on_publish_diagnostics, {
                update_in_insert = false,
                virtual_text = false,
                severity_sort = true,
                underline = false,
              }
            ),
          },
        }
      end

      -- Rust-specific configuration
      lspconfig.rust_analyzer.setup {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        flags = { debounce_text_changes = 150 },
        settings = {
          ['rust-analyzer'] = {
            checkOnSave = {
              command = "clippy", -- Use clippy for linting
            },
            completion = {
              autoimport = {
                enable = true, -- Auto-import suggestions
              },
            },
            diagnostics = {
              enable = true,
            },
          },
        },
      }

      -- Go-specific configuration
      lspconfig.gopls.setup {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        flags = { debounce_text_changes = 150 },
        settings = {
          gopls = {
            completeUnimported = true, -- Auto-import completions
            usePlaceholders = true, -- Add placeholders for function arguments
            analyses = {
              unusedparams = true,
              shadow = true,
            },
          },
        },
      }

      -- JavaScript/TypeScript-specific configuration
      lspconfig.ts_ls.setup {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        flags = { debounce_text_changes = 150 },
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayFunctionLikeReturnTypeHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayFunctionLikeReturnTypeHints = true,
            },
          },
        },
      }

      -- Julia-specific configuration
      lspconfig.julials.setup {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        flags = { debounce_text_changes = 150 },
        settings = {
          julia = {
            lint = {
              enabled = true, -- Enable linting
            },
            completion = {
              enable = true, -- Enable completions
            },
            runtime = {
              version = "stable", -- Use the stable Julia version
            },
          },
        },

        -- Specify the command to start julials (optional, Mason handles this)
        cmd = { "julia", "--project=~/.julia/environments/nvim-lspconfig", "-e", "using LanguageServer; runserver()" },
        on_new_config = function(new_config, new_root_dir)
          -- Ensure the Julia environment is set up
          local julia_env = vim.fn.expand("~/.julia/environments/nvim-lspconfig")
          if not vim.fn.isdirectory(julia_env) then
            os.execute("julia -e 'using Pkg; Pkg.add(\"LanguageServer\"); Pkg.add(\"SymbolServer\")'")
          end
        end,
      }

      -- Python-specific configuration
      lspconfig.pyright.setup {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        flags = { debounce_text_changes = 150 },
        settings = {
          python = {
            analysis = {
              autoImportCompletions = true,
              typeCheckingMode = "basic", -- Options: "off", "basic", "strict"
              diagnosticMode = "openFilesOnly", -- Reduce diagnostics for large projects
            },
          },
        },
      }

      -- C/C++-specific configuration
      lspconfig.clangd.setup {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        flags = { debounce_text_changes = 1 },
        cmd = { "clangd", "--background-index", "--suggest-missing-includes", "--clang-tidy" },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        settings = {
          clangd = {
            fallbackFlags = { "-std=c++17" }, -- Default standard for C++
          },
        },
      }

      -- CSS LSP
      lspconfig.cssls.setup {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        flags = { debounce_text_changes = 150 },
      }

      -- JSON LSP
      lspconfig.jsonls.setup {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        flags = { debounce_text_changes = 150 },
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      }

      -- YAML LSP
      lspconfig.yamlls.setup {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        flags = { debounce_text_changes = 150 },
        settings = {
          yaml = {
            schemas = require('schemastore').yaml.schemas(),
            validate = true,
          },
        },
      }

      -- Keymaps
      vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { noremap = true, silent = true })
      vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, { noremap = true, silent = true })
      vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, { noremap = true, silent = true })
      vim.keymap.set('n', '<leader>gh', vim.lsp.buf.hover, { noremap = true, silent = true })
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { noremap = true, silent = true })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { noremap = true, silent = true })
    end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "b0o/schemastore.nvim",
    },
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      require("luasnip.loaders.from_vscode").lazy_load()

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
          { name = 'buffer', max_item_count = 8, keyword_length = 4 },
          { name = 'path', max_item_count = 5 },
        }),
        performance = {
          max_view_entries = 8,
          debounce = 150,
          throttle = 80,
          fetching_timeout = 100,
        },
      })

      cmp.setup.filetype({ 'json', 'yaml' }, {
        sources = cmp.config.sources({
          { name = 'nvim_lsp', max_item_count = 10 },
          { name = 'buffer', max_item_count = 8, keyword_length = 4 },
          { name = 'path', max_item_count = 5 },
        }),
      })
    end,
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
        event_handlers = {
          -- Fix for buffer clearing issue - don't unload current buffer on file_open
          {
            event = "file_opened",
            handler = function(file_path)
              -- Don't close the tree when opening a file
              -- and don't clear the buffer
              -- require("neo-tree.sources.manager").close_all()
              -- Optionally focus the opened file
              -- vim.cmd("e " .. vim.fn.fnameescape(file_path))
              vim.defer_fn(function()
                vim.cmd("e " .. vim.fn.fnameescape(file_path))
              end, 10)
            end
          },
        },
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
    end
  },


  -- vim-gigutter - Lightweight git gutter for large files
  {
    "airblade/vim-gitgutter",
    event = "BufReadPre",
    init = function()
      -- Optimize gitgutter for performance
      vim.g.gitgutter_max_signs = 500
      vim.g.gitgutter_realtime = 0
      vim.g.gitgutter_eager = 0
      vim.g.gitgutter_sign_priority = 5
      vim.g.LargeFile = 10 -- 10 MB, matches LSP max_filesize

      -- Disable gitgutter for large files
      local git_group = vim.api.nvim_create_augroup("GitGutterLargeFiles", { clear = true })
      vim.api.nvim_create_autocmd({"BufReadPre"}, {
        group = git_group,
        callback = function(ev)
          local max_filesize = vim.g.LargeFile * 1024 * 1024 -- Convert MB to bytes
          local ok, stats = pcall(vim.loop.fs_stat, ev.match)
          if ok and stats and (stats.size > max_filesize or stats.type == "directory") then
            vim.b.gitgutter_enabled = 0
          end
        end,
      })
    end
  },

  -- far.vim - Find and replace with performance in mind
  {
    "brooth/far.vim",
    cmd = {"Far", "Farp", "F", "Refar"},
    keys = {
      { "<leader>ffr", ":Far ", desc = "Find and Replace" },
      { "<leader>ffd", ":Fardo<CR>", desc = "Execute Far Replace" },
    },
    init = function()
      -- Configure Far.vim for better performance
      vim.g['far#source'] = vim.fn.executable("rg") == 1 and "rg" or "vimgrep"
      vim.g['far#limit'] = 1000
      vim.g['far#window_width'] = 60
      vim.g['far#file_mask_favorites'] = { "**/*.*", "**/*.lua", "**/*.vim", "**/*.txt" }
    end
  },

  -- nvim-lsp-file-operations - LSP-aware file operations
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
    },
    event = "LspAttach",
    config = function()
      require("lsp-file-operations").setup({
        -- Disable for large files
        enabled = function(bufnr)
          return not vim.b[bufnr].large_file
        end
      })
    end
  },

  -- Low-resource status line
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = false, -- Disable icons for performance
          theme = 'auto',
          component_separators = '|',
          section_separators = '',
          disabled_filetypes = {},
          always_divide_middle = false,
          globalstatus = false, -- Use per-window statuslines
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'filename'},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {'filename'},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {'location'}
        },
        -- Optimize for large files
        extensions = {
          function()
            -- Custom extension for large files
            local large_file_extension = {
              sections = {
                lualine_a = {'mode'},
                lualine_b = {'filename'},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {'progress'},
                lualine_z = {}
              },
              inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {'filename'},
                lualine_x = {},
                lualine_y = {},
                lualine_z = {}
              },
              filetypes = {'*'}
            }

            return large_file_extension
          end
        }
      }

      -- Create a custom status line for large files
      local status_group = vim.api.nvim_create_augroup("StatuslineLargeFiles", { clear = true })
      vim.api.nvim_create_autocmd({"BufReadPre", "FileReadPre"}, {
        group = status_group,
        callback = function(ev)
          local file_size = vim.fn.getfsize(ev.match)
          if file_size > (vim.g.LargeFile or 10) * 1024 * 1024 or file_size == -2 then
            vim.opt_local.statusline = " %f %m%r%h%w [%{&ff}] "
            vim.opt_local.ruler = true
            vim.opt_local.laststatus = 1 -- Use a simplified statusline
          end
        end,
      })
    end
  },

  -- buffer manager that's light on resources
  {
    "j-morano/buffer_manager.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>b", "<cmd>lua require('buffer_manager.ui').toggle_quick_menu()<CR>", desc = "Buffer Manager" },
    },
    config = function()
      require("buffer_manager").setup({
        line_keys = "1234567890",
        select_menu_item_commands = {
          v = {
            key = "<C-v>",
            command = "vsplit"
          },
          h = {
            key = "<C-h>",
            command = "split"
          }
        },
        focus_alternate_buffer = false,
        short_file_names = true,
        short_term_names = true,
        loop_nav = true,
      })
    end
  },

  -- TreeSitter configuration with unified and optimized performance thresholds
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      -- UNIFIED FILE SIZE THRESHOLDS (aligned across all configs)
      -- These should match your performance.lua and large_file.lua thresholds
      local SMALL_FILE_THRESHOLD = 512 * 1024        -- 512KB - full features
      local MEDIUM_FILE_THRESHOLD = 5 * 1024 * 1024  -- 5MB - reduce textobjects
      local LARGE_FILE_THRESHOLD = 50 * 1024 * 1024  -- 50MB - minimal TreeSitter
      local HUGE_FILE_THRESHOLD = 500 * 1024 * 1024  -- 500MB - disable TreeSitter

      -- Helper function to get file size safely
      local function get_file_size(buf)
        local name = vim.api.nvim_buf_get_name(buf or 0)
        if name == "" then return 0 end
        local size = vim.fn.getfsize(name)
        return size > 0 and size or 0
      end

      -- Optimized disable function with proper tier logic
      local function should_disable_feature(lang, buf, feature_level)
        local filesize = get_file_size(buf)
        
        -- Never disable for very small files (< 512KB)
        if filesize <= SMALL_FILE_THRESHOLD then
          return false
        end
        
        -- Feature level tiers:
        -- 1 = basic features (highlight, indent) - disable at HUGE_FILE_THRESHOLD
        -- 2 = advanced features (textobjects) - disable at LARGE_FILE_THRESHOLD  
        -- 3 = complex features (move, swap, lsp_interop) - disable at MEDIUM_FILE_THRESHOLD
        
        if feature_level == 1 and filesize >= HUGE_FILE_THRESHOLD then
          return true
        elseif feature_level == 2 and filesize >= LARGE_FILE_THRESHOLD then
          return true
        elseif feature_level == 3 and filesize >= MEDIUM_FILE_THRESHOLD then
          return true
        end
        
        -- Special cases for resource-intensive language combinations
        local intensive_langs = { "markdown", "html", "xml", "json", "yaml" }
        if vim.tbl_contains(intensive_langs, lang) then
          if feature_level >= 2 and filesize >= (MEDIUM_FILE_THRESHOLD / 2) then -- 2.5MB
            return true
          end
        end
        
        return false
      end

      require("nvim-treesitter.configs").setup({
        -- Essential parsers (optimized list)
        ensure_installed = {
          "lua", "vim", "vimdoc", "query", -- Core Neovim
          "rust", "go", "python", "javascript", "typescript", "tsx", -- Popular languages
          "json", "yaml", "markdown", "markdown_inline", -- Data formats
          "bash", "sql", "html", "css", "c", "cpp" -- Utilities
        },

        -- Performance settings
        sync_install = false,
        auto_install = true,
        ignore_install = {}, -- Don't ignore any parsers

        -- TIER 1: Basic syntax highlighting and indentation
        highlight = {
          enable = true,
          disable = function(lang, buf)
            return should_disable_feature(lang, buf, 1) -- Only disable for huge files (500MB+)
          end,
          additional_vim_regex_highlighting = false,
          use_languagetree = true, -- Better for large files
        },

        indent = {
          enable = true,
          disable = function(lang, buf)
            -- More conservative for indent - can cause performance issues
            local filesize = get_file_size(buf)
            if filesize >= LARGE_FILE_THRESHOLD then return true end
            
            -- Known problematic languages for indentation
            local problematic_langs = { "python", "yaml", "markdown" }
            if vim.tbl_contains(problematic_langs, lang) and filesize >= MEDIUM_FILE_THRESHOLD then
              return true
            end
            
            return false
          end,
        },

        -- TIER 2: Advanced selection features
        incremental_selection = {
          enable = true,
          disable = function(lang, buf)
            return should_disable_feature(lang, buf, 2) -- Disable at 50MB+
          end,
          keymaps = {
            init_selection = '<CR>',
            scope_incremental = '<CR>',
            node_incremental = '<TAB>',
            node_decremental = '<S-TAB>',
          },
        },

        -- TIER 3: Complex textobjects (most resource intensive)
        textobjects = {
          select = {
            enable = true,
            disable = function(lang, buf)
              return should_disable_feature(lang, buf, 3) -- Disable at 5MB+
            end,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer", 
              ["ia"] = "@parameter.inner",
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inner",
            },
            selection_modes = {
              ['@parameter.outer'] = 'v',
              ['@function.outer'] = 'V',
              ['@class.outer'] = '<c-v>',
            },
            include_surrounding_whitespace = false, -- Performance optimization
          },

          move = {
            enable = true,
            disable = function(lang, buf)
              return should_disable_feature(lang, buf, 3) -- Disable at 5MB+
            end,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer", 
              ["]a"] = "@parameter.outer",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]C"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
              ["[a"] = "@parameter.outer",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer", 
              ["[C"] = "@class.outer",
            },
          },

          swap = {
            enable = true,
            disable = function(lang, buf)
              return should_disable_feature(lang, buf, 3) -- Disable at 5MB+
            end,
            swap_next = {
              ["<leader>sp"] = "@parameter.inner",
            },
            swap_previous = {
              ["<leader>sP"] = "@parameter.inner",
            },
          },

          lsp_interop = {
            enable = true,
            disable = function(lang, buf)
              return should_disable_feature(lang, buf, 3) -- Disable at 5MB+
            end,
            border = 'rounded',
            floating_preview_opts = {
              max_width = 80,
              max_height = 20,
            },
            peek_definition_code = {
              ["<leader>df"] = "@function.outer",
              ["<leader>dc"] = "@class.outer",
            },
          },
        },

        -- Performance optimizations
        query_linter = {
          enable = true,
          use_virtual_text = true,
          lint_events = {"BufWrite", "CursorHold"},
        },
      })

      -- Enhanced performance management with proper tiers
      local function manage_treesitter_performance(buf)
        local filesize = get_file_size(buf)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
        
        -- Set appropriate syntax sync for different file sizes
        if filesize <= SMALL_FILE_THRESHOLD then
          -- Small files: full performance
          vim.bo[buf].synmaxcol = 0 -- No limit
          pcall(function() vim.cmd("syntax sync fromstart") end)
          
        elseif filesize <= MEDIUM_FILE_THRESHOLD then
          -- Medium files: balanced performance
          vim.bo[buf].synmaxcol = 300
          pcall(function() vim.cmd("syntax sync minlines=100 maxlines=200") end)
          vim.notify(sprintf("TreeSitter optimized for medium file: %s (%.1fMB)", 
            filename, filesize / 1024 / 1024), vim.log.levels.INFO)
          
        elseif filesize <= LARGE_FILE_THRESHOLD then
          -- Large files: reduced features
          vim.bo[buf].synmaxcol = 200
          pcall(function() vim.cmd("syntax sync minlines=50 maxlines=100") end)
          vim.notify(sprintf("TreeSitter reduced for large file: %s (%.1fMB)", 
            filename, filesize / 1024 / 1024), vim.log.levels.WARN)
          
        else
          -- Huge files: minimal features
          vim.bo[buf].synmaxcol = 128
          pcall(function() vim.cmd("syntax sync minlines=10 maxlines=50") end)
          vim.notify(sprintf("TreeSitter minimal for huge file: %s (%.1fMB)", 
            filename, filesize / 1024 / 1024), vim.log.levels.ERROR)
        end
      end

      -- Performance management autocommands
      local group = vim.api.nvim_create_augroup("TreeSitterPerformance", { clear = true })

      vim.api.nvim_create_autocmd({"BufReadPost", "BufNewFile"}, {
        group = group,
        callback = function(ev)
          -- Defer to ensure buffer is fully loaded
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(ev.buf) then
              manage_treesitter_performance(ev.buf)
            end
          end, 50) -- Increased delay for stability
        end
      })

      -- Cleanup for performance on buffer changes
      vim.api.nvim_create_autocmd("BufWinLeave", {
        group = group,
        callback = function()
          -- Force garbage collection when leaving large buffers
          local filesize = get_file_size()
          if filesize > MEDIUM_FILE_THRESHOLD then
            vim.defer_fn(function()
              collectgarbage("collect")
            end, 100)
          end
        end
      })

      -- Enhanced user commands
      vim.api.nvim_create_user_command("TSStatus", function()
        local buf = vim.api.nvim_get_current_buf()
        local filesize = get_file_size(buf)
        local bufname = vim.api.nvim_buf_get_name(buf)
        local filetype = vim.bo[buf].filetype
        local filename = vim.fn.fnamemodify(bufname, ":t")
        
        -- Determine performance tier
        local tier, tier_desc
        if filesize <= SMALL_FILE_THRESHOLD then
          tier, tier_desc = "SMALL", "Full TreeSitter features"
        elseif filesize <= MEDIUM_FILE_THRESHOLD then
          tier, tier_desc = "MEDIUM", "Reduced textobjects"  
        elseif filesize <= LARGE_FILE_THRESHOLD then
          tier, tier_desc = "LARGE", "Basic features only"
        else
          tier, tier_desc = "HUGE", "Minimal TreeSitter"
        end
        
        print(string.format("=== TreeSitter Status ==="))
        print(string.format("File: %s", filename))
        print(string.format("Size: %.2f KB (%.2f MB)", filesize / 1024, filesize / 1024 / 1024))
        print(string.format("Type: %s", filetype))
        print(string.format("Tier: %s - %s", tier, tier_desc))
        print("")
        
        -- Check feature status
        local features = {
          { name = "Highlight", level = 1, threshold = HUGE_FILE_THRESHOLD },
          { name = "Indent", level = 1, threshold = LARGE_FILE_THRESHOLD },
          { name = "Selection", level = 2, threshold = LARGE_FILE_THRESHOLD },
          { name = "Textobjects", level = 3, threshold = MEDIUM_FILE_THRESHOLD },
        }
        
        for _, feature in ipairs(features) do
          local disabled = should_disable_feature(filetype, buf, feature.level)
          local status = disabled and "❌ DISABLED" or "✅ ENABLED"
          print(string.format("%-12s %s", feature.name .. ":", status))
        end
      end, { desc = "Show detailed TreeSitter status" })

      vim.api.nvim_create_user_command("TSOptimize", function()
        local buf = vim.api.nvim_get_current_buf()
        manage_treesitter_performance(buf)
        vim.notify("TreeSitter performance optimized for current buffer", vim.log.levels.INFO)
      end, { desc = "Manually optimize TreeSitter for current buffer" })

      vim.api.nvim_create_user_command("TSForceEnable", function()
        local buf = vim.api.nvim_get_current_buf()
        pcall(function() vim.cmd("TSBufEnable highlight") end)
        pcall(function() vim.cmd("TSBufEnable indent") end) 
        pcall(function() vim.cmd("TSBufEnable incremental_selection") end)
        vim.notify("TreeSitter features force-enabled (may impact performance)", vim.log.levels.WARN)
      end, { desc = "Force enable all TreeSitter features" })

      vim.api.nvim_create_user_command("TSForceDisable", function()
        pcall(function() vim.cmd("TSBufDisable highlight") end)
        pcall(function() vim.cmd("TSBufDisable indent") end)
        pcall(function() vim.cmd("TSBufDisable incremental_selection") end)
        vim.notify("TreeSitter features disabled", vim.log.levels.INFO)
      end, { desc = "Force disable TreeSitter features" })
    end,
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
