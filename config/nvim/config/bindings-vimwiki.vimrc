function! MapVimwiki()
    " grep: if exists('g:loaded_vimwiki')
    nmap <leader>mm <Plug>VimwikiIndex
    nmap <leader>mhelp :verbose map ,m<CR>
    nmap <leader>mg <Plug>VimwikiGoto
    " TODO These two don't split unless I put it on multiple keys like ,mv
    nmap <C-Enter> <Plug>VimwikiVSplitLink
    nmap <S-Enter> <Plug>VimwikiSplitLink
    nmap <leader>mn <Plug>VimwikiNextTask
    " TODO This command doesn't exist
    " nmap <leader>mN <Plug>VimwikiPrevTask
    " nmap <leader>m/ <Plug>VimwikiSearch /
    nmap <Tab> <Plug>VimWikiListChangeLevel >>
    nmap <S-Tab> <Plug>VimWikiListChangeLevel <<
    imap <Tab> <Plug>VimWikiListChangeLevel >>
    imap <S-Tab> <Plug>VimWikiListChangeLevel <<
    nmap <leader>mb <Plug>VimwikiBackLinks
    " nmap <leader>m\ <Plug>VimwikiTable 
    nmap <leader>mqtoc <Plug>VimwikiTOC
    nmap <leader>mqgtl <Plug>VimwikiRebuildTags<CR><Plug>VimwikiGenerateTagLinks<CR>


    " TODO: None of these work
    " nmap <leader>m| :VimwikiVSplitLink 1 1<CR>
    " nmap <leader>m- :VimwikiSplitLink 1 1<CR>
    " vmap <leader>m- :VimwikiSplitLink 1 1<CR>
endfunction

augroup Vimwiki_Mappings
    autocmd!
    autocmd VimEnter * :call MapVimwiki()
augroup END
" TODO This shouldn't be necessary, why does this need to be called before vimwiki
" and after startup?
:call MapVimwiki()
