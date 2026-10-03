vim.pack.add({
  -- Lua utility functions (required by many plugins)
  'https://github.com/nvim-lua/plenary.nvim',
  -- UI component library
  'https://github.com/MunifTanjim/nui.nvim',
  -- File type icons (requires a Nerd Font)
  'https://github.com/nvim-tree/nvim-web-devicons',
  -- Colorscheme
  'https://github.com/folke/tokyonight.nvim',
})

require('nvim-web-devicons').setup({ default = true })

-- Colorscheme — TokyoNight Night, same palette as ghostty, tmux and btop.
require('tokyonight').setup({
  style = 'night',
  -- Ghostty draws the background itself (with opacity + blur), the tmux
  -- status bar uses bg=default and btop runs theme_background = false, so
  -- let it show through instead of painting an opaque #1a1b26 on top.
  transparent = true,
  terminal_colors = true,
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
  },
  -- lualine's outer pill caps blend into StatusLine, keep it see-through too.
  on_highlights = function(hl, c)
    hl.StatusLine = { fg = c.fg_dark, bg = 'NONE' }
    hl.StatusLineNC = { fg = c.comment, bg = 'NONE' }
  end,
})
vim.cmd.colorscheme('tokyonight-night')
