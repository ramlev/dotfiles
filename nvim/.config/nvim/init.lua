vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Disable providers we don't use (performance)
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load core config before plugins
require('config.options').setup()
require('config.keymaps').setup()
require('config.autocmds').setup()

-- Plugins: every file in lua/plugins/ returns a list of specs
require('lazy').setup({
  spec = { { import = 'plugins' } },
  defaults = { lazy = true },
  install = { colorscheme = { 'tokyonight-night', 'habamax' } },
  checker = { enabled = false },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip', 'matchit', 'matchparen', 'netrwPlugin',
        'tarPlugin', 'tohtml', 'tutor', 'zipPlugin',
      },
    },
  },
})
