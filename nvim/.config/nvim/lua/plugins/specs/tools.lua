return {
  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable('make') == 1 end,
      },
    },
    keys = {
      { '<leader>sf', '<cmd>Telescope find_files<CR>',              desc = 'Find files' },
      { '<leader>sg', '<cmd>Telescope live_grep<CR>',               desc = 'Live grep' },
      { '<leader>sw', '<cmd>Telescope grep_string<CR>',             desc = 'Grep word under cursor' },
      { '<leader><space>', '<cmd>Telescope buffers<CR>',            desc = 'Open buffers' },
      { '<leader>sh', '<cmd>Telescope help_tags<CR>',               desc = 'Help tags' },
      { '<leader>sk', '<cmd>Telescope keymaps<CR>',                 desc = 'Keymaps' },
      { '<leader>sd', '<cmd>Telescope diagnostics<CR>',             desc = 'Diagnostics' },
      { '<leader>sr', '<cmd>Telescope oldfiles<CR>',                desc = 'Recent files' },
      { '<leader>sc', '<cmd>Telescope colorscheme<CR>',             desc = 'Colorscheme' },
      { '<leader>/',  '<cmd>Telescope current_buffer_fuzzy_find<CR>', desc = 'Fuzzy find in buffer' },
    },
    config = function()
      local telescope = require('telescope')
      local actions   = require('telescope.actions')

      -- Excluded in rg itself, so huge dirs (Drupal's sites/*/files can hold
      -- 500k+ uploads) are never walked, even when they aren't gitignored.
      local ignore_globs = {
        '--glob', '!**/.git/*',
        '--glob', '!**/sites/*/files/*',
        '--glob', '!**/node_modules/*',
        '--glob', '!**/var/cache/*',
      }

      telescope.setup({
        defaults = {
          prompt_prefix   = ' ',
          selection_caret = ' ',
          path_display    = { 'smart' },
          vimgrep_arguments = vim.list_extend({
            'rg', '--color=never', '--no-heading', '--with-filename',
            '--line-number', '--column', '--smart-case', '--hidden',
          }, ignore_globs),
          mappings = {
            i = {
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-j>'] = actions.move_selection_next,
              ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
              ['<esc>'] = actions.close,
            },
          },
        },
        pickers = {
          find_files = {
            find_command = vim.list_extend({ 'rg', '--files', '--color=never', '--hidden' }, ignore_globs),
          },
        },
      })

      pcall(telescope.load_extension, 'fzf')
    end,
  },

  -- File explorer sidebar
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    cmd = 'Neotree',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    keys = {
      { '\\',         '<cmd>Neotree toggle<CR>',       desc = 'Toggle Neo-tree' },
      { '<leader>fe', '<cmd>Neotree focus<CR>',         desc = 'Focus Neo-tree' },
      { '<leader>fg', '<cmd>Neotree git_status<CR>',    desc = 'Neo-tree git status' },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = 'rounded',
      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
        },
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = {
        width = 35,
        mappings = {
          ['<space>'] = 'none',  -- Don't conflict with leader
        },
      },
      default_component_configs = {
        indent = { with_expanders = true },
        git_status = {
          symbols = {
            added     = '',
            modified  = '',
            deleted   = '✖',
            renamed   = '',
            untracked = '',
            ignored   = '',
            unstaged  = '',
            staged    = '',
            conflict  = '',
          },
        },
      },
    },
  },
}
