return {
  -- Auto-close brackets, quotes, etc.
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {
      check_ts = true,           -- Use treesitter
      ts_config = {
        lua = { 'string' },
        javascript = { 'template_string' },
      },
    },
  },

  -- Git decorations in the sign column
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPre',
    opts = {
      signs = {
        add          = { text = '▎' },
        change       = { text = '▎' },
        delete       = { text = '' },
        topdelete    = { text = '' },
        changedelete = { text = '▎' },
        untracked    = { text = '▎' },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- Navigation
        map('n', ']h', gs.next_hunk,  'Next hunk')
        map('n', '[h', gs.prev_hunk,  'Prev hunk')

        -- Actions
        map('n', '<leader>gs', gs.stage_hunk,        'Stage hunk')
        map('n', '<leader>gr', gs.reset_hunk,        'Reset hunk')
        map('v', '<leader>gs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Stage hunk')
        map('v', '<leader>gr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Reset hunk')
        map('n', '<leader>gS', gs.stage_buffer,      'Stage buffer')
        map('n', '<leader>gu', gs.undo_stage_hunk,   'Undo stage hunk')
        map('n', '<leader>gR', gs.reset_buffer,      'Reset buffer')
        map('n', '<leader>gp', gs.preview_hunk,      'Preview hunk')
        map('n', '<leader>gb', function() gs.blame_line({ full = true }) end, 'Blame line')
        map('n', '<leader>gd', gs.diffthis,          'Diff this')
        map('n', '<leader>gD', function() gs.diffthis('~') end, 'Diff this ~')

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Select hunk')
      end,
    },
  },

  -- Comment toggling
  {
    'numToStr/Comment.nvim',
    event = 'BufReadPost',
    opts = {},
  },

  -- Detect indentation automatically
  {
    'tpope/vim-sleuth',
    event = 'BufReadPre',
  },
}
