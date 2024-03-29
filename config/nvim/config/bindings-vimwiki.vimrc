function! MapVimwiki()
    " grep: if exists('g:loaded_vimwiki')
    " double m
    nmap <leader>mm <Plug>VimwikiIndex
    " m wiki
    nmap <leader>mw <Plug>VimwikiUISelect
    " m help
    nmap <leader>mhelp :verbose map ,m<CR>
    " m go
    nmap <leader>mg <Plug>VimwikiGoto
    " m personal
    nmap <leader>mf <Plug>VimwikiUISelect1<CR>
    " m work
    nmap <leader>m<Space> <Plug>VimwikiUISelect2<CR>
    " m private
    nmap <leader>mp <Plug>VimwikiUISelect3<CR>
    " m shared
    nmap <leader>ms <Plug>VimwikiUISelect4<CR>

    " <C-Enter> and <S-Enter> (the original bindings for these) don't work
    " because they send the same keycode and probably other reasons
    nmap <leader>m- <Plug>VimwikiSplitLink
    nmap <leader>m<bar> <Plug>VimwikiVSplitLink

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
    nmap <C-d><C-Space> <Plug>VimwikiRemoveSingleCB
    imap <C-d><C-Space> <Esc><Plug>VimwikiRemoveSingleCBa
    nmap <leader>mb <Plug>VimwikiBackLinks
    " nmap <leader>m\ <Plug>VimwikiTable 
    nmap <leader>mqtoc <Plug>VimwikiTOC
    nmap <leader>mqgtl <Plug>VimwikiRebuildTags<CR><Plug>VimwikiGenerateTagLinks<CR>

    " Insert link from system clipboard
    vmap <leader>mk c[]<Esc>Pea()<Esc>"+P
    imap <leader>mk <Esc>viW<C-k>ea
    nmap <leader>mk ciw[]<Esc>Pea()<Esc>"+P

    " TODO: None of these work
    " nmap <leader>m| :VimwikiVSplitLink 1 1<CR>
    " nmap <leader>m- :VimwikiSplitLink 1 1<CR>
    " vmap <leader>m- :VimwikiSplitLink 1 1<CR>

    " Vim-Zettel
    " TODO The <Plug> syntax is correct but broken
    " autocmd Filetype vimwiki nmap <leader>mag <Plug>ZettelOpen
    autocmd Filetype vimwiki nmap <leader>mag :ZettelOpen<CR>
    " autocmd Filetype vimwiki nmap <leader>mp0 :ZettelOpen<CR>p0
    " autocmd Filetype vimwiki nmap <leader>mp1 :ZettelOpen<CR>p1
    " TODO This doesn't work
    autocmd Filetype vimwiki nmap <leader>mat :ZettelOpen<CR>title:
endfunction

augroup Vimwiki_Mappings
    autocmd!
    " TODO: This isn't working, vimwiki bindings are not being initialized
    autocmd FileType vimwiki :call MapVimwiki()
augroup END
" TODO This shouldn't be necessary, why does this need to be called before vimwiki
" and after startup?
" :call MapVimwiki()
