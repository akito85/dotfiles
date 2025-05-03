-- ~/.config/nvim/lua/core/keymaps.lua
-- Core keybindings (non-plugin specific)

-- Essential keybindings

-- Fast escape with a rolling motion
vim.keymap.set('i', 'jk', '<ESC>', { noremap = true, silent = true })
-- Remove duplicate escape sequence (one is sufficient for muscle memory)

-- Faster home/end navigation
vim.keymap.set('n', 'H', '^', { noremap = true })
vim.keymap.set('n', 'L', '$', { noremap = true })

-- Add visual mode support for H/L
vim.keymap.set('v', 'H', '^', { noremap = true })
vim.keymap.set('v', 'L', '$', { noremap = true })

-- Window navigation - standardize on Ctrl keys for window movement
-- This avoids the delay waiting for leader key sequences
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

-- Buffer navigation with space+[] (more ergonomic than n/p)
vim.keymap.set('n', '<leader>[', ':bprevious<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>]', ':bnext<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>d', ':bdelete<CR>', { noremap = true, silent = true })

-- Quick save and quit
vim.keymap.set('n', '<leader>w', ':w<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>q', ':q<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>Q', ':qa!<CR>', { noremap = true, silent = true })

-- Clear search highlighting
vim.keymap.set('n', '<Esc>', ':nohlsearch<CR>', { noremap = true, silent = true })

-- Split windows
vim.keymap.set('n', '<leader>v', ':vsplit<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>s', ':split<CR>', { noremap = true, silent = true })

-- Terminal mode escape
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })
vim.keymap.set('t', 'jk', '<C-\\><C-n>', { noremap = true, silent = true })

-- Quick terminal
vim.keymap.set('n', '<leader>t', ':terminal<CR>', { noremap = true, silent = true })

-- Better line movement (respects wrapped lines)
vim.keymap.set('n', 'j', 'gj', { noremap = true, silent = true })
vim.keymap.set('n', 'k', 'gk', { noremap = true, silent = true })

-- Jump between paragraphs with J/K
vim.keymap.set('n', 'J', '}', { noremap = true, silent = true })
vim.keymap.set('n', 'K', '{', { noremap = true, silent = true })
vim.keymap.set('v', 'J', '}', { noremap = true, silent = true })
vim.keymap.set('v', 'K', '{', { noremap = true, silent = true })

-- Center cursor when moving half-page up/down
vim.keymap.set('n', '<C-d>', '<C-d>zz', { noremap = true, silent = true })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { noremap = true, silent = true })

-- Center search results
vim.keymap.set('n', 'n', 'nzzzv', { noremap = true, silent = true })
vim.keymap.set('n', 'N', 'Nzzzv', { noremap = true, silent = true })

-- Center the view
vim.keymap.set('n', '<Leader>n', '<cmd>NoNeckPain<cr>', { noremap = true, silent = true, desc = 'Toggle NoNeckPain' })
