return {
  -- Dashboard / splash screen
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local alpha = require('alpha')
      local dashboard = require('alpha.themes.dashboard')

      dashboard.section.header.val = {
        '██████╗  █████╗ ███╗   ███╗██╗     ███████╗██╗   ██╗   ██████╗ ██╗  ██╗',
        '██╔══██╗██╔══██╗████╗ ████║██║     ██╔════╝██║   ██║   ██╔══██╗██║ ██╔╝',
        '██████╔╝███████║██╔████╔██║██║     █████╗  ██║   ██║   ██║  ██║█████╔╝ ',
        '██╔══██╗██╔══██║██║╚██╔╝██║██║     ██╔══╝  ╚██╗ ██╔╝   ██║  ██║██╔═██╗ ',
        '██║  ██║██║  ██║██║ ╚═╝ ██║███████╗███████╗ ╚████╔╝ ██╗██████╔╝██║  ██╗',
        '╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝  ╚═══╝  ╚═╝╚═════╝ ╚═╝  ╚═╝',
      }

      dashboard.section.buttons.val = {
        dashboard.button('f', '  Find file',    ':Telescope find_files <CR>'),
        dashboard.button('e', '  New file',     ':ene <BAR> startinsert <CR>'),
        dashboard.button('r', '  Recent files', ':Telescope oldfiles <CR>'),
        dashboard.button('g', '  Find text',    ':Telescope live_grep <CR>'),
        dashboard.button('q', '  Quit',         ':qa<CR>'),
      }

      dashboard.section.footer.val = ''

      dashboard.opts.opts.noautocmd = true
      alpha.setup(dashboard.opts)
    end,
  },

  -- Statusline — mirrors the tmux status bar: a filled pill for the mode,
  -- the current file in a soft pill, muted "icon text" info on the right,
  -- all on a transparent background.
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = function()
      -- TokyoNight Night, same values as the @tn_* options in tmux.conf.
      local tn = {
        bg       = '#1a1b26',
        gutter   = '#3b4261',
        comment  = '#565f89',
        fg_dark  = '#a9b1d6',
        fg       = '#c0caf5',
        blue     = '#7aa2f7',
        cyan     = '#7dcfff',
        teal     = '#73daca',
        magenta  = '#bb9af7',
        red      = '#f7768e',
        yellow   = '#e0af68',
        green    = '#9ece6a',
      }

      -- Accent per mode, like tmux's blue / red (prefix) / yellow (copy mode).
      local function mode(accent)
        return {
          a = { fg = tn.bg, bg = accent, gui = 'bold' },
          b = { fg = tn.fg_dark, bg = 'None' },
          c = { fg = tn.fg_dark, bg = 'None' },
        }
      end
      local theme = {
        normal   = mode(tn.blue),
        insert   = mode(tn.green),
        visual   = mode(tn.yellow),
        replace  = mode(tn.red),
        command  = mode(tn.magenta),
        terminal = mode(tn.teal),
        inactive = mode(tn.comment),
      }

      -- Nerd Font glyphs as byte escapes so they survive any editor.
      local g = {
        pill_l = '\238\130\182', -- U+E0B6
        pill_r = '\238\130\180', -- U+E0B4
        vim    = '\238\152\171', -- U+E62B
        branch = '\238\130\160', -- U+E0A0
        file   = '\239\131\182', -- U+F0F6
        lock   = '\239\128\163', -- U+F023
        line   = '\238\130\161', -- U+E0A1
      }
      local pill = { left = g.pill_l, right = g.pill_r }

      local muted = { fg = tn.comment }

      return {
        options = {
          theme = theme,
          globalstatus = true,
          section_separators = '',
          component_separators = '',
          disabled_filetypes = { statusline = { 'neo-tree' } },
        },
        sections = {
          lualine_a = {
            { 'mode', icon = g.vim, fmt = string.lower, separator = pill, padding = { left = 1, right = 0 } },
          },
          lualine_b = {
            { 'branch', icon = { g.branch, color = muted }, padding = { left = 2, right = 1 } },
            {
              'diff',
              diff_color = { added = { fg = tn.green }, modified = { fg = tn.yellow }, removed = { fg = tn.red } },
            },
          },
          lualine_c = {
            {
              'filename',
              path = 1,
              icon = { g.file, color = { fg = tn.cyan, bg = tn.gutter, gui = 'bold' } },
              color = { fg = tn.fg, bg = tn.gutter },
              separator = pill,
              padding = 0,
              symbols = { modified = ' ●', readonly = ' ' .. g.lock, unnamed = '[No Name]', newfile = '[New]' },
            },
          },
          lualine_x = {
            {
              'diagnostics',
              diagnostics_color = {
                error = { fg = tn.red }, warn = { fg = tn.yellow }, info = { fg = tn.cyan }, hint = { fg = tn.teal },
              },
            },
            { 'filetype', colored = false, icon = { align = 'left' }, color = { fg = tn.fg_dark } },
          },
          lualine_y = {},
          lualine_z = {
            { 'location', icon = { g.line, color = muted }, color = { fg = tn.fg_dark, bg = 'None', gui = 'none' } },
          },
        },
      }
    end,
  },

  -- Open buffers as tabs along the top
  {
    'akinsho/bufferline.nvim',
    version = '*',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<leader>bp', '<cmd>BufferLinePick<CR>',        desc = 'Pick buffer' },
      { '<leader>bo', '<cmd>BufferLineCloseOthers<CR>', desc = 'Close other buffers' },
      { '<leader>bP', '<cmd>BufferLineTogglePin<CR>',   desc = 'Pin buffer' },
    },
    opts = {
      options = {
        diagnostics = 'nvim_lsp',
        always_show_bufferline = false,
        offsets = {
          { filetype = 'neo-tree', text = 'Files', highlight = 'Directory', separator = true },
        },
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
        { '<leader>T', group = 'Test' },
        { '<leader>x', group = 'Debug' },
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
