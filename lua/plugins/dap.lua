return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',
    -- 'nvim-telescope/telescope-dap.nvim',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- Konfigurasi untuk C/C++ menggunakan codelldb
    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = vim.fn.expand '$HOME/.local/share/nvim/mason/bin/codelldb',
        args = { '--port', '${port}' },
      },
    }

    -- Konfigurasi Debugger untuk C dan C++
    dap.configurations.cpp = {
      {
        name = 'Launch file',
        type = 'codelldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
      },
    }

    -- Konfigurasi untuk C sama dengan C++
    dap.configurations.c = dap.configurations.cpp

    -- Konfigurasi untuk Node.js
    dap.adapters.node2 = {
      type = 'executable',
      command = 'node',
      args = { vim.fn.expand '$HOME/.local/share/nvim/mason/packages/node-debug2-adapter/out/src/nodeDebug.js' },
    }

    dap.configurations.javascript = {
      {
        name = 'Launch',
        type = 'node2',
        request = 'launch',
        program = '${file}',
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = 'inspector',
        console = 'integratedTerminal',
      },
      {
        name = 'Attach to process',
        type = 'node2',
        request = 'attach',
        processId = require('dap.utils').pick_process,
      },
    }

    -- Setup DAP UI
    dapui.setup()

    -- Automatically open and close the DAP UI
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end

    -- Keymaps for debugging
    vim.keymap.set('n', '<F5>', function()
      dap.continue()
    end)
    vim.keymap.set('n', '<F10>', function()
      dap.step_over()
    end)
    vim.keymap.set('n', '<F11>', function()
      dap.step_into()
    end)
    vim.keymap.set('n', '<F12>', function()
      dap.step_out()
    end)
    vim.keymap.set('n', '<Leader>b', function()
      dap.toggle_breakpoint()
    end)
    vim.keymap.set('n', '<Leader>B', function()
      dap.set_breakpoint()
    end)
    vim.keymap.set('n', '<Leader>lp', function()
      dap.set_breakpoint(nil, nil, vim.fn.input 'Log point message: ')
    end)
    vim.keymap.set('n', '<Leader>dr', function()
      dap.repl.open()
    end)
    vim.keymap.set('n', '<Leader>dl', function()
      dap.run_last()
    end)

    -- Setup for nvim-dap-virtual-text
    require('nvim-dap-virtual-text').setup()

    -- Setup for telescope-dap
    require('telescope').load_extension 'dap'

    -- Additional Telescope keymaps for DAP
    vim.keymap.set('n', '<Leader>dc', function()
      require('telescope').extensions.dap.commands {}
    end)
    vim.keymap.set('n', '<Leader>dC', function()
      require('telescope').extensions.dap.configurations {}
    end)
    vim.keymap.set('n', '<Leader>db', function()
      require('telescope').extensions.dap.list_breakpoints {}
    end)
    vim.keymap.set('n', '<Leader>dv', function()
      require('telescope').extensions.dap.variables {}
    end)
    vim.keymap.set('n', '<Leader>df', function()
      require('telescope').extensions.dap.frames {}
    end)
  end,
}
