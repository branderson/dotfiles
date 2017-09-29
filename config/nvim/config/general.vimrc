" Control-X Control-O to open autocomplete box
set omnifunc=syntaxcomplete#Complete
" Leave hidden buffers open
set hidden
set autoread " Reload files changed outside vim

" Turn off .swp files
set noswapfile
set nobackup

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

" Always display airline statusline
set laststatus=2
" Hide default statusline text
set noshowmode "

" Theme
" colorscheme zenburn
" colorscheme solarized
" colorscheme base16-default
" colorscheme hybrid_reverse
" colorscheme hybrid_material
try
    silent! colorscheme gruvbox
catch /^Vim\%((\a\++)\)\=:E185/
    colorscheme desert
endtry

set termguicolors

let g:enable_bold_font = 1

" Have vrm extend background color to full terminal screen
set t_ut=

" --- GUI settings ---
" set lines=50
" set columns=150

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
