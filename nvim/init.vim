lua require("plugins")
lua require("lsp")
lua require("utils")
" lua require('keybindings')

" lua require'lualine'.setup { options = { theme = 'gruvbox_dark' } }
" lua require("telescope").load_extension("git_worktree")


let mapleader = " "

colorscheme gruvbox-material
highlight Normal guibg=none

" move lines
nnoremap <C-j> :m +1<CR>
nnoremap <C-k> :m -2<CR>
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi

" window nav
nnoremap <F4> <C-w>l
nnoremap <F1> <C-w>h
nnoremap <F2> <C-w>j
nnoremap <F3> <C-w>k

nnoremap L :GitGutterNextHunk<CR>:GitGutterPreviewHunk<CR>
nnoremap H :GitGutterPrevHunk<CR>:GitGutterPreviewHunk<CR>
nnoremap <leader>ggu :GitGutterUndoHunk<CR>
vnoremap <leader>ggu :GitGutterUndoHunk<CR>
nnoremap <leader>p :GitGutterPreviewHunk<CR>

" sneak
map f <Plug>Sneak_s
map F <Plug>Sneak_S

" comments
nnoremap <C-_> :Commentary<CR>
vnoremap <C-_> :Commentary<CR>gv=gv
inoremap <C-_> <C-o>:Commentary<CR>

" save remap
nnoremap <C-S> :w<CR>

" indents
vnoremap <F19> >gv
nnoremap <F19> >>
vnoremap <F18> <gv
nnoremap <F18> <<

" remove merge lines in visual mode
vnoremap J <nop>

" shift K and J jump blocks
nnoremap K {
nnoremap J }

" jump home/end of line
nnoremap <F17> $
nnoremap <F16> ^
inoremap <F16> <C-o>^
inoremap <F17> <C-o>$

" select a block of code
nnoremap <F15> vap

" S remaps
nnoremap S v$
nnoremap s v

" buffer quit
nnoremap <F12> :q<CR>

" undo tree
nnoremap <leader>u :UndotreeToggle<CR>

" file tree nav
nnoremap <leader>pv :Sex!<CR>

" vertical resize
nnoremap + :vertical resize +5<CR>
nnoremap _ :vertical resize -5<CR>

if executable('rg')
    let g:rg_derive_root='true'
endif


augroup augroup
  autocmd!
  autocmd BufWritePre lua,cpp,c,h,cxx,cc Neoformat
  autocmd BufWritePre * %s/\s\+$//e
  autocmd BufEnter,BufWinEnter,TabEnter *.rs :lua require'lsp_extensions'.inlay_hints{}
augroup END

augroup netrw_mapping
  autocmd!
  autocmd filetype netrw call NetrwMapping()
augroup END

function! NetrwMapping()
  noremap <buffer> <F1> <C-w>h
endfunction

augroup vimrc_help
  autocmd!
  autocmd BufEnter *.txt if &buftype == 'help' | wincmd L | endif
augroup END

augroup typscript-formatting
  autocmd!
  autocmd BufWritePre *.ts,lua,*.tsx lua vim.lsp.buf.formatting()
augroup END

imap <silent><expr> <Tab> IsNextTaboutChar() ? "\<Right>" : '<Tab>'

"poor mans tabout
function! IsNextTaboutChar()
  let l:char = strpart(getline('.'), col('.') -1, 1)
  let l:list = ['"', ')', '}', ']', "'"]
  if index(l:list, l:char) >= 0
    return 1
  endif
  return 0
endfunction

nnoremap <F6> :call ToggleHighlightChar()<CR>

function! ToggleHighlightChar()
  if !exists("g:is_highlight_char_on")
    let g:is_highlight_char_on = 0
  endif

  if g:is_highlight_char_on
    echom "hls on"
    set hlsearch
    let g:is_highlight_char_on = 0
  else
    echom "hls off"
    set nohls
    let g:is_highlight_char_on = 1
  endif

endfunction

