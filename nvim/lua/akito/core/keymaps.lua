-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps
---------------------

-- explorer
-- keymap.set("n", "<leader>pv", vim.cmd.Ex)
-- use jk to exit inse)t mode
keymap.set("i", "jk", "<ESC>")

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>") -- increment
keymap.set("n", "<leader>-", "<C-x>") -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window

keymap.set("n", "<leader>to", ":tabnew<CR>") -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>") --  go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>") --  go to previous tab

----------------------
-- Plugin Keybinds
----------------------

-- neo-tree
keymap.set("n", "<leader>ee", ":Neotree toggle<CR>") -- toggle file explorer

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags

-- telescope git commands (not on youtube nvim video)
keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>") -- list all git commits (use <cr> to checkout) ["gc" for git commits]
keymap.set("n", "<leader>gfc", "<cmd>Telescope git_bcommits<cr>") -- list git commits for current file/buffer (use <cr> to checkout) ["gfc" for git file commits]
keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>") -- list git branches (use <cr> to checkout) ["gb" for git branch]
keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>") -- list current changes per file with diff preview ["gs" for git status]

-- restart lsp server (not on youtube nvim video)
keymap.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary

-- local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Move to previous/next
keymap.set("n", "<A-,>", "<Cmd>BufferPrevious<CR>", opts)
keymap.set("n", "<A-.>", "<Cmd>BufferNext<CR>", opts)
-- Re-order to previous/next
keymap.set("n", "<A-<>", "<Cmd>BufferMovePrevious<CR>", opts)
keymap.set("n", "<A->>", "<Cmd>BufferMoveNext<CR>", opts)
-- Goto buffer in position...
keymap.set("n", "<A-1>", "<Cmd>BufferGoto 1<CR>", opts)
keymap.set("n", "<A-2>", "<Cmd>BufferGoto 2<CR>", opts)
keymap.set("n", "<A-3>", "<Cmd>BufferGoto 3<CR>", opts)
keymap.set("n", "<A-4>", "<Cmd>BufferGoto 4<CR>", opts)
keymap.set("n", "<A-5>", "<Cmd>BufferGoto 5<CR>", opts)
keymap.set("n", "<A-6>", "<Cmd>BufferGoto 6<CR>", opts)
keymap.set("n", "<A-7>", "<Cmd>BufferGoto 7<CR>", opts)
keymap.set("n", "<A-8>", "<Cmd>BufferGoto 8<CR>", opts)
keymap.set("n", "<A-9>", "<Cmd>BufferGoto 9<CR>", opts)
keymap.set("n", "<A-0>", "<Cmd>BufferLast<CR>", opts)
-- Pin/unpin buffer
keymap.set("n", "<A-p>", "<Cmd>BufferPin<CR>", opts)
-- Close buffer
keymap.set("n", "<A-c>", "<Cmd>BufferClose<CR>", opts)
-- Wipeout buffer
--                 :BufferWipeout
-- Close commands
--                 :BufferCloseAllButCurrent
--                 :BufferCloseAllButPinned
--                 :BufferCloseAllButCurrentOrPinned
--                 :BufferCloseBuffersLeft
--                 :BufferCloseBuffersRight
-- Magic buffer-picking mode
keymap.set("n", "<C-p>", "<Cmd>BufferPick<CR>", opts)
-- Sort automatically by...
keymap.set("n", "<Space>bb", "<Cmd>BufferOrderByBufferNumber<CR>", opts)
keymap.set("n", "<Space>bd", "<Cmd>BufferOrderByDirectory<CR>", opts)
keymap.set("n", "<Space>bl", "<Cmd>BufferOrderByLanguage<CR>", opts)
keymap.set("n", "<Space>bw", "<Cmd>BufferOrderByWindowNumber<CR>", opts)

-- Other:
-- :BarbarEnable - enables barbar (enabled by default)
-- :BarbarDisable - very bad command, should never be used
--
-- LSP Saga
-- local keymap = vim.keymap.set
-- Lsp finder find the symbol definition implement reference
-- if there is no implement it will hide
-- when you use action in finder like open vsplit then you can
-- use <C-t> to jump back
keymap.set("n", "gh", "<cmd>Lspsaga lsp_finder<CR>")

-- Code action
keymap.set({ "n", "v" }, "<leader>ca", "<cmd>Lspsaga code_action<CR>")

-- Rename
keymap.set("n", "gr", "<cmd>Lspsaga rename<CR>")

-- Rename word in whole project
keymap.set("n", "gr", "<cmd>Lspsaga rename ++project<CR>")

-- Peek Definition
-- you can edit the definition file in this float window
-- also support open/vsplit/etc operation check definition_action_keys
-- support tagstack C-t jump back
keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>")

-- Go to Definition
keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>")

-- Show line diagnostics you can pass argument ++unfocus to make
-- show_line_diagnostics float window unfocus
keymap.set("n", "<leader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>")

-- Show cursor diagnostic
-- also like show_line_diagnostics  support pass ++unfocus
keymap.set("n", "<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>")

-- Show buffer diagnostic
keymap.set("n", "<leader>sb", "<cmd>Lspsaga show_buf_diagnostics<CR>")

-- Diagnostic jump can use `<c-o>` to jump back
keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>")

-- Diagnostic jump with filter like Only jump to error
keymap.set("n", "[E", function()
	require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
end)
keymap.set("n", "]E", function()
	require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
end)

-- Toggle Outline
keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<CR>")

-- Hover Doc
-- if there has no hover will have a notify no information available
-- to disable it just Lspsaga hover_doc ++quiet
-- press twice it will jump into hover window
keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>")
-- if you want keep hover window in right top you can use ++keep arg
-- notice if you use hover with ++keep you press this keymap it will
-- close the hover window .if you want jump to hover window must use
-- wincmd command <C-w>w
keymap.set("n", "K", "<cmd>Lspsaga hover_doc ++keep<CR>")

-- Callhierarchy
keymap.set("n", "<Leader>ci", "<cmd>Lspsaga incoming_calls<CR>")
keymap.set("n", "<Leader>co", "<cmd>Lspsaga outgoing_calls<CR>")

-- Float terminal
keymap.set({ "n", "t" }, "<A-d>", "<cmd>Lspsaga term_toggle<CR>")


-- nvim tmux
keymap.set('n', "<C-h>", "<cmd>NvimTmuxNavigateLeft<CR>")
keymap.set('n', "<C-j>", "<cmd>NvimTmuxNavigateDown<CR>")
keymap.set('n', "<C-k>", "<cmd>NvimTmuxNavigateUp<CR>")
keymap.set('n', "<C-l>", "<cmd>NvimTmuxNavigateRight<CR>")
-- keymap.set('n', "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
-- keymap.set('n', "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)

local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
