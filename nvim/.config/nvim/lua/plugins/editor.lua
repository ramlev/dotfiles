vim.pack.add({
  -- Release tags ship prebuilt fuzzy-matcher binaries
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.*') },
  'https://github.com/windwp/nvim-autopairs',
  'https://github.com/lewis6991/gitsigns.nvim',
  -- Detect indentation automatically
  'https://github.com/tpope/vim-sleuth',
})

-- Completion (LSP, snippets, buffer, path)
require('blink.cmp').setup({
  keymap = { preset = 'enter' }, -- <CR> accept, <C-n>/<C-p> select, <C-space> open
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 300 },
  },
  signature = { enabled = true },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
})

-- Auto-close brackets, quotes, etc.
require('nvim-autopairs').setup({
  check_ts = true,           -- Use treesitter
  ts_config = {
    lua = { 'string' },
    javascript = { 'template_string' },
  },
})

-- Git decorations in the sign column
require('gitsigns').setup({
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
    map('n', ']h', function() gs.nav_hunk('next') end, 'Next hunk')
    map('n', '[h', function() gs.nav_hunk('prev') end, 'Prev hunk')

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
})
