-- from : https://github.com/vim-scripts/BufOnly.vim/blob/master/plugin/BufOnly.vim
vim.cmd([[
" BufOnly.vim  -  Delete all the buffers except the current/named buffer.
"
" Copyright November 2003 by Christian J. Robinson <infynity@onewest.net>
"
" Distributed under the terms of the Vim license.  See ":help license".
"
" Usage:
"
" :Bonly / :BOnly / :Bufonly / :BufOnly [buffer]
"
" Without any arguments the current buffer is kept.  With an argument the
" buffer name/number supplied is kept.

command! -nargs=? -complete=buffer -bang Bonly
    \ :call BufOnly('<args>', '<bang>')
command! -nargs=? -complete=buffer -bang BOnly
    \ :call BufOnly('<args>', '<bang>')
command! -nargs=? -complete=buffer -bang Bufonly
    \ :call BufOnly('<args>', '<bang>')
command! -nargs=? -complete=buffer -bang BufOnly
    \ :call BufOnly('<args>', '<bang>')

function! BufOnly(buffer, bang)
	if a:buffer == ''
		" No buffer provided, use the current buffer.
		let buffer = bufnr('%')
	elseif (a:buffer + 0) > 0
		" A buffer number was provided.
		let buffer = bufnr(a:buffer + 0)
	else
		" A buffer name was provided.
		let buffer = bufnr(a:buffer)
	endif

	if buffer == -1
		echohl ErrorMsg
		echomsg "No matching buffer for" a:buffer
		echohl None
		return
	endif

	let last_buffer = bufnr('$')

	let delete_count = 0
	let n = 1
	while n <= last_buffer
		if n != buffer && buflisted(n)
			if a:bang == '' && getbufvar(n, '&modified')
				echohl ErrorMsg
				echomsg 'No write since last change for buffer'
							\ n '(add ! to override)'
				echohl None
			else
				silent exe 'bdel' . a:bang . ' ' . n
				if ! buflisted(n)
					let delete_count = delete_count+1
				endif
			endif
		endif
		let n = n+1
	endwhile

	if delete_count == 1
		echomsg delete_count "buffer deleted"
	elseif delete_count > 1
		echomsg delete_count "buffers deleted"
	endif

endfunction]])

function CloseDuplicateBuffers()
  -- Get a list of all window IDs
  local windows = vim.api.nvim_list_wins()

  -- Get the name of the current buffer
  local current_buffer = vim.api.nvim_get_current_buf()
  local current_buffer_name = vim.api.nvim_buf_get_name(current_buffer)

  -- Get the current window ID
  local current_window = vim.api.nvim_get_current_win()

  local didClose = false

  local i = 1
  while i <= #windows do
    -- Get the buffer displayed in the window
    local win = windows[i]
    local buffer = vim.api.nvim_win_get_buf(win)
    local win_buf_name = vim.api.nvim_buf_get_name(buffer)

    -- If the buffer is not the current buffer and its name matches the current buffer's name
    -- and the window is not the current window
    if win_buf_name == current_buffer_name and win ~= current_window then
      didClose = true
      -- Close the window
      vim.api.nvim_win_close(win, true)

      -- Refresh the list of windows
      windows = vim.api.nvim_list_wins()
    else
      i = i + 1
    end
  end

  vim.api.nvim_set_current_buf(current_buffer)
  return didClose
end

function CloseAllExceptCurrent()
  local didCloseDuplicates = CloseDuplicateBuffers()

  if not didCloseDuplicates then
    vim.cmd([[BufOnly]])
  end
end

vim.keymap.set("n", "<leader>o", CloseAllExceptCurrent, { desc = "Close All Except this one", noremap = true })
