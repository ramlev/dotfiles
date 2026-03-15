return {
  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'tokyonight',
        globalstatus = true,
        disabled_filetypes = { statusline = { 'neo-tree' } },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
    },
  },

  -- Keybinding hints popup
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      delay = 500,
      icons = { mappings = true },
    },
    config = function(_, opts)
      local wk = require('which-key')
      wk.setup(opts)
      -- Register group prefixes
      wk.add({
        { '<leader>b', group = 'Buffer' },
        { '<leader>d', group = 'Diagnostics' },
        { '<leader>f', group = 'Find/File' },
        { '<leader>g', group = 'Git' },
        { '<leader>l', group = 'LSP' },
        { '<leader>s', group = 'Search' },
        { '<leader>S', group = 'Splits' },
        { '<leader>t', group = 'Terminal/Trouble' },
      })
    end,
  },

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'BufReadPost',
    main = 'ibl',
    opts = {
      indent = { char = '│' },
      scope = { enabled = false },
    },
  },
}
