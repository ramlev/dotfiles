local M = {}

M.setup = function()
  local opt = vim.opt

  -- Line numbers
  opt.number = true
  opt.relativenumber = true

  -- Tabs & indentation
  opt.tabstop = 2
  opt.shiftwidth = 2
  opt.expandtab = true
  opt.autoindent = true
  opt.smartindent = true

  -- Line wrapping
  opt.wrap = false

  -- Search
  opt.ignorecase = true
  opt.smartcase = true
  opt.hlsearch = true
  opt.incsearch = true

  -- Appearance
  opt.termguicolors = true
  opt.signcolumn = 'yes'
  opt.cursorline = true
  opt.scrolloff = 8
  opt.sidescrolloff = 8
  opt.colorcolumn = '100'

  -- Split behavior
  opt.splitright = true
  opt.splitbelow = true

  -- Backspace
  opt.backspace = 'indent,eol,start'

  -- Clipboard
  opt.clipboard = 'unnamedplus'

  -- Undo
  opt.undofile = true
  opt.undolevels = 1000

  -- Backup / swap
  opt.backup = false
  opt.swapfile = false

  -- Completion
  opt.completeopt = 'menuone,noinsert,noselect'
  opt.pumheight = 10

  -- Update time
  opt.updatetime = 250
  opt.timeoutlen = 300

  -- Mouse
  opt.mouse = 'a'

  -- Encoding
  opt.encoding = 'utf-8'
  opt.fileencoding = 'utf-8'

  -- Fold (use treesitter when available)
  opt.foldmethod = 'indent'
  opt.foldlevel = 99

  -- Misc
  opt.showmode = false   -- lualine shows the mode
  opt.cmdheight = 1
  opt.conceallevel = 0
end

return M
