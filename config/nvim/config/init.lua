vim.cmd([[
let g:vim_plug_install_dir = "~/.local/share/nvim/site/autoload"
let g:plugin_install_dir = "~/.local/share/nvim/plugged"

" Install vim-plug if not present
if empty(glob(g:vim_plug_install_dir . "/plug.vim"))
    execute "!curl -fLo " . g:vim_plug_install_dir . "/plug.vim "
        \ "--create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
endif

call plug#begin('~/.vim/plugged')

" --- General ---
" - Visual -
" Rainbow parentheses
Plug 'luochen1990/rainbow'
" Gruvbox
Plug 'morhetz/gruvbox'
" Airline
" TODO This now depends on lua
Plug 'bling/vim-airline'

" - Views -
" Start screen
Plug 'mhinz/vim-startify'
" Directory view
Plug 'scrooloose/nerdtree'
" Visualize undo tree
Plug 'sjl/gundo.vim'
" Much nicer buffer management
Plug 'jlanzarotta/bufexplorer'
" Shows indentation level
Plug 'yggdroot/indentLine'
" Show marks
" TODO Make this not conflict with ,mm for vimwiki, probably just an issue
" with not having vimwiki installed yet
" Plug 'kshenoy/vim-signature'
"
" - Sessions -
" Better sessions
Plug 'tpope/vim-obsession'

" - Generative AI -
Plug 'David-Kunz/gen.nvim'

" - Ctags -
" Ctags view
Plug 'majutsushi/tagbar'
" Automatically keep ctags up to date
" Plug 'xolox/vim-easytags'
" TODO Fix compatibility with vim-zettel
" Plug 'c0r73x/neotags.nvim'

" - Syntax and completion -
" Asynchronous linting
Plug 'neomake/neomake'
" Completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Awesome autocompletion for almost everything
" Plug 'Valloric/YouCompleteMe', {
    "      \ 'build' : {
        "      \     'mac' : './install.sh --clang-completer --system-libclang --omnisharp-completer --racer-completer',
            "      \     'unix' : './install.sh --clang-completer --system-libclang --omnisharp-completer --racer-completer',
            "      \     'windows' : './install.sh --clang-completer --system-libclang --omnisharp-completer --racer-completer',
            "      \     'cygwin' : './install.sh --clang-completer --system-libclang --omnisharp-completer --racer-completer'
                "      \    }
    "      \ }

" - Commenting -
" Comment toggling with lots of options
Plug 'scrooloose/nerdcommenter'
" Simple, quick commenting
Plug 'tpope/vim-commentary'

" - Git -
" Shows git changes in the side gutter
" Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-signify'
" Git wrapper inside vim
Plug 'tpope/vim-fugitive'

" - Automation -
" Surround things and change surroundings
Plug 'tpope/vim-surround'
" Parentheses and bracket auto-close
Plug 'Raimondi/delimitMate'
" Much nicer navigation
" TODO Move this to space key
Plug 'easymotion/vim-easymotion'
" Multiple cursors
Plug 'terryma/vim-multiple-cursors'
" Automatic alignment
Plug 'godlygeek/tabular'
" Tables
Plug 'dhruvasagar/vim-table-mode'

" - Search -
" Kickass fuzzy finder for whole filesystem
Plug 'ctrlpvim/ctrlp.vim'
" Can use Ag from vim
" Plug 'rking/ag.vim'

" - Utility and dependencies
" Library required for some plugins
" Plug 'L9'
" Close buffers
Plug 'rbgrouleff/bclose.vim'
" Seamless navigation between tmux panes and vim splits
Plug 'christoomey/vim-tmux-navigator'
" Required for easytags
Plug 'xolox/vim-misc'
" Make . work for plugins
Plug 'tpope/vim-repeat'
" Auto reload changed config
Plug 'xolox/vim-reload'
" Make configuration files for YCM
" Plug 'rdnetto/YCM-Generator'

" - Note Taking -
" Note taking and wiki managment
Plug 'vimwiki/vimwiki'
" TODO Why can't these go in Search?
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'michal-h21/vim-zettel'
" TODO Make this pull on buffer open / load
" Plug 'michal-h21/vimwiki-sync'

" --- Language specific ---
" - All -
Plug 'sheerun/vim-polyglot'
" Integration with language servers but manual configuration
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Allows vim to configure filetype by file section (for svelte)
Plug 'Shougo/context_filetype.vim'
" Prettier
Plug 'prettier/vim-prettier', {
  \ 'do': 'npm install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'yaml', 'html'] }

" - Web -
Plug 'mattn/emmet-vim'
Plug 'mattn/webapi-vim'
Plug 'cakebaker/scss-syntax.vim'

" - Python -
" Plug 'klen/python-mode'
" Plug 'davidhalter/jedi-vim'
" Completion
" Plug 'zchee/deoplete-jedi'

" - C# -
" Omnicompletion and syntax
" Plug 'OmniSharp/omnisharp-vim'

" - Rust -
" Syntax and autocompletion
" Plug 'rust-lang/rust.vim'
" Plug 'phildawes/racer'

" - Javascript -
Plug 'pangloss/vim-javascript'

" - Typescript -
Plug 'HerringtonDarkholme/yats.vim'
" TODO: Needs to be installed with `:CocInstall coc-tsserver`, figure out how
" to config this
" Plug 'coc-extensions/coc-tsserver'

" - Svelte
" Plug 'evanleck/vim-svelte', {'branch': 'main'}
Plug 'leafOfTree/vim-svelte-plugin'
Plug 'coc-extensions/coc-svelte'

" - Processing -
Plug 'sophacles/vim-processing'

" - Markdown -
" Plug 'shime/vim-livedown'


" --- Icons ---
" For some reason this needs to be loaded last
Plug 'ryanoasis/vim-devicons'

call plug#end()
]])
