"------ Functions ------
if executable('ranger')
    " Open ranger from within vim
    function! Ranger()
        " Get a temp file name without creating it
        let tmpfile = substitute(system('mktemp -u'), '\n', '', '')
        " Launch ranger, passing it the temp file name
        silent exec '!RANGER_RETURN_FILE='.tmpfile.' ranger'
        " If the temp file has been written by ranger
        if filereadable(tmpfile)
            " Get the selected file name from the temp file
            let filetoedit = system('cat '.tmpfile)
            exec 'edit '.filetoedit
            call delete(tmpfile)
        endif
        redraw!
    endfunction
endif

 " set viminfo=%M

" Delete trailing white space on save, useful for Python and CoffeeScript ;)
func! DeleteTrailingWS()
    silent! normal mz
    silent! %s/\s\+$//ge
    silent! normal `z
endfunc
" autocmd BufWrite *.py :call DeleteTrailingWS()
" autocmd BufWrite *.coffee :call DeleteTrailingWS()

" Only define if not defined, otherwise it'll be redefined in the middle of
" execution
if !exists("*ReloadVimRC")
    func! ReloadVimRC()
        " IMPORTANT: After way too much messing with this trying to make everything work properly
        " after a vimrc reload, my advice is DON'T RELOAD THE VIMRC WHILE EDITING A FILE!
        " Side effects will include: Some syntax highlighting lost until next save, indentline
        " plugin will break, newly opened buffers will use buffer reloaded on's syntax file for
        " comment plugins (and possibly other things)
        " Ommision of 'syntax on' here will prevent anything from breaking inside the current buffer,
        " however new buffers will be opened without any syntax highlighting
        source $MYVIMRC
        " Need to toggle this twice, once toggles every other time, none turns
        " it off on reload. I have no idea why this is.
        RainbowToggle
        RainbowToggle
        syntax on
        " Workaround for indentline turning off on syntax enable
        IndentLinesReset
    endfunc
endif
