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
" Clear highlighting on ,, in normal mode
map <leader><leader><ESC> :nohl<CR>
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
" map <leader>m :emenu <C-Z><C-Z>
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

    if exists('g:loaded_zettel')
    endif
    if exists('g:loaded_vimwiki')
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
