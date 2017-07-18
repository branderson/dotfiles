" ------ CONTENTS ------
" [A0] General Settings
"   [A1] GUI settings
"   [A2] Language specific settings
" [B0] Plugins
" [C0] Install plugins
"   [C1] General
"       [C1a] Visual
"       [C1b] Views
"       [C1c] Ctags
"       [C1d] Syntax and completion
"       [C1e] Commenting
"       [C1f] Git
"       [C1g] Automation
"       [C1h] Search
"       [C1i] Utilities and dependencies

" ------ General Settings ------
set nocompatible " Turn off vim compatibility mode
filetype on " Detect file types
filetype plugin indent on
if !exists("g:syntax_on")
syntax enable " Syntax highlighting
endif
" Control-X Control-O to open autocomplete box
set omnifunc=syntaxcomplete#Complete
" Leave hidden buffers open
set hidden
set autoread " Reload files changed outside vim

set t_Co=256 " Run in 256-color mode
set number " Show line numbers

" Matchit plugin enhances %
runtime macros/matchit.vim

" Set unix line endings
" set fileformat=unix

" Don't redraw screen when not needed
set lazyredraw

" Allow backspacing over everything
set backspace=indent,eol,start

" Keep longer history
set history=700

" Incremental search
set incsearch

" Smart case insensitive search
set ignorecase
set smartcase

" Maintain context around cursor
set scrolloff=15

" Wildmode configuration
set wildmode=longest,list,full
set wildmenu
" Make hardcoded tab work
:set wildcharm=<C-Z>

" Mouse support
set mouse=a

" Configure tab behavior
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=4
" set autoindent
set cindent
set cinkeys-=0#
set indentkeys-=0#
" set smartindent

" Linewrap
set wrap linebreak nolist

" Show current position
set ruler

" Show matching brackets
set showmatch

" Code folding
set foldmethod=syntax
set foldcolumn=5
set foldlevel=20

" Load default menus
source $VIMRUNTIME/menu.vim

" --- GUI settings ---
set lines=50
set columns=150

" --- Language specific settings ---
" autocmd! BufNewFile,BufReadPre,FileReadPre,BufEnter * set expandtab softtabstop=4 shiftwidth=4
augroup Enter_Buffer
autocmd!
autocmd BufNewFile,BufReadPre,FileReadPre,BufEnter *.pde setlocal softtabstop=2 shiftwidth=2
autocmd BufNewFile,BufReadPre,FileReadPre,BufEnter Makefile setlocal noexpandtab softtabstop=0 shiftwidth=8
autocmd BufNewFile,BufReadPre,FileReadPre,BufEnter *.asm,*.S setlocal softtabstop=8 shiftwidth=8
augroup END

au BufNewFile,BufRead *.py
\ setlocal tabstop=4 |
\ setlocal softtabstop=4 |
\ setlocal shiftwidth=4 |
\ setlocal textwidth=79 |
\ setlocal expandtab |
\ setlocal autoindent |
\ setlocal fileformat=unix |

" ------ Plugins ------
" Clone NeoBundle if not present
if empty(glob("~/.vim/bundle/neobundle.vim"))
!git clone https://github.com/shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
endif

" Powerline
" set rtp+=/usr/lib/python2.7/site-packages/powerline/bindings/vim
" python from powerline.vim import setup as powerline_setup
" python powerline_setup()
" python del powerline_setup

" Always display powerline statusline
set laststatus=2
" Hide default statusline text
set noshowmode "

" Prevent plugin loading on systems without NeoBundle
" if exists("g:loaded_neobundle")
" Set up NeoBundle
set rtp+=~/.vim/bundle/neobundle.vim/
call neobundle#begin(expand('~/.vim/bundle/'))

" let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

" ------ Install Plugins ------
" --- General ---
" - Visual -
" Rainbow parentheses
" NeoBundle 'kien/rainbow_parentheses.vim'
NeoBundle 'luochen1990/rainbow'
" Solarized colors for when I want them
" NeoBundle 'altercation/vim-colors-solarized'
" Zenburn colors for when I want them
" NeoBundle 'jnurmine/Zenburn'
" Base16 themes
" NeoBundle 'chriskempson/base16-vim'
" Hybrid material theme
" NeoBundle 'kristijanhusak/vim-hybrid-material'
" Gruvbox
NeoBundle 'morhetz/gruvbox'
" Airline
NeoBundle 'bling/vim-airline'
" Bufferline
NeoBundle 'bling/vim-bufferline'

" - Views -
" Start screen
NeoBundle 'mhinz/vim-startify'
" Directory view
NeoBundle 'scrooloose/nerdtree'
" Visualize undo tree
NeoBundle 'sjl/gundo.vim'
if v:version >= 703
    " Much nicer buffer management
    NeoBundle 'jlanzarotta/bufexplorer'
endif
" Shows indentation level
" NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'yggdroot/indentLine'
" Show marks
NeoBundle 'kshenoy/vim-signature'

" - Ctags -
" Ctags view
" NeoBundle 'majutsushi/tagbar'
" Automatically keep ctags up to date
" NeoBundle 'xolox/vim-easytags'

" - Syntax and completion -
" Awesome on-the-fly syntax checking for tons of languages
NeoBundle 'scrooloose/syntastic'
" Awesome autocompletion for almost everything
" NeoBundle 'Valloric/YouCompleteMe', {
    "      \ 'build' : {
        "      \     'mac' : './install.sh --clang-completer --system-libclang --omnisharp-completer --racer-completer',
            "      \     'unix' : './install.sh --clang-completer --system-libclang --omnisharp-completer --racer-completer',
            "      \     'windows' : './install.sh --clang-completer --system-libclang --omnisharp-completer --racer-completer',
            "      \     'cygwin' : './install.sh --clang-completer --system-libclang --omnisharp-completer --racer-completer'
                "      \    }
    "      \ }

" - Commenting -
" Comment toggling with lots of options
NeoBundle 'scrooloose/nerdcommenter'
" Simple, quick commenting
NeoBundle 'tpope/vim-commentary'

" - Git -
" Shows git changes in the side gutter
NeoBundle 'gitgutter/Vim'
" Git wrapper inside vim
NeoBundle 'tpope/vim-fugitive'

" - Automation -
" Surround things and change surroundings
NeoBundle 'tpope/vim-surround'
" Parentheses and bracket auto-close
NeoBundle 'Raimondi/delimitMate'
" Much nicer navigation
NeoBundle 'easymotion/vim-easymotion'
" Multiple cursors
NeoBundle 'terryma/vim-multiple-cursors'
" Automatic alignment
NeoBundle 'godlygeek/tabular'

" - Search -
" Kickass fuzzy finder for whole filesystem
NeoBundle 'ctrlpvim/ctrlp.vim'
" Can use Ag from vim
NeoBundle 'rking/ag.vim'

" - Utility and dependencies
" Library required for some plugins
NeoBundle 'L9'
" Close buffers
NeoBundle 'rbgrouleff/bclose.vim'
" Seamless navigation between tmux panes and vim splits
NeoBundle 'christoomey/vim-tmux-navigator'
" Required for easytags
NeoBundle 'xolox/vim-misc'
" Make . work for plugins
NeoBundle 'tpope/vim-repeat'
" Auto reload changed config
NeoBundle 'xolox/vim-reload'
" Make configuration files for YCM
NeoBundle 'rdnetto/YCM-Generator'

" --- Language specific ---
" - All -
NeoBundle 'sheerun/vim-polyglot'

" - Web -
NeoBundle 'mattn/emmet-vim'
NeoBundle 'mattn/webapi-vim'

" - Python -
NeoBundle 'klen/python-mode'
NeoBundle 'davidhalter/jedi-vim'

" - C# -
" Omnicompletion and syntax
NeoBundle 'OmniSharp/omnisharp-vim'

" - Rust -
" Syntax and autocompletion
NeoBundle 'rust-lang/rust.vim'
NeoBundle 'phildawes/racer'

" - Javascript -
NeoBundle 'pangloss/vim-javascript'

" - Processing -
NeoBundle 'sophacles/vim-processing'

" - Markdown -
NeoBundle 'shime/vim-livedown'

if !has('vim_starting')
    " Reload plugins
    call neobundle#call_hook('on_source')
endif
call neobundle#end()
" Prompt installation of uninstalled plugins
NeoBundleCheck
" endif

" Clone racer if not present
if empty(glob("~/dotfiles/racer"))
    !git clone https://github.com/phildawes/racer ~/dotfiles/racer
    "!cd ~/dotfiles/racer
    "!cargo build --release
endif

" ------ Plugin Configuration ------
" --- General ---
" - Visual -
set background=dark
let base16colorspace=256
" let g:solarized_termtrans = 3
let g:airline_powerline_fonts=1
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
if exists('g:rainbow_conf')
    augroup Rainbow_Parentheses
        autocmd!
        autocmd VimEnter * if exists('g:rainbow_conf') | RainbowToggle | endif
    augroup END
endif

" Theme
" colorscheme zenburn
" colorscheme solarized
" colorscheme base16-default
" colorscheme hybrid_reverse
" colorscheme hybrid_material
try
    colorscheme gruvbox
catch /^Vim\%((\a\++)\)\=:E185/
    colorscheme desert
endtry

let g:enable_bold_font = 1

" Have vrm extend background color to full terminal screen
set t_ut=

" - Views -
" Startify
let g:startify_bookmarks = ["~/dotfiles/vimrc", "~/dotfiles/zshrc", "~/dotfiles/config/i3/config"]
let g:startify_custom_indices = ['f', 'd', 's', 'a', 'g']
let g:startify_custom_header = map(split(system('fortune -a -s | fmt -80 -s | cowthink -$(shuf -n 1 -e b d g p s t w y)  -f $(shuf -n 1 -e $(cowsay -l | tail -n +2)) -n'), '\n'), '"   ". v:val') + [","]

" Bufferline
let g:bufferline_echo = 0
augroup Bufferline
    autocmd! VimEnter * if exists('g:loaded_bufferline') | 
        \ let &statusline='%{bufferline#refresh_status()}'
        \ .bufferline#get_status_string() |
        \ endif
augroup END

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
" let g:vim_markdown_preview_hotkey = '<localleader>p'
" let g:vim_markdown_preview_github = 1
" let g:vim_markdown_preview_xdg_open = 1
" let g:vim_markdown_preview_temp_file = 0
" let g:vim_markdown_preview_browser = 'Firefox'
" let g:vim_markdown_preview_toggle = 1

"------ Keybindings ------
" Plugins
"
" BufferExplorer
" leader-be - Open explorer
" leader-bs - Open horizontal split
" leader-bv - Open vertical split
" t or Shift-Enter - Open in new tab
"   switch between open tabs with gt and gT
"
" C-Vim
" I should get this when I have time to learn it
"
" SurroundVim
" [action] s [current] [new] (e.g. cs"' changes " to '
" iw is a text object (so, selecting Hello and pressing ysiw] is [Hello]
"
" Vim Signature
" mx           Toggle mark 'x' and display it in the leftmost column
" dmx          Remove mark 'x' where x is a-zA-Z
" m,           Place the next available mark
" m.           If no mark on line, place the next available mark. Otherwise, remove (first) existing mark.
" m-           Delete all marks from the current line
" m<Space>     Delete all marks from the current buffer
" ]`           Jump to next mark
" [`           Jump to prev mark
" ]'           Jump to start of next line containing a mark
" ['           Jump to start of prev line containing a mark
" `]           Jump by alphabetical order to next mark
" `[           Jump by alphabetical order to prev mark
" ']           Jump by alphabetical order to start of next line having a mark
" '[           Jump by alphabetical order to start of prev line having a mark
" m/           Open location list and display marks from current buffer
" m[0-9]       Toggle the corresponding marker !@#$%^&*()
" m<S-[0-9]>   Remove all markers of the same type
" ]-           Jump to next line having a marker of the same type
" [-           Jump to prev line having a marker of the same type
" ]=           Jump to next line having a marker of any type
" [=           Jump to prev line having a marker of any type
" m?           Open location list and display markers from current buffer
" m<BS>        Remove all markers"
"
" CtrlP
"
" NerdCommenter
" (commas are leaders)
" [count],cc Comment out current line or text selected
" [count],cn Nested comment
" [count],c Toggles comment state of selected lines based on top line
" [count],cm One set of multiline delimiters
" [count],ci Individually toggle comment state of selected lines
" [count],cs Sexy comment (?)
" [count],cy Comments out lines but yanks them first
" ,c$ Comments out from cursor to the end of the line
" ,cA Adds comment delimiters to the end of line insert between them
" ,ca Switches to other set of delimiters
" [count],cu Uncomment selected lines
"
" VimCommentary
" gcc   comment toggle a line
" gc[motion]
"
" Ag.vim
" e    to open file and close the quickfix window
" o    to open (same as enter)
" go   to preview file (open but maintain focus on ag.vim results)
" t    to open in new tab
" T    to open in new tab silently
" h    to open in horizontal split
" H    to open in horizontal split silently
" v    to open in vertical split
" gv   to open in vertical split silently
" q    to close the quickfix window
"
" Easymotion
" ,,w   hightlight words
" ,,f   highlight letters
" ,,s   bidirectional letter search
" ,,b   backwards words
"
" Pymode
" zM closes all open folds.
" zR decreases the foldlevel to zero -- all folds will be open.
" zo opens a fold at the cursor.
" zc close a fold at the cursor.
" zf#j creates a fold from the cursor down # lines.
" zf/string creates a fold from the cursor to string .
" zj moves the cursor to the next fold.
" zk moves the cursor to the previous fold.
" zO opens all folds at the cursor.
" zm increases the foldlevel by one.
" zr decreases the foldlevel by one.
" zd deletes the fold at the cursor.
" zE deletes all folds.
" [z move to start of open fold.
" ]z move to end of open fold.

" --- Mappings ---
" - General -
noremap <space> :
inoremap ,, <ESC>
cnoremap ,, <ESC><ESC>
nmap j gj
nmap k gk
" Only set on first run or it overwrites YCM behavior
" if has('vim_starting')
"     imap <tab> <C-X><C-O>
" endif
let mapleader=","
let maplocalleader="\\"
" Enable hex mode
map <leader>\he :%!xxd<CR>
" Disable hex mode
map <leader>\hd :%!xxd -r<CR>
" Show whitespace
nmap <leader><leader>lw :set list!<CR>
" List registers
map <leader><leader>lr :reg<CR>
" List marks
map <leader><leader>lm :marks<CR>
" Close buffer
map <leader><leader>c :Bclose<CR>
" Prev/next buffer
map <leader>q :bp<CR>
map <leader>w :bn<CR>
" System clipboard cut copy paste
map <leader>y "+y
map <leader><leader>y "+Y
map <leader>p "+p
map <leader><leader>p "+P"
map <leader>x "+x
map <leader><leader>x "+dd
" Move between splits
nnoremap <C-j> <C-W><C-j>
nnoremap <C-k> <C-W><C-k>
nnoremap <C-h> <C-W><C-h>
nnoremap <C-l> <C-W><C-l>
" Make split
nnoremap <leader>- :sp<space>
nnoremap <leader><bar> :vsp<space>
set splitbelow
set splitright
" Open vimrc
map <leader>v :e $MYVIMRC<CR>
" Update vimrc
map <leader>rr :call ReloadVimRC()<CR>;
" Open GVim menu
map <leader>m :emenu <C-Z><C-Z>
" Low-light mode
map <leader><leader>ll :set background=dark<CR>
" Daylight mode
map <leader><leader>LL :set background=light<CR>
" Open ranger
nmap <leader>ra :call Ranger()<CR>
" Delete whitespace
nmap <leader>rw :call DeleteTrailingWS()<CR>
" Fix syntax highlighting
noremap <F12> <Esc>:syntax sync fromstart<CR>

function! MapPlugins()
    " - Plugins -
    if exists('g:loaded_startify')
        " Open Startify
        map <leader><leader>o :Startify<CR>
    endif

    if exists('g:loaded_nerd_tree')
        " Toggle directory view
        map <leader>t :NERDTreeToggle<CR>
    endif

    if exists('g:loaded_tagbar')
        " Toggle tagbar
        map <leader>ct :TagbarToggle<CR>
    endif

    " Update ctags
    " nnoremap <leader>ct :! ctags -R<CR><CR>

    if exists('g:loaded_ctrlp')
        " Jump to a tag
        nnoremap <leader>. :CtrlPTag<CR>
        " Jump to a buffer
        nnoremap <leader>; :CtrlPBuffer<CR>
    endif

    " Make a config for YCM from Makefile
    map <leader>ygc :YcmGenerateConfig<CR>

    " Ag
    map <leader>ag :Ag<space>

    " Easymotion
    if exists('g:EasyMotion_loaded')
        " let g:EasyMotion_do_mapping = 0
        let g:EasyMotion_smartcase = 1
        map <leader>/ <Plug>(easymotion-sn)
        omap <leader>/ <Plug>(easymotion-tn)
        " map <leader>n <Plug>(easymotion-next)
        " map <leader>N <Plug>(easymotion-prev)
        " Bidirectional single-letter search
        map <leader>s <Plug>(easymotion-s)
        " Bidirectional 2-letter search
        map <leader><leader>s <Plug>(easymotion-s2)
        " Forward single letter search
        map <leader>f <Plug>(easymotion-f)
        " Directional jumps
        map <leader>l <Plug>(easymotion-lineforward)
        map <leader>j <Plug>(easymotion-j)
        map <leader>k <Plug>(easymotion-k)
        map <leader>h <Plug>(easymotion-linebackward)
    endif

    " Multiple Cursors
    let g:multi_cursor_use_default_mapping=0
    let g:multi_cursor_next_key='n'
    let g:multi_cursor_prev_key='m'
    let g:multi_cursor_skip_key='.'
    let g:multi_cursor_quit_key=','
    let g:multi_cursor_start_key='<C-n>'

    if exists('g:tabular_loaded')
        " Tabular
        map <leader>a= :Tabularize /=<CR>
        map <leader>a: :Tabularize /:\zs<CR>
    endif

    if exists('g:loaded_nerd_comments')
        " NERD Commenter
        " Enter the NERD Commenter menu which can be tabbed through
        map <leader>nc :emenu Plugin.comment.<C-Z><C-Z>
    endif

    if exists('g:loaded_gundo')
        " Gundo
        nnoremap <leader>u :GundoToggle<CR>
    endif

    " --- Language Specific ---
    " - Rust -
    map <localleader>rr :RustRun<CR>

    " - Markdown -
    map <localleader>v :LivedownToggle<CR>
endfunction

augroup Plugin_Mappings
    autocmd!
    autocmd VimEnter * :call MapPlugins()
augroup END

" silent! call repeat#set("\<Plug>(easymotion)", v:count)

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

"------ Autocommands ------
augroup OpenBuffer
    autocmd!
    " Return to last edit position when opening files
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END

augroup SaveBuffer
    autocmd!
    autocmd FileType c,cpp,java,php,python,rust autocmd BufWritePre <buffer> : call DeleteTrailingWS()
    " Reload vimrc on save
    " autocmd BufWritePost vimrc,.vimrc : call ReloadVimRC()
augroup END
" autocmd BufWritePre *.rs : call DeleteTrailingWS()

" Local overrides
let $LOCALFILE=expand("~/.vimrc_local")
if filereadable($LOCALFILE)
    source $LOCALFILE
endif

if !has('vim_starting')
    " Reload plugins
    silent! call neobundle#call_hook('on_post_source')
endif
