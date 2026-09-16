return {
  -- Lua utility functions (required by many plugins)
  { 'nvim-lua/plenary.nvim', lazy = true },

  -- UI component library
  { 'MunifTanjim/nui.nvim', lazy = true },

  -- File type icons (requires a Nerd Font)
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true,
    opts = { default = true },
  },

  -- Colorscheme — TokyoNight Night, same palette as ghostty, tmux and btop.
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {
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
    },
    config = function(_, opts)
      require('tokyonight').setup(opts)
      vim.cmd.colorscheme('tokyonight-night')
    end,
  },
}
