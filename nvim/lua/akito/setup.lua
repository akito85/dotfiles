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
return require('packer').startup(function(use)
  -- Neovim package management
  use "wbthomason/packer.nvim"

  -- Theme
  use "catppuccin/nvim"

  -- Syntax highlighting treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    run = function()
    local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
    ts_update()
    end,
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
    }
  })

  -- Window pickers
  use({
    's1n7ax/nvim-window-picker',
    tag = 'v1.*',
    config = function()
        require'window-picker'.setup()
    end,
  })

  -- Tmux navigators
  use("alexghergh/nvim-tmux-navigation")

  -- Language servers and configurations
  use("williamboman/mason.nvim")
  use("williamboman/mason-lspconfig.nvim")
  use("neovim/nvim-lspconfig")
  use({
    "glepnir/lspsaga.nvim",
    opt = true,
    branch = "main",
    event = "LspAttach",
    requires = {
        {"nvim-tree/nvim-web-devicons"},
        --Please make sure you install markdown and markdown_inline parser
        {"nvim-treesitter/nvim-treesitter"}
    }
  })

  use("jose-elias-alvarez/null-ls.nvim")
  use("jayp0521/mason-null-ls.nvim")

  -- Autocompletion
  use("hrsh7th/cmp-nvim-lsp")
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/cmp-path")
  use("hrsh7th/cmp-cmdline")
  use("hrsh7th/nvim-cmp")

  -- Snippets
  use("L3MON4D3/LuaSnip")
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
  --       'smoka7/hydra.nvim',
  --   },
  --   opts = {},
  --   cmd = { 'MCstart', 'MCvisual', 'MCclear', 'MCpattern', 'MCvisualPattern', 'MCunderCursor' },
  --   keys = {
  --           {
  --               mode = { 'v', 'n' },
  --               '<Leader>m',
  --               '<cmd>MCstart<cr>',
  --               desc = 'Create a selection for selected text or word under the cursor',
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
    "akinsho/toggleterm.nvim", tag = '*', config = function()
        require('toggleterm').setup({
          open_mapping = '<C-g>',
          direction = 'float',
          shade_terminals = true
        })
    end
  }
  -- Comment block / line
  use {
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup()
    end
  }

  -- Centered : commandline
  use {
    'VonHeikemen/fine-cmdline.nvim',
    requires = {
      {'MunifTanjim/nui.nvim'}
    }
  }

end
)
