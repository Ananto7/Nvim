return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    dependencies = { 'nvim-neotest/nvim-nio' },
    {
      'theHamsta/nvim-dap-virtual-text',
      opts = {},
    },
  },

  keys = {
    {
      '<leader>d',
      '',
      desc = '+debug',
      mode = { 'n', 'v' },
    },
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Breakpoint Condition',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Toggle Breakpoint',
    },
    {
      '<leader>dc',
      function()
        require('dap').continue()
      end,
      desc = 'Continue',
    },
    {
      '<leader>da',
      function()
        require('dap').continue { before = get_args }
      end,
      desc = 'Run with Args',
    },
    {
      '<leader>dC',
      function()
        require('dap').run_to_cursor()
      end,
      desc = 'Run to Cursor',
    },
    {
      '<leader>dg',
      function()
        require('dap').goto_()
      end,
      desc = 'Go to Line (No Execute)',
    },
    {
      '<leader>di',
      function()
        require('dap').step_into()
      end,
      desc = 'Step Into',
    },
    {
      '<leader>dj',
      function()
        require('dap').down()
      end,
      desc = 'Down',
    },
    {
      '<leader>dk',
      function()
        require('dap').up()
      end,
      desc = 'Up',
    },
    {
      '<leader>dl',
      function()
        require('dap').run_last()
      end,
      desc = 'Run Last',
    },
    {
      '<leader>do',
      function()
        require('dap').step_out()
      end,
      desc = 'Step Out',
    },
    {
      '<leader>dO',
      function()
        require('dap').step_over()
      end,
      desc = 'Step Over',
    },
    {
      '<leader>dp',
      function()
        require('dap').pause()
      end,
      desc = 'Pause',
    },
    {
      '<leader>dr',
      function()
        require('dap').repl.toggle()
      end,
      desc = 'Toggle REPL',
    },
    {
      '<leader>ds',
      function()
        require('dap').session()
      end,
      desc = 'Session',
    },
    {
      '<leader>dt',
      function()
        require('dap').terminate()
      end,
      desc = 'Terminate',
    },
    {
      '<leader>dw',
      function()
        require('dap.ui.widgets').hover()
      end,
      desc = 'Widgets',
    },
    {
      '<leader>du',
      function()
        require('dapui').toggle {}
      end,
      desc = 'Dap UI',
    },
    {
      '<leader>de',
      function()
        require('dapui').eval()
      end,
      desc = 'Eval',
      mode = { 'n', 'v' },
    },
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

    -- load mason-nvim-dap here, after all adapters have been setup
    if LazyVim.has 'mason-nvim-dap.nvim' then
      require('mason-nvim-dap').setup(LazyVim.opts 'mason-nvim-dap.nvim')
    end

    vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })

    for name, sign in pairs(LazyVim.config.icons.dap) do
      sign = type(sign) == 'table' and sign or { sign }
      vim.fn.sign_define('Dap' .. name, { text = sign[1], texthl = sign[2] or 'DiagnosticInfo', linehl = sign[3], numhl = sign[3] })
    end

    -- setup dap config by VsCode launch.json file
    local vscode = require 'dap.ext.vscode'
    local json = require 'plenary.json'
    vscode.json_decode = function(str)
      return vim.json.decode(json.json_strip_comments(str))
    end
  end,
}
