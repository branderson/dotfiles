function! MapVimwiki()
    " grep: if exists('g:loaded_vimwiki')
    nmap <leader>mm <Plug>VimwikiIndex
    nmap <leader>mhelp :verbose map ,m<CR>
    nmap <leader>mg <Plug>VimwikiGoto
    " TODO These two don't split unless I put it on multiple keys like ,mv
    " This is because they send the same keycode
    nmap <C-Enter> <Plug>VimwikiVSplitLink
    nmap <S-Enter> <Plug>VimwikiSplitLink
    nmap <leader>mnt <Plug>VimwikiNextTask
    " TODO This command doesn't exist
    " nmap <leader>mN <Plug>VimwikiPrevTask
    nmap <leader>mnl <Plug>VimwikiNextLink
    nmap <leader>mNl <Plug>VimwikiPrevLink
    " nmap <leader>m/ <Plug>VimwikiSearch /
    " nmap <leader>maq <Plug>ZettelOpen
    nmap <Tab> <Plug>VimwikiIncreaseLvlSingleItem
    nmap <S-Tab> <Plug>VimwikiDecreaseLvlSingleItem
    imap <Tab> <Plug>VimwikiIncreaseLvlSingleItem
    imap <S-Tab> <Plug>VimwikiDecreaseLvlSingleItem
    vmap <Tab> <Plug>VimwikiIncreaseLvlSingleItem
    vmap <S-Tab> <Plug>VimwikiDecreaseLvlSingleItem
    " This is how to map insert mode plug commands <Esc><Plug>{command}a
    " This always jumps to the end of the line, but with 'a' it doesn't skip
    " the [ ] when adding at the start of the line
    imap <C-Space> <Esc><Plug>VimwikiToggleListItemA
    nmap <C-l><C-Space> <Plug>VimwikiRemoveSingleCB
    imap <C-l><C-Space> <Esc><Plug>VimwikiRemoveSingleCBa
    nmap <leader>mb <Plug>VimwikiBackLinks
    " nmap <leader>m\ <Plug>VimwikiTable 
    nmap <leader>mqtoc <Plug>VimwikiTOC
    nmap <leader>mqgtl <Plug>VimwikiRebuildTags<CR><Plug>VimwikiGenerateTagLinks<CR>

    " Insert link from system clipboard
    vmap <C-k> c[]<Esc>Pea()<Esc>"+P
    imap <C-k> <Esc>viW<C-k>ea
    nmap <C-k> ciw[]<Esc>Pea()<Esc>"+P

    " TODO: None of these work
    " nmap <leader>m| :VimwikiVSplitLink 1 1<CR>
    " nmap <leader>m- :VimwikiSplitLink 1 1<CR>
    " vmap <leader>m- :VimwikiSplitLink 1 1<CR>

    " Vim-Zettel
    " autocmd Filetype vimwiki nmap <leader>mag <Plug>ZettelOpen<CR>
endfunction

augroup Vimwiki_Mappings
    autocmd!
    autocmd VimEnter * :call MapVimwiki()
augroup END
" TODO This shouldn't be necessary, why does this need to be called before vimwiki
" and after startup?
:call MapVimwiki()
