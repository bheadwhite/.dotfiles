local win_utils = require("bdub.win_utils")
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

function CloseAllExceptCurrent()
  local ok, err = pcall(function()
    local didCloseDuplicates = win_utils.close_current_tab_duplicate_windows()

    if not didCloseDuplicates then
      for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local current_tab = vim.api.nvim_get_current_tabpage()
        if tab ~= current_tab then
          pcall(vim.cmd, "tabclose " .. tab)
        end
      end

      local current_wins = vim.api.nvim_list_wins()
      if #current_wins > 1 then
        vim.cmd("BufOnly")
      end
    end
  end)

  if not ok then
    vim.notify("Error in CloseAllExceptCurrent: " .. tostring(err), vim.log.levels.ERROR)
  end
end

vim.keymap.set("n", "<leader>o", CloseAllExceptCurrent, { desc = "Close All Except this one", noremap = true })
