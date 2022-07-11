local actions = require 'telescope.actions'
local telescope = require 'telescope'

telescope.setup {
    defaults = {
        layout_strategy = "vertical",
        mappings = {i = {['<esc>'] = actions.close}},
        layout_config = {
          width = 0.9,
          height = 0.9,
          preview_cutoff = 30,
          preview_height = 30
        },
        file_ignore_patterns = {
            '.backup',
            '.cache',
            '*.git',
            '.yarn',
            '.gitlab',
            '.undo',
            '.swap',
            '.langservers',
            '.session',
            '.vscode-server',
            'node_modules',
            'vendor',
            'classes',
            -- workdirs
            'build_defs',
            'commons/abool',
            'commons/adapters',
            'commons/audit',
            'commons/auth',
            'commons/census',
            'commons/compliance_antlr',
            'commons/constants',
            'commons/containers',
            'commons/copygen',
            'commons/country',
            'commons/darwin',
            'commons/docker',
            'commons/extractor',
            'commons/goamqp',
            'commons/goasterisk',
            'commons/gomega',
            'commons/gomock',
            'commons/gonfig',
            'commons/grpc',
            'commons/gstorage',
            'commons/health',
            'commons/k8s',
            'commons/lms_antlr',
            'commons/logging',
            'commons/mock_service',
            'commons/mockdlfssdk',
            'commons/mockhazelcast',
            'commons/mockpulsar',
            'commons/mockredis',
            'commons/operations',
            'commons/org',
            'commons/persist',
            'commons/ports',
            'commons/profiler',
            'commons/scanner',
            'commons/sdk',
            'commons/service',
            'commons/skunk',
            'commons/sql',
            'commons/tcnutil',
            'commons/tests',
            'commons/time',
            'k8s',
            'opctl',
            'persist',
            'plz-out',
            'protos',
            'scripts',
            'services',
            'test_helpers',
            'third_party',
            'tools',
            'tools'
        },
        winblend = 20,
        path_display = {'truncate'},
        set_env = {['COLORTERM'] = 'truecolor'}, -- default = nil,
    },
    pickers = {
        buffers = {
          sort_lastused = true,
          previewer = false,
          theme = 'dropdown',
          sort_mru = true},
        find_files = {
          theme = 'dropdown'
        },
        git_files = {
          -- theme = 'dropdown'
        },
        registers = {
          theme = 'dropdown'
        },
        lsp_code_actions = {
          theme = 'cursor'
        },
        lsp_range_code_actions = {
          theme = 'cursor'
        },
        loclist = {
          previewer = false
        }
    },
}

nnoremap('<leader>ps', '<cmd>lua require("telescope.builtin").grep_string({ search = vim.fn.input("Grep for > ")})<CR>', 'telescope', 'telescope_grep_string', 'find project wide string')
nnoremap('<F11>', '<cmd>lua require("telescope.builtin").git_files()<CR>', 'telescope', 'telescope_git', 'view all git files in project')
nnoremap('<leader>pl', '<cmd>lua require("telescope.builtin").live_grep()<CR>', 'telescope', 'telescope_live_grep', 'live grep ')
nnoremap('<leader>ch', '<cmd>lua require("telescope.builtin").command_history()<CR>', 'telescope', 'telescope_command_history', 'telescope the command history')
nnoremap('<leader>pf', '<cmd>lua require("telescope.builtin").current_buffer_fuzzy_find()<CR>', 'telescope', 'telescope_bfr_fzy_find', 'fzy find in the buffer')

nnoremap('<leader>gw', '<cmd>lua require("telescope").extensions.git_worktree.git_worktrees()<CR>', 'telescope', 'telescope_git_worktree', 'view git work trees')
nnoremap('<leader>cgw', '<cmd>lua require("telescope").extensions.git_worktree.create_git_worktree()<CR>', 'telescope', 'telescope_create_git_worktree', 'create a git worktree')

