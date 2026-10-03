vim.pack.add({
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/neotest',
  'https://github.com/olimorris/neotest-phpunit',
})

local map = vim.keymap.set

-- Debugging (Xdebug via php-debug-adapter from mason).
-- Set up on first use rather than at startup.
local dap_ready = false
local function dap()
  if dap_ready then
    return require('dap')
  end
  dap_ready = true

  local d = require('dap')
  local dapui = require('dapui')
  dapui.setup()

  d.adapters.php = {
    type = 'executable',
    command = vim.fn.stdpath('data') .. '/mason/bin/php-debug-adapter',
  }

  d.configurations.php = {
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
  d.listeners.after.event_initialized['dapui'] = dapui.open
  d.listeners.before.event_terminated['dapui'] = dapui.close
  d.listeners.before.event_exited['dapui'] = dapui.close

  vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticError' })
  vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticWarn' })
  vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticOk', linehl = 'Visual' })

  return d
end

local function dapui()
  dap()
  return require('dapui')
end

map('n', '<F5>',       function() dap().continue() end,          { desc = 'Debug: Continue / start' })
map('n', '<F10>',      function() dap().step_over() end,         { desc = 'Debug: Step over' })
map('n', '<F11>',      function() dap().step_into() end,         { desc = 'Debug: Step into' })
map('n', '<F12>',      function() dap().step_out() end,          { desc = 'Debug: Step out' })
map('n', '<leader>xb', function() dap().toggle_breakpoint() end, { desc = 'Toggle breakpoint' })
map('n', '<leader>xB', function() dap().set_breakpoint(vim.fn.input('Condition: ')) end, { desc = 'Conditional breakpoint' })
map('n', '<leader>xc', function() dap().continue() end,          { desc = 'Continue / start' })
map('n', '<leader>xt', function() dap().terminate() end,         { desc = 'Terminate' })
map('n', '<leader>xu', function() dapui().toggle() end,          { desc = 'Toggle debug UI' })
map({ 'n', 'v' }, '<leader>xe', function() dapui().eval() end,   { desc = 'Eval expression' })

-- Test runner. Set up on first use rather than at startup.
local neotest_ready = false
local function neotest()
  if not neotest_ready then
    neotest_ready = true
    require('neotest').setup({
      adapters = {
        require('neotest-phpunit'),
      },
    })
  end
  return require('neotest')
end

map('n', '<leader>Tt', function() neotest().run.run() end,                   { desc = 'Run nearest test' })
map('n', '<leader>Tf', function() neotest().run.run(vim.fn.expand('%')) end, { desc = 'Run file' })
map('n', '<leader>Tl', function() neotest().run.run_last() end,              { desc = 'Run last' })
map('n', '<leader>Ts', function() neotest().summary.toggle() end,            { desc = 'Toggle summary' })
map('n', '<leader>To', function() neotest().output.open({ enter = true }) end, { desc = 'Show output' })
map('n', '<leader>Tp', function() neotest().output_panel.toggle() end,       { desc = 'Toggle output panel' })
