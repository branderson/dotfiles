" --- General ---
" - Visual -
set background=dark
let base16colorspace=256
" let g:solarized_termtrans = 3

" Airline
let g:airline_powerline_fonts=1
" PERF: Could cause bad performance
let g:airline_skip_empty_sections=1
let g:airline#extensions#tabline#enabled=1

" Gruvbox
let g:gruvbox_italic=1
let g:gruvbox_contrast_dark="medium"
let g:gruvbox_contrast_light="soft"
let g:gruvbox_invert_selection=1
let g:gruvbox_invert_signs=0
let g:gruvbox_improved_strings=0
let g:gruvbox_improved_warnings=1
let g:gruvbox_italicize_strings=1

" Rainbow parentheses
" if exists('g:rainbow_conf')
"     augroup Rainbow_Parentheses
"         autocmd!
"         autocmd VimEnter * if exists('g:rainbow_conf') |
"         \ RainbowToggle |
"         \ endif
"     augroup END
" endif

" - Views -
" Startify
let g:startify_bookmarks = [
    \"~/dotfiles/config/nvim/config/init.vimrc",
    \"~/dotfiles/config/nvim/config/general.vimrc",
    \"~/dotfiles/config/nvim/config/plugin.vimrc",
    \"~/dotfiles/config/nvim/config/bindings.vimrc",
    \"~/dotfiles/config/nvim/config/functions.vimrc",
    \"~/dotfiles/zshrc",
    \"~/dotfiles/config/i3/config"
    \]
let g:startify_custom_indices = ['f', 'd', 's', 'a', 'g']
let g:startify_custom_header = map(split(system('fortune -a -s | fmt -80 -s | cowthink -$(shuf -n 1 -e b d g p s t w y) -f $(shuf -n 1 -e $(cowsay -l | tail -n +2)) -n'), '\n'), '"   ". v:val') + [","]

" Automatically open tagbar when entering supported buffer
" autocmd BufEnter * nested :call tagbar#autoopen(0)

" - Utility -
" DelimitMate sane bracing
let delimitMate_expand_cr = 1

" Indent Guide configuration
" set ts=2 sw=2 et
let g:indent_guides_enable_on_vim_startup = 0
let g:indent_guides_start_level = 2
let g:indent_guides_auto_colors = 0
augroup Indent_Guides
    autocmd!
    autocmd VimEnter,Colorscheme * if exists('g:indentLine_loaded') |
        \ :hi IndentGuidesOdd ctermbg=darkgreen |
        \ endif
    autocmd VimEnter,Colorscheme * if exists('g:indentLine_loaded') |
        \ :hi IndentGuidesEven ctermbg=cyan |
        \ endif
augroup END

" Indent Line configuration
let g:indentLine_faster = 1
" let g:indentLine_leadingSpaceEnabled = 1
" let g:indentLine_leadingSpaceChar = '.'

" GitGutter
let g:gitgutter_map_keys = 0

" NERD Commenter
" let g:NERDMenuMode = 1

" Ctrl-P configuration
" Use nearest version control directory as cwd
let g:ctrlp_working_path_mode = 'r'

" Syntastic configuration
let g:syntastic_aggregate_errors = 1

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = {
    \ "mode": "active",
    \ "passive_filetypes": ['asm', 'scss'] }

" YCM configuration
let g:ycm_global_ycm_extra_conf = '~/dotfiles/.ycm_extra_conf.py'
let g:ycm_extra_conf_globlist = ['~/dotfiles/.ycm_extra_conf.py']

let g:ycm_server_keep_logfiles = 1
let g:ycm_server_log_level = 'debug'
" let g:loaded_youcompleteme = 1
" let g:ycm_min_num_of_chars_for_completion = 100
let g:neobundle#install_process_timeout = 1500
" nnoremap <leader><leader>zy :let g:ycm_auto_trigger=0<CR>
" nnoremap <leader><leader>zY :let g:ycm_auto_trigger=1<CR>

" Powerline configuration
let g:powerline_pycmd = "py"
" let g:powerline_pyeval = "pyeval"

" Neotags configuration
" let g:neotags_enabled = 1

" Vimwiki configuration
let g:vimwiki_list = [
            \{'path': '~/notebook/', 'syntax': 'markdown', 'ext': '.md', 'diary_rel_path': 'daily_notes/', 'diary_index': 'index', 'diary_header': 'Daily Notes', 'auto_tags': 1, 'auto_diary_index': 1, 'auto_generate_links': 1, 'auto_generate_tags': 1},
            \{'path': '~/work_notebook/', 'syntax': 'markdown', 'ext': '.md'},
            \{'path': '~/private_notebook/', 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_map_prefix = '<Leader>m'
augroup filetype_vimwiki
    " Wrap lines nicely
    autocmd Filetype vimwiki set breakindent
    autocmd Filetype vimwiki set breakindentopt=shift:2
augroup END

"Vim-Zettel configuration
" let g:zettel_fzf_command = "ag "

" --- Language Specific ---
" - All -
let g:polyglot_disabled = ['python']

" - Web -
let g:user_emmet_install_global=0
augroup Emmet
    autocmd!
    autocmd Filetype html,css if exists('g:loaded_emmet_vim') |
        \ EmmetInstall |
        \ endif
augroup END
" let g:user_emmet_leader_key='<localleader>'

" - Javascript -
" Javascript configuration
let g:javascript_enable_dom_htmlcss = 1

" - Python -
" Run in python using F9
augroup Python
    autocmd!
    autocmd FileType python nnoremap <buffer> <F9> :exec '!python' shellescape(@%, 1)<cr>
augroup END

" Documentation
let g:pymode_doc = 1
let g:pymode_doc_key = 'K'

" Linting
let g:pymode_lint = 1
let g:pymode_lint_checkers = ['pyflakes', 'pep8']
let g:pymode_lint_message = 1

" Auto check on save
let g:pymode_lint_write = 1

" Support virtualenv
let g:pymode_virtualenv = 1

" Enable breakpoints plugin
let g:pymode_breakpoint = 1
let g:pymode_breakpoint_bind = '<localleader>b'

" Syntax highlighting
let g:pymode_syntax = 1
let g:pymode_syntax_all = 1
let g:pymode_syntax_indent_errors = g:pymode_syntax_all
let g:pymode_syntax_space_errors = g:pymode_syntax_all

" Enable python folding
let g:pymode_folding = 1

" Enable pymode motion
let g:pymode_motion = 1

" Set up default python options
let g:pymode_options = 1

" Trim whitespace on save
let g:pymode_trim_whitespaces = 1

" PEP8-compatible python indent
" let g:pymode_indent = 1

" Rope support
let g:pymode_rope = 0

" [YELP] Ignore line too long
let g:pymode_lint_ignore = "W503,E128"

" - Rust -
" Rust racer
let g:racer_cmd = "~/dotfiles/racer/target/release/racer"
" Must install Rust source to this location first
let $RUST_SRC_PATH="/usr/local/src/rust/src/"
" Rust folding
let g:rust_fold = 2

" - Processing -
let g:processing_fold = 1

" - Markdown -
let g:livedown_open = 1
