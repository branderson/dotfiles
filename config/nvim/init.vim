" Source config files
source $HOME/.config/nvim/config/plugin.vimrc
source $HOME/.config/nvim/config/bindings-vimwiki.vimrc
source $HOME/.config/nvim/config/init.vimrc
source $HOME/.config/nvim/config/general.vimrc
source $HOME/.config/nvim/config/bindings.vimrc
source $HOME/.config/nvim/config/functions.vimrc

" Python dependencies
if isdirectory(expand($HOME.'/.pyenv/versions/neovim2'))
    let g:python_host_prog=expand($HOME.'/.pyenv/versions/neovim2/bin/python')
endif
if isdirectory(expand($HOME.'/.pyenv/versions/neovim3'))
    let g:python3_host_prog=expand($HOME.'/.pyenv/versions/neovim3/bin/python')
endif

" Local overrides
let $LOCALFILE=expand("$HOME/.nvim_local.vimrc")
if filereadable($LOCALFILE)
    source $LOCALFILE
endif
