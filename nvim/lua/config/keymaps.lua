local M = {}

M.setup = function()
  local map = vim.keymap.set

  -- Better escape
  map('i', 'jk', '<Esc>', { desc = 'Exit insert mode' })

  -- Clear search highlight
  map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear highlights' })

  -- Save
  map('n', '<C-s>', '<cmd>w<CR>', { desc = 'Save file' })
  map('i', '<C-s>', '<Esc><cmd>w<CR>', { desc = 'Save file' })

  -- Quit
  map('n', '<leader>q', '<cmd>q<CR>', { desc = 'Quit' })
  map('n', '<leader>Q', '<cmd>qa!<CR>', { desc = 'Quit all (force)' })

  -- Window navigation
  map('n', '<C-h>', '<C-w>h', { desc = 'Window left' })
  map('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
  map('n', '<C-k>', '<C-w>k', { desc = 'Window up' })
  map('n', '<C-l>', '<C-w>l', { desc = 'Window right' })

  -- Window resize
  map('n', '<C-Up>',    '<cmd>resize +2<CR>',          { desc = 'Increase height' })
  map('n', '<C-Down>',  '<cmd>resize -2<CR>',           { desc = 'Decrease height' })
  map('n', '<C-Left>',  '<cmd>vertical resize -2<CR>',  { desc = 'Decrease width' })
  map('n', '<C-Right>', '<cmd>vertical resize +2<CR>',  { desc = 'Increase width' })

  -- Buffer navigation
  map('n', '<S-h>', '<cmd>bprevious<CR>', { desc = 'Prev buffer' })
  map('n', '<S-l>', '<cmd>bnext<CR>',     { desc = 'Next buffer' })
  map('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Delete buffer' })

  -- Move lines up/down in visual mode
  map('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move lines down' })
  map('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move lines up' })

  -- Keep cursor centered on search / joining
  map('n', 'n', 'nzzzv', { desc = 'Next match (centered)' })
  map('n', 'N', 'Nzzzv', { desc = 'Prev match (centered)' })
  map('n', 'J', 'mzJ`z', { desc = 'Join lines (keep cursor)' })

  -- Better indenting
  map('v', '<', '<gv', { desc = 'Unindent' })
  map('v', '>', '>gv', { desc = 'Indent' })

  -- Diagnostics
  map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev diagnostic' })
  map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
  map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic float' })
  map('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'Diagnostic list' })

  -- Split windows
  map('n', '<leader>sv', '<cmd>vsplit<CR>', { desc = 'Split vertical' })
  map('n', '<leader>sh', '<cmd>split<CR>',  { desc = 'Split horizontal' })
  map('n', '<leader>se', '<C-w>=',          { desc = 'Equalize splits' })
  map('n', '<leader>sx', '<cmd>close<CR>',  { desc = 'Close split' })
end

return M
