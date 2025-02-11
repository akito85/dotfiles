-- auto install packer if not installed
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
        vim.cmd([[packadd packer.nvim]])
        return true
    end
    return false
end
local packer_bootstrap = ensure_packer() -- true if packer was just installed

-- autocommand that reloads neovim and installs/updates/removes plugins
-- when file is saved
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins-setup.lua source <afile> | PackerSync
  augroup end
]])

-- import packer safely
local status, packer = pcall(require, "packer")
if not status then
    return
end

-- plugins installation
return require("packer").startup(function(use)
  -- Neovim package management
  use "wbthomason/packer.nvim"

  -- Theme
  use "rebelot/kanagawa.nvim"

  -- Syntax highlighting treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    run = function()
    local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
    ts_update()
    end,
    config = function()
      require("nvim-treesitter.configs").setup {
        -- A list of parser names, or "all" (the listed parsers MUST always be installed)
        ensure_installed = {
          "c",
          "lua",
          "vim",
          "vimdoc",
          "query",
          "markdown",
          "markdown_inline",
          -- additional needs
          "cpp",
          "go",
          "rust",
          "julia",
          "python",
          "javascript",
          "typescript"
        },
      }
    end,
    highlight = {
      enable = true,
    }
  })

  -- Some globally dependencies
  use "nvim-lua/plenary.nvim"
  use "nvim-tree/nvim-web-devicons"

  -- Fuzzy finding telescope
  use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
  use({ "nvim-telescope/telescope.nvim", branch = "0.1.x" })

  -- File explorer neotree
  use({
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    requires = {
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        window = {
          position = "right", -- left, right, top, bottom, float, current
          width = 41, -- applies to left and right positions
          height = 15, -- applies to top and bottom positions
          auto_expand_width = false, -- expand the window when file exceeds the window width. does not work with position = "float"
          popup = { -- settings that apply to float position only
            size = {
              height = "91%",
              width = "55%",
            },
            position = "50%", -- 50% means center it
            title = function (state) -- format the text that appears at the top of a popup window
              return "Neo-tree " .. state.name:gsub("^%l", string.upper)
            end,
          }
        },
      })
    end
  })

  -- Blank line, chunk
  use({
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("hlchunk").setup({
        chunk = {
          enable = true
        },
        indent = {
          enable = true,
            chars = {
                    "│",
            },
            style = {
              "#FF0000",
              "#FF7F00",
              "#FFFF00",
              "#00FF00",
              "#00FFFF",
              "#0000FF",
              "#8B00FF",
            },
        },
        line_num = {
          enable = true
        }
      })
    end
  })

  -- Tmux navigators
  use("alexghergh/nvim-tmux-navigation")

  -- Language servers and configurations
  use({
    "williamboman/mason.nvim",
    config = function()
      local mason = require("mason")
      mason.setup({})
    end
  })

  use({
    "williamboman/mason-lspconfig.nvim",
    config = function()
      local mason_lspconfig = require("mason-lspconfig")
       mason_lspconfig.setup({})
    end
  })

  use({
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      -- typescript / javascript lsp
      lspconfig.ts_ls.setup({})

      -- golang lsp
      lspconfig.gopls.setup({
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })

      -- rust lsp
      lspconfig.rust_analyzer.setup({
        -- Server-specific settings. See `:help lspconfig-setup`
        settings = {
          ['rust-analyzer'] = {},
        },
      })

      -- julia lsp
      lspconfig.julials.setup({
        on_new_config = function(new_config, _)
          local julia = vim.fn.expand("~/.julia/environments/nvim-lspconfig/bin/julia")
          if require("lspconfig").util.path.is_file(julia) then
            new_config.cmd[1] = julia
          end
        end,

        filetypes = {"julia", "jl"},
        root_dir = function(fname)
          local util = require("lspconfig.util")
          return util.root_pattern 'Project.toml'(fname) or util.find_git_ancestor(fname) or
             util.path.dirname(fname)
        end
      })

      -- python lsp
      lspconfig.ruff.setup({})

      -- lua lsp
      lspconfig.lua_ls.setup({
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if path ~= vim.fn.stdpath('config') and (vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc')) then
              return
            end
          end

          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              -- Tell the language server which version of Lua you're using
              -- (most likely LuaJIT in the case of Neovim)
              version = 'LuaJIT'
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME
                -- Depending on the usage, you might want to add additional paths here.
                -- "${3rd}/luv/library"
                -- "${3rd}/busted/library",
              }
              -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
              -- library = vim.api.nvim_get_runtime_file("", true)
            }
          })
        end,
        settings = {
          Lua = {}
        }
      })

      --yaml lsp
      lspconfig.yamlls.setup({})

      --tailwindcss lsp
      lspconfig.tailwindcss.setup({})

    end
  })

  -- Lspsaga
  use({
    "nvimdev/lspsaga.nvim",
    after = "nvim-lspconfig",
    config = function()
      local lspsaga = require("lspsaga")
      lspsaga.setup({})
    end,
  })

  -- Formatter
  use({
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.gofumpt,
          null_ls.builtins.formatting.golines,

          null_ls.builtins.formatting.black,
          null_ls.builtins.diagnostics.ruff,

          null_ls.builtins.formatting.julials,
          null_ls.builtins.diagnostics.julials,

          null_ls.builtins.formatting.clang_format,
          null_ls.builtins.diagnostics.cpplint,

          null_ls.builtins.formatting.prettier.with({ filetypes = { "js", "jsx", "ts", "tsx" } }),
          null_ls.builtins.diagnostics.eslint_d,

          null_ls.builtins.diagnostics.yamllint,
          null_ls.builtins.formatting.yamlfmt,

          null_ls.builtins.diagnostics.tailwindcss_language_server,

          -- null_ls.builtins.diagnostics.rust_analyzer,
          null_ls.builtins.formatting.taplo,
        },
      })
    end
  })

  use("jay-babu/mason-null-ls.nvim")

  -- Autocompletion
  use("hrsh7th/cmp-nvim-lsp")
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/cmp-path")
  use("hrsh7th/cmp-cmdline")
  use("hrsh7th/nvim-cmp")

  -- Snippets
  use({
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    tag = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!:).
    run = "make install_jsregexp"
  })

  use("saadparwaiz1/cmp_luasnip")
  use("rafamadriz/friendly-snippets")

  -- Git for add, remove, and changed lines
  use "lewis6991/gitsigns.nvim"
  use "tpope/vim-fugitive"

  -- Surround
  use "tpope/vim-surround"

  -- Repeat
  use "tpope/vim-repeat"

  -- MULTI CURSOR
  use({"mg979/vim-visual-multi", branch = "master"})
  -- use({
  --   "smoka7/multicursors.nvim",
  --   event = "VeryLazy",
  --   dependencies = {
  --       "smoka7/hydra.nvim",
  --   },
  --   opts = {},
  --   cmd = { "MCstart", "MCvisual", "MCclear", "MCpattern", "MCvisualPattern", "MCunderCursor" },
  --   keys = {
  --           {
  --               mode = { "v", "n" },
  --               "<Leader>m",
  --               "<cmd>MCstart<cr>",
  --               desc = "Create a selection for selected text or word under the cursor",
  --           },
  --       },
  -- })

  -- Status line lualine
  use "nvim-lualine/lualine.nvim"

  -- Tab or buffer
  use "romgrk/barbar.nvim"

  -- Auto closing parenthesis, brackets, tags, etc.
  use("windwp/nvim-autopairs")
  use({ "windwp/nvim-ts-autotag", after = "nvim-treesitter" })

  -- Toggle terminal
  use {
    "akinsho/toggleterm.nvim", tag = "*",
    config = function()
        require("toggleterm").setup({
          open_mapping = "<C-g>",
          direction = "float",
          shade_terminals = true
        })
    end
  }
  -- Comment block / line
  use {
    "numToStr/Comment.nvim",
    config = function()
        require("Comment").setup()
    end
  }

  use({
    "monkoose/neocodeium",
    -- event = "VeryLazy",
    opts = {
      server = {
        api_url = 'https://codeium.company.net/_route/api_server',
        portal_url = 'https://codeium.company.net',
      },
    }
  })

  -- Centered : commandline
  -- use {
  --   "VonHeikemen/fine-cmdline.nvim",
  --   requires = {
  --     {"MunifTanjim/nui.nvim"}
  --   }
  -- }

  -- Make current buffer centered
  --  use {
  --      "shortcuts/no-neck-pain.nvim",
  --      config = function()
  --          require("no-neck-pain").setup({
  --              buffers = {
  --                  left = {
  --                      enabled = false,
  --                  },
  --              },
  --          })
  --      end
  --  }
end
)
