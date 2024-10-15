vim.cmd([[
  augroup _general_settings
    autocmd!
    autocmd FileType qf,help,man,lspinfo nnoremap <silent> <buffer> q :close<CR>
    autocmd TextYankPost * silent!lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 200})
    autocmd BufWinEnter * :set formatoptions-=cro
    autocmd FileType qf set nobuflisted
  augroup end

  augroup _git
    autocmd!
    autocmd FileType gitcommit setlocal wrap
    autocmd FileType gitcommit setlocal spell
  augroup end

  augroup _markdown
    autocmd!
    autocmd FileType markdown setlocal wrap
    autocmd FileType markdown setlocal spell
  augroup end

  augroup _auto_resize
    autocmd!
    autocmd VimResized * tabdo wincmd =
  augroup end

  " on pre buf save, remove trailing whitespace"
  augroup _remove_trailing_whitespace
    autocmd!
    autocmd BufWritePre * :%s/\s\+$//e
  augroup end

  augroup _help
    autocmd!
    autocmd FileType help wincmd L
  augroup end


  augroup refresh_lsp_progress
    autocmd!
    autocmd User LspProgressUpdate redrawstatus
  augroup END

  "augroup strdr4605
  "  autocmd FileType typescript,typescriptreact set makeprg=./node_modules/.bin/tsc\ \\\|\ sed\ 's/(\\(.*\\),\\(.*\\)):/:\\1:\\2:/'
  "augroup END

  " augroup _typescript_mkprg
  "   autocmd!
  "   autocmd FileType typescript,typescriptreact compiler tsc | setlocal makeprg=NODE_OPTIONS='--max-old-space-size=8192'\ npx\ tsc
  " augroup END

  " augroup set_vim_title
  "   autocmd!
  "   autocmd BufEnter * silent!lua require("bdub.commands").set_vim_title()
  " augroup END

]])
