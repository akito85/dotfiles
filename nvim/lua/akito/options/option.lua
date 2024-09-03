if vim.g.neovide then 
    vim.o.guifont = "FiraCode Nerd Font Mono:h11"
    vim.g.neovide_cursor_vfx_mode = "railgun"
end

local opt = vim.opt

-- autoread
opt.autoread = true

-- line numbers
opt.relativenumber = true
opt.number = true

-- tabs & identation
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- disable swap file
opt.swapfile = false
opt.backup = false

opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

-- line wrapping
opt.wrap = false

-- search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- cursor line
opt.cursorline = true

-- appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start"

opt.scrolloff = 8
opt.signcolumn = "yes"
opt.isfname:append("@-@")
opt.updatetime = 50
--opt.colorcolumn = "80"

-- clipboard
opt.clipboard:append("unnamedplus")
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
end

-- split windows
opt.splitright = true
opt.splitbelow = true

opt.iskeyword:append("-")

-- opt.list = true
-- opt.listchars:append("space:⋅")
-- opt.listchars:append("eol:↴")

--require("indent_blankline").setup({
--  space_char_blankline = " ",
--  show_current_context = true,
--  show_current_context_start = true,
--})

-- vim.api.nvim_set_keymap('n', ':', '<cmd>FineCmdline<CR>', {noremap = true})

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        vim.cmd("NoNeckPain")
    end,
})
