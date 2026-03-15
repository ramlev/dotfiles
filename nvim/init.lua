-- Bootstrap lazy.nvim
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Disable providers we don't use (performance)
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load core config before plugins
require('config.options').setup()
require('config.keymaps').setup()
require('config.autocmds').setup()

-- Load plugins
require('lazy').setup({
  spec = {
    { import = 'plugins.specs.core' },
    { import = 'plugins.specs.ui' },
    { import = 'plugins.specs.editor' },
    { import = 'plugins.specs.lsp' },
    { import = 'plugins.specs.tools' },
  },
  defaults = { lazy = true },
  install = { colorscheme = { 'tokyonight', 'habamax' } },
  checker = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip', 'matchit', 'matchparen', 'netrwPlugin',
        'tarPlugin', 'tohtml', 'tutor', 'zipPlugin',
      },
    },
  },
})
