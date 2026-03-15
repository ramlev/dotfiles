local M = {}

M.setup = function()
  local augroup = vim.api.nvim_create_augroup
  local autocmd = vim.api.nvim_create_autocmd

  -- Highlight on yank
  local yank_group = augroup('YankHighlight', { clear = true })
  autocmd('TextYankPost', {
    group = yank_group,
    callback = function()
      vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
    end,
  })

  -- Remove trailing whitespace on save
  local trim_group = augroup('TrimWhitespace', { clear = true })
  autocmd('BufWritePre', {
    group = trim_group,
    pattern = '*',
    callback = function()
      local pos = vim.api.nvim_win_get_cursor(0)
      vim.cmd([[%s/\s\+$//e]])
      vim.api.nvim_win_set_cursor(0, pos)
    end,
  })

  -- Resize splits when window is resized
  local resize_group = augroup('ResizeSplits', { clear = true })
  autocmd('VimResized', {
    group = resize_group,
    callback = function()
      vim.cmd('tabdo wincmd =')
    end,
  })

  -- Return to last cursor position when opening a file
  local cursor_group = augroup('RestoreCursor', { clear = true })
  autocmd('BufReadPost', {
    group = cursor_group,
    callback = function()
      local mark = vim.api.nvim_buf_get_mark(0, '"')
      local line_count = vim.api.nvim_buf_line_count(0)
      if mark[1] > 0 and mark[1] <= line_count then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end,
  })

  -- Auto-close some filetypes with q
  local close_group = augroup('CloseWithQ', { clear = true })
  autocmd('FileType', {
    group = close_group,
    pattern = { 'help', 'man', 'qf', 'startuptime', 'checkhealth', 'lspinfo' },
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = event.buf, silent = true })
    end,
  })

  -- Enable spell check for text filetypes
  local spell_group = augroup('SpellCheck', { clear = true })
  autocmd('FileType', {
    group = spell_group,
    pattern = { 'markdown', 'gitcommit', 'text' },
    callback = function()
      vim.opt_local.spell = true
      vim.opt_local.wrap = true
    end,
  })
end

return M
