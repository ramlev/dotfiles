vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Disable providers we don't use (performance)
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

-- Disable bundled plugins we don't use
for _, name in ipairs({
  'gzip', 'matchit', 'matchparen', 'netrw', 'netrwPlugin',
  'tarPlugin', 'tutor_mode_plugin', 'zipPlugin',
}) do
  vim.g['loaded_' .. name] = 1
end

-- Load core config before plugins
require('config.options').setup()
require('config.keymaps').setup()
require('config.autocmds').setup()

-- Build steps for plugins managed by vim.pack. Must be registered before the
-- first vim.pack.add() so they also run on a fresh install.
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('PackHooks', { clear = true }),
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then
      return
    end

    if name == 'telescope-fzf-native.nvim' and vim.fn.executable('make') == 1 then
      vim.system({ 'make' }, { cwd = ev.data.path }):wait()
    elseif name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then
        vim.cmd.packadd('nvim-treesitter')
      end
      vim.cmd('TSUpdate')
    end
  end,
})

-- Plugins (vim.pack, built into Neovim 0.12). Update with :lua vim.pack.update()
require('plugins.core')
require('plugins.ui')
require('plugins.editor')
require('plugins.lsp')
require('plugins.tools')
require('plugins.dev')
