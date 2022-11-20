vim.cmd [[
        imap <silent><script><expr> <S-TAB> copilot#Accept("\<CR>")
        let g:copilot_no_tab_map = v:true
]]
