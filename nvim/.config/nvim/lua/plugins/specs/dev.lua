return {
  -- Debugging (Xdebug via php-debug-adapter from mason)
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      {
        'rcarriga/nvim-dap-ui',
        dependencies = { 'nvim-neotest/nvim-nio' },
        opts = {},
      },
    },
    keys = {
      { '<F5>',       function() require('dap').continue() end,          desc = 'Debug: Continue / start' },
      { '<F10>',      function() require('dap').step_over() end,         desc = 'Debug: Step over' },
      { '<F11>',      function() require('dap').step_into() end,         desc = 'Debug: Step into' },
      { '<F12>',      function() require('dap').step_out() end,          desc = 'Debug: Step out' },
      { '<leader>xb', function() require('dap').toggle_breakpoint() end, desc = 'Toggle breakpoint' },
      {
        '<leader>xB',
        function() require('dap').set_breakpoint(vim.fn.input('Condition: ')) end,
        desc = 'Conditional breakpoint',
      },
      { '<leader>xc', function() require('dap').continue() end,          desc = 'Continue / start' },
      { '<leader>xt', function() require('dap').terminate() end,         desc = 'Terminate' },
      { '<leader>xu', function() require('dapui').toggle() end,          desc = 'Toggle debug UI' },
      { '<leader>xe', function() require('dapui').eval() end,            desc = 'Eval expression', mode = { 'n', 'v' } },
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      dap.adapters.php = {
        type = 'executable',
        command = vim.fn.stdpath('data') .. '/mason/bin/php-debug-adapter',
      }

      dap.configurations.php = {
        {
          type = 'php',
          request = 'launch',
          name = 'Listen for Xdebug (local)',
          port = 9003,
        },
        {
          -- DDEV/Lando/Docker: project is mounted at /var/www/html in the container
          type = 'php',
          request = 'launch',
          name = 'Listen for Xdebug (DDEV/Docker)',
          port = 9003,
          pathMappings = {
            ['/var/www/html'] = '${workspaceFolder}',
          },
        },
      }

      -- Open/close the UI with the debug session
      dap.listeners.after.event_initialized['dapui'] = dapui.open
      dap.listeners.before.event_terminated['dapui'] = dapui.close
      dap.listeners.before.event_exited['dapui'] = dapui.close

      vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticError' })
      vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticWarn' })
      vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticOk', linehl = 'Visual' })
    end,
  },

  -- Test runner
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'olimorris/neotest-phpunit',
    },
    keys = {
      { '<leader>Tt', function() require('neotest').run.run() end,                   desc = 'Run nearest test' },
      { '<leader>Tf', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = 'Run file' },
      { '<leader>Tl', function() require('neotest').run.run_last() end,              desc = 'Run last' },
      { '<leader>Ts', function() require('neotest').summary.toggle() end,            desc = 'Toggle summary' },
      { '<leader>To', function() require('neotest').output.open({ enter = true }) end, desc = 'Show output' },
      { '<leader>Tp', function() require('neotest').output_panel.toggle() end,       desc = 'Toggle output panel' },
    },
    config = function()
      require('neotest').setup({
        adapters = {
          require('neotest-phpunit'),
        },
      })
    end,
  },
}
